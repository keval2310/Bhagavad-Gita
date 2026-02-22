# Soul Guide: Emotion-Aware Bhagavad Gita Counsellor

A premium, spiritual, and intelligent Flutter application that provides personalized emotional guidance using AI analysis and the timeless wisdom of the Bhagavad Gita.

## ✨ Features

- **Multi-Modal Emotion Detection**: Analyze emotions via face (ML Kit), voice (Sentiment), and text (NLP).
- **Spiritual Mapping Engine**: Intelligently maps emotional states to relevant Gita Shlokas.
- **Divine Guidance Screen**: Elegant presentation of Sanskrit shlokas, translations, and psychological insights.
- **Wellness Dashboard**: Track mood trends, streaks, and frequent emotional states.
- **User Reflection Journal**: Practice self-inquiry and journal your thoughts.
- **Animated Splash Screen**: Features an animated, rotating Om symbol for a peaceful entry.
- **Dark Mode Support**: Seamless transition between light and spiritual dark themes.

## 🛠️ Tech Stack

- **Framework**: Flutter (Material 3)
- **State Management**: Riverpod
- **AI/ML**: 
  - Google ML Kit (Face Detection)
  - Gemini AI (Optional - for advanced insights)
- **Backend**: Firebase (Auth, Firestore)
- **Animations**: animate_do, Lottie

## 🚀 Setup Instructions

1. **Clone the Repo**:
   ```bash
   git clone <repository-url>
   cd "Bhagavad Gita"
   ```

2. **Backend Configuration (Firebase)**:
   - Create a project on the [Firebase Console](https://console.firebase.google.com/).
   - Add an Android app and download `google-services.json`.
   - Place `google-services.json` in `android/app/`.
   - Enable **Anonymous Auth** and **Cloud Firestore**.

3. **AI Configuration (Optional)**:
   - Get a Gemini API key from [Google AI Studio](https://aistudio.google.com/).
   - Update `GeminiService` with your key in `lib/services/gemini_service.dart`.

4. **Run the App**:
   ```bash
   flutter pub get
   flutter run
   ```

## 📂 Project Structure

- `lib/core/`: Theming and global constants.
- `lib/features/`: Modularized features (Auth, Dashboard, Emotion Engine, Gita Counsellor).
- `lib/models/`: Data models for emotions and recommendations.
- `lib/services/`: Firebase, Gemini, and Local detection services.
- `lib/providers/`: Riverpod state management.

## 🎯 Play Store Preparation

This project follows a lean, MVVM-inspired architecture.
- **Clean Code**: Unnecessary files removed.
- **Productive Defaults**: Includes mock fallbacks for easier demonstration without cloud keys.
- **Responsiveness**: UI scales across phone and tablet sizes.

---
*Created with peace and precision.*
