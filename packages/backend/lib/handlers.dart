import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:postgres/postgres.dart';
import 'package:crypto/crypto.dart';
import 'package:shared/user.dart';
import 'package:dotenv/dotenv.dart';

var env = DotEnv(includePlatformEnvironment: true)..load();
final db = PostgreSQLConnection(
  env['DB_HOST']!,
  int.parse(env['DB_PORT']!),
  env['DB_NAME']!,
  username: env['DB_USERNAME']!,
  password: env['DB_PASSWORD']!,
);

Future<void> _ensureDbConnected() async {
  if (db.isClosed) await db.open();
}

String hashPassword(String password) {
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

Future<Response> signUpHandler(Request req) async {
  await _ensureDbConnected();
  final body = await req.readAsString();
  final data = json.decode(body);
  final user = User.fromJson(data);

  if ([user.firstName, user.lastName, user.email, user.password].any((e) => e.isEmpty)) {
    return Response(400, body: jsonEncode({'message': 'All fields are required.'}));
  }


  final existing = await db.query(
    'SELECT id FROM users WHERE email = @email',
    substitutionValues: {'email': user.email},
  );
  if (existing.isNotEmpty) {
    return Response(409, body: jsonEncode({'message': 'Email already registered.'}));
  }

  await db.query(
    '''INSERT INTO users (first_name, last_name, email, password_hash) 
       VALUES (@first, @last, @email, @hash)''',
    substitutionValues: {
      'first': user.firstName,
      'last': user.lastName,
      'email': user.email,
      'hash': hashPassword(user.password),
    },
  );

  return Response(200, body: jsonEncode({'message': 'Registration successful'}));
}

Future<Response> loginHandler(Request req) async {
  await _ensureDbConnected();
  final body = await req.readAsString();
  final data = json.decode(body);

  final email = data['email']?.trim();
  final password = data['password'];

  if ([email, password].any((e) => e == null || e.isEmpty)) {
    return Response(400, body: jsonEncode({'message': 'Email and password required.'}));
  }

  final hashed = hashPassword(password);

  final result = await db.query(
    'SELECT id, first_name, last_name, email FROM users WHERE email = @email AND password_hash = @hash',
    substitutionValues: {'email': email, 'hash': hashed},
  );

  if (result.isEmpty) {
    return Response(401, body: jsonEncode({'message': 'Invalid credentials.'}));
  }

  final user = result.first.toColumnMap();
  return Response.ok(jsonEncode({'message': 'Login successful', 'user': user}));
}
