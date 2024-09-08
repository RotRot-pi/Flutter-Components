# Flutter Expandable Card with Implicit Animations

This project demonstrates how to create an expandable card widget in Flutter using implicit animations. The card smoothly expands and collapses when tapped, revealing more content with a subtle animation.

## Video Demo

![Flutter Expandable Card with Implicit Animations](screenshots/Screencast_20240908_122847.gif)

## Features

* **Expandable Card:** The card expands and collapses on tap.
* **Implicit Animations:** Uses `AnimatedContainer`, `AnimatedRotation`, and `AnimatedOpacity` for smooth transitions.
* **Customizable UI:** You can easily change the card's background color, image, text styles, and icon.

## Getting Started

1. Clone this repository.
2. Run `flutter pub get` to install dependencies.
3. Run the app using `flutter run`.

## Code Overview

The `ExpandableCard` widget is a stateful widget that manages the expansion state. It uses `AnimatedContainer` to animate the card's height, `AnimatedRotation` to rotate the expansion icon, and `AnimatedOpacity` to fade the text content in and out.

## Customization

You can customize the card's appearance by modifying the following:

* **Background Image:** Change the `image` property of the `BoxDecoration` in the `AnimatedContainer`.
* **Background Color:** Change the `color` property of the `BoxDecoration`.
* **Text Styles:** Modify the `TextStyle` properties in the `Text` widgets.
* **Expansion Icon:** Change the `icon` property of the `AnimatedRotation` widget.
