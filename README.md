# Flutter MacOS Dock

A Flutter implementation of a MacOS-style dock with smooth animations and scaling effects.

![Demo](assets/demo.gif)

## Demo

- [Live Demo](https://sanskarsh.github.io/Flutter_MacOS_Dock/)
- [DartPad Demo](https://dartpad.dev/?embed=true&id=632316326346fe89bbd321c664be8e26)

## Features

- Smooth drag and drop reordering
- MacOS-like scaling animations
- Responsive hover effects
- Customizable items

## Usage

```dart
Dock(
  items: const [
    Icons.person,
    Icons.message,
    Icons.call,
    Icons.camera,
    Icons.photo,
  ],
  builder: (icon) {
    return Container(
      constraints: const BoxConstraints(minWidth: 48),
      height: 48,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.primaries[icon.hashCode % Colors.primaries.length],
      ),
      child: Center(child: Icon(icon, color: Colors.white)),
    );
  },
)
```

## Getting Started

Add to your `pubspec.yaml`:
```yaml
dependencies:
  flutter_macos_dock:
    git:
      url: https://github.com/SanskarSh/Flutter_MacOS_Dock.git
```