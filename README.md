# Colory

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Colory.svg)](https://cocoapods.org/pods/Colory)
[![License](https://img.shields.io/cocoapods/l/Colory.svg)](https://github.com/crazytonyli/Colory/blob/master/LICENSE)

A `UIControl` for picking color from HSB color palette.

![Screenshot](Example/Colory.gif)

P.S. Gradient looks way smoother on device than this gif.

## Installation

### CocoaPods

To install Colory using [CocoaPods](https://cocoapods.org), add following line to your Podfile:

```
pod 'Colory'
```

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
