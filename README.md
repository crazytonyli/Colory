# Colory

![Swift 3, 4](https://img.shields.io/badge/Swift-3%2C%204-orange.svg)
[![Build Status](https://img.shields.io/travis/crazytonyli/Colory.svg)](https://travis-ci.org/crazytonyli/Colory)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Colory.svg)](https://cocoapods.org/pods/Colory)
![Carthage](https://img.shields.io/badge/carthage-compatible-blue.svg)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://github.com/crazytonyli/Colory/blob/master/LICENSE)

A `UIControl` for picking color from HSB color palette.

![Screenshot](Example/Colory.gif)

P.S. Gradient looks way smoother on device than this gif.

## Installation

### CocoaPods

To install Colory using [CocoaPods](https://cocoapods.org), add following line to your Podfile:

    pod 'Colory'

### Carthage

To install Colory using [Carthage](https://github.com/Carthage/Carthage), add following line to your Cartfile:

    github "crazytonyli/Colory"

## Usage

Colory has very simple API.

Register action with `valueChanged` event to receive picked color changes.

```swift
let pickerView = ColorPickerView()
pickerView.addTarget(self, action: #selector(colorChanged(_:)), for: .valueChanged)
```


Use `color` property to get and set currently picked color.

```swift
@objc func colorChanged(_ pickerView: ColorPickerView) {
    update(with: pickerView.color)
}
```

Use `layoutMargins` to customize palette margins.
```swift
pickerView.layoutMargins = UIEdgeInsets(top: pickerView.layoutMargins.top,
                                        left: 20,
                                        bottom: pickerView.layoutMargins.bottom,
                                        right: 20)
```

## LICENSE

This library is released under [MIT License](LICENSE).
