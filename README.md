# images

# English Learning App

A Flutter mobile application for improving English speaking, listening, and vocabulary skills.

## Features

* Vocabulary learning
* Text-to-speech support
* Pronunciation practice
* Translation support
* Responsive UI
* BLoC state management

## Technologies

* Flutter
* Dart
* BLoC
* REST API
* Flutter TTS

## Installation

```bash
flutter pub get
flutter run
```

## Screenshots
    * Home
        * Event → Bloc → State → UI (BlocBuilder)
            * Events — what the user does:
                * HomeLoaded — screen opens, triggers data fetch
                * LessonResumed(id) — taps a lesson card
                * QuickPracticeTapped(skill) — taps a practice tile
                * NavTabChanged(index) — switches bottom nav tab
            * States — what the UI shows:
                * HomeInitial → blank before anything loads
                * HomeLoading → spinner
                * HomeReady → full data (stats, lessons, quick practices)
                * HomeError → error message
            * Key BLoC patterns used:
                * Equatable on all events/states so BLoC skips redundant rebuilds
                * copyWith on HomeReady for partial updates (e.g. nav tab change without re-fetching data)
                * context.read<HomeBloc>().add(...) in widgets to dispatch events
                * BlocBuilder for rebuilding UI on state changes
                * BlocProvider at the top of HomeScreen to scope the bloc
                


(Add screenshots here)

## Author

Phi Tran Xuan
- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)
(- https://thigiacmaytinh.com/huong-dan-viet-file-markdown-readme-md/)

# Programming Language
    – Dart

# IDE for development

    – VsCode
    – Android Studio
    – intellij

# User Interface
    - Widgets
        - statefull widget
        - stateless widget
        - accessibility
        - Inherited widget
            * Theming
            * Localization


    - Style
        - Material
        - Cupertion

    - Assets
        - fonts
        - images
        - svg
        - audio
        - video

    - Static User Interface
        - View
            * Text,Image,button raised button etc
        - ViewGroup
            * Container, Row, Column, Stack, Expanded, ConstrainedBox

    - Dynamic User Interface
        - ListView
        - GridView
        - ExpansionTitle

    - Animation
        - AnimatedWidget
        - AnimatedBuilder
        - AnimationController
        - CurvedAnimation
        - Hero
        - Transform
        - Opacity

    - Sotrage
        - shared preference
        - file storage
        - sqlite
    - 3rd party libararies
        - http
        - dio
        - get_it
        - cached_network_image
        - Flutter_webview_plug-in
        - font_awesome_flutter
        - SQFLite
        - rxdart
        - bloc_pattern
 
    - Behavior Components

        - Permission
        - Local Notification
        - Push Notification
        - Download Manager
        - Media Playback
        - Preference
        - Sharing

    - State management

        - setState
        - Provider
        - Redux
        - BLoC
        - MobX
    - Quality Assurance

        - Firebase
            * Crashlytics
            * App distribution
            * Analytics
        - Google play beta tests
        - TestFlight
        - App Center
    - Version Control

        - Git
        - Github
        - Bitbucket
        - Gitlab
    - Firebase

        - Firebase Auth
        - Firebase database
        - Firebase Storage
        - Firebase Messaging

    - Native Integration
        - Android
            * Android Studio
            * Java
            * Kotlin
            * App Siging
            * Google Play Store
            * In App Purchase
        - IOS
            * Xcode
            * Swift
            * Objective-C
            * Apple Certification
            * AppStore

Keep Learning and try to improve your code.


 # BLOC: Includes
    - Design Pattern
    - State Management Library
    - Architectural Pattern


 # How to Handle the Voice AI Workflow
 1. User taps "New Chat"
    => Event: StartChat()
 2. BLoC calls Gemini service → gets welcome message
    => State: ChatLoading()
    => State: ChatReady(messages=[welcome])
 3. UI shows welcome card + "Tap to Speak" mic button
 4. User taps "Tap to Speak" (opens voice screen)
    => Event: OpenVoice()
    => State: VoiceModeActive(conversationId, isListening=false, isSpeaking=false)
 5. User holds mic → App records audio
    => BLoC streams AudioRecordEvent.started
    => BLoC streams AudioRecordEvent.started
    => BLoC streams AudioRecordEvent.data(chunk)
 6. User releases mic → App sends audio to Gemini
    => Event: SendVoice(audioBuffer)
 7. BLoC calls Gemini: generates transcription + response + translation
    => State: ChatReady(..., isWaitingForTutor: true)
    => Gemini streams JSON: { transcription, response, translation }
    => BLoC accumulates chunks: transcription="I...", "I had...", "I had a great...", "I had a great day!"
    => UI updates typing indicator or streams text in real-time
 8. Gemini finishes → BLoC emits:
    => State: ChatReady(..., isWaitingForTutor: false)
    => State: ChatReady(..., isSpeaking: true)
    => Flutter TTS speaks response
 9. User speaks in Vietnamese → Gemini transcribes → BLoC sends:
    => Event: SendText("Ngày hôm nay của tôi rất vui")
 10. Gemini sends response in English + Vietnamese translation
    => State: ChatReady(..., isWaitingForTutor: true)
    => BLoC updates state with full response + translation
    => State: ChatReady(..., isWaitingForTutor: false)
 11. BLoC emits: isSpeaking=true
    => Flutter TTS speaks
    => User taps pause → stop TTS
    => isSpeaking=false
 12. User taps "End Chat" (top right) or app navigates away
    => Event: EndSession()
    => BLoC closes Gemini stream
    => BLoC emits ChatInitial()
 13. UI returns to chat list

 # Key Concepts
 
 ✓ Event-driven → everything starts with user actions
 ✓ State-first → UI reflects state (no direct calls from widgets)
 ✓ Async boundary → Gemini calls happen inside BLoC only
 ✓ Streams → manage real-time audio + streaming AI responses
 ✓ Cancellation → properly close Gemini stream when needed