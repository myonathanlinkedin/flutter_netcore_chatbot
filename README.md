# Flutter NetCore Chatbot

A modern chatbot application built with Flutter and .NET Core, implementing clean architecture with BLoC pattern.

## Features

- Real-time chat interface
- Clean Architecture with BLoC pattern
- Cross-platform support (iOS, Android, Web)
- Modern Material Design 3
- Integration with .NET Core backend (upcoming)

## Project Structure

```
lib/
├── blocs/          # BLoC pattern implementation
│   └── chat/       # Chat feature BLoCs
├── data/           # Data layer
│   ├── models/     # Data models
│   └── datasources/# Data sources
├── repositories/   # Repository pattern
├── screens/        # UI screens
├── widgets/        # Reusable widgets
├── services/       # Business logic
├── utils/          # Helper functions
└── main.dart       # Entry point
```

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- .NET Core SDK (for backend)
- Android Studio / VS Code
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/flutter_netcore_chatbot.git
cd flutter_netcore_chatbot
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

## Architecture

This project follows the BLoC (Business Logic Component) pattern:
- **BLoC Layer**: Handles business logic and state management
- **Repository Layer**: Abstracts data sources
- **Data Layer**: Manages API and local storage
- **Presentation Layer**: UI components and screens

## Dependencies

- `flutter_bloc`: State management
- `get_it`: Dependency injection
- `freezed`: Code generation for immutable classes
- `dio`: HTTP client
- `shared_preferences`: Local storage

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

Copyright © 2025 Mateus Yonathan

This project includes software developed by Mateus Yonathan (https://www.linkedin.com/in/siyoyo).

Licensed under the Apache License, Version 2.0 (the "License").
You may obtain a copy of the License at:

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

## Contact

Mateus Yonathan - [@siyoyo](https://www.linkedin.com/in/siyoyo)

Project Link: [https://github.com/yourusername/flutter_netcore_chatbot](https://github.com/yourusername/flutter_netcore_chatbot) 