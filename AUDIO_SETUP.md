# Audio Files Setup Guide

This guide explains how to add audio files to the Sparks mobile app for the calm music player feature.

## 📁 Directory Structure

Create the following folder structure in your project:

```
sparks_monorepo/
└── assets/
    └── audio/
        ├── forest.mp3
        ├── ocean.mp3
        ├── meditation.mp3
        ├── rain.mp3
        └── whitenoise.mp3
```

## 🎵 Required Audio Files

You need to add 5 audio files to the `assets/audio/` folder:

| File Name | Description | Recommended Duration |
|-----------|-------------|---------------------|
| `forest.mp3` | Forest ambience with gentle rain | ~10 minutes |
| `ocean.mp3` | Calming ocean waves | ~15 minutes |
| `meditation.mp3` | Tibetan singing bowls and bells | ~8 minutes |
| `rain.mp3` | Gentle rain sounds | ~12 minutes |
| `whitenoise.mp3` | Continuous white noise | ~20 minutes |

## 📥 Where to Get Free Audio Files

### Option 1: Free Stock Audio Websites
- **Pixabay** (https://pixabay.com/sound-effects/search/nature/)
  - License: Free for commercial use
  - Search for: "forest", "ocean waves", "rain", "meditation bell", "white noise"

- **Freesound** (https://freesound.org/)
  - License: Creative Commons (check individual licenses)
  - Search for nature sounds and meditation music

- **YouTube Audio Library** (https://studio.youtube.com/channel/UC/music)
  - License: Free to use
  - Filter by "Ambient" and "Meditation"

### Option 2: Generate White Noise
- Use online generators like:
  - https://www.noisli.com/
  - https://mynoise.net/

### Option 3: Record Your Own (Optional)
- Use a recording app to create custom ambient sounds

## 🛠️ Steps to Add Audio Files

### 1. Create the Audio Folder
```bash
mkdir -p assets/audio
```

### 2. Download or Add Your Audio Files
- Download the audio files from the sources above
- Make sure they are in **MP3 format**
- Name them exactly as shown in the table above
- Place them in the `assets/audio/` folder

### 3. Verify File Names
Ensure your files are named exactly as follows:
- ✅ `forest.mp3`
- ✅ `ocean.mp3`
- ✅ `meditation.mp3`
- ✅ `rain.mp3`
- ✅ `whitenoise.mp3`

**Important:** File names are case-sensitive!

### 4. Install Dependencies
Run the following command in your terminal:

```bash
flutter pub get
```

### 5. Clean and Rebuild
After adding audio files, clean and rebuild the app:

```bash
flutter clean
flutter pub get
flutter run
```

## 🎧 Audio Format Recommendations

- **Format:** MP3 (recommended) or M4A
- **Quality:** 128-192 kbps (good balance between quality and file size)
- **File Size:** Keep each file under 10 MB for better performance
- **Duration:** Longer loops are better to avoid frequent restarts

## 🔧 Troubleshooting

### Audio Not Playing?
1. **Check file paths:**
   - Ensure files are in `assets/audio/`
   - Verify file names match exactly (case-sensitive)

2. **Check pubspec.yaml:**
   ```yaml
   flutter:
     assets:
       - assets/audio/
   ```

3. **Run flutter clean:**
   ```bash
   flutter clean
   flutter pub get
   ```

4. **Check device volume:**
   - Make sure device volume is turned up
   - Check if device is not in silent mode

### Error: "Unable to load asset"
- This means the file path is incorrect or file doesn't exist
- Double-check folder structure and file names

### Audio Stops When App Goes to Background (iOS)
- This is expected behavior for the current implementation
- Background audio requires additional configuration in iOS

## 📝 Optional: Using Your Own Audio Files

If you want to use different audio files:

1. Place your MP3 files in `assets/audio/`
2. Update the file paths in `lib/screens/user/relaxation_page.dart`:

```dart
final List<Map<String, dynamic>> _musicTracks = [
  {
    'title': 'Your Custom Title',
    'duration': 'XX:XX',
    'description': 'Your description',
    'icon': Icons.your_icon,
    'file': 'assets/audio/your-file.mp3',  // ← Update this
  },
  // ... more tracks
];
```

## 🎉 Testing

Once setup is complete:

1. Run the app: `flutter run`
2. Navigate to Dashboard
3. Click "Start Training"
4. Go to "Calm Music" tab
5. Click play on any track
6. You should hear the audio playing

## 📱 Supported Platforms

The audioplayers package supports:
- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 📚 Additional Resources

- [audioplayers package documentation](https://pub.dev/packages/audioplayers)
- [Flutter assets guide](https://docs.flutter.dev/development/ui/assets-and-images)

---

**Need help?** Check the error messages in the console or refer to the audioplayers documentation.
