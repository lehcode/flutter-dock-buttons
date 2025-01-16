# Animated Dock Buttons

A Flutter application demonstrating an animated dock interface inspired by macOS, with draggable buttons and smooth animations.

## Features

- Animated dock with hover effects
- Draggable buttons with smooth scaling
- Material Design 3 theming
- Gradient background
- Interactive button feedback

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Git

### Installation

#### Clone the repository

```bash
git clone https://github.com/yourusername/dock-buttons.git
```

#### Navigate to project directory

```bash
cd dock-buttons
```

#### Install dependencies

```bash
flutter pub get
```

#### Run the application

```bash
flutter run -d chrome
```

## Project Structure

```bash
lib/
├── models/
│   └── dock_button.dart
├── widgets/
│   ├── desktop_widget.dart
│   ├── dock.dart
│   └── dock_button_widget.dart
└── main.dart
```

## Components

- `DockButton` - Model class for dock button data
- `Dock` - Main dock container with animation logic
- `DockButtonWidget` - Individual button with drag functionality
- `DesktopWidget` - Desktop area supposed to handle button drops

## Tech Stack

- Language: Dart
- Framework: Flutter

## Deployment

The application is deployed using GitHub Pages. Visit:
https://lehcode.github.io/dock-buttons/

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by macOS dock functionality
- Flutter animation system
- Material Design guidelines

---
