//
//  ColorPickerView.swift
//  Colory
//
//  Created by Tony Li on 20/09/17.
//  Copyright © 2017 Tony Li. All rights reserved.
//

import UIKit

/// A control used to pick color from HSB color palette.
///
/// Use `color` property to get and set currently picked color. You can also use `set(_:animated:)`
/// to change color with animation.
///
/// Use `layoutMargins` to customize palette margins.
///
/// Register action with `valueChanged` event to receive picked color changes.
public class ColorPickerView: UIControl {
    fileprivate let paletteView: ColorPickerGradientView
    fileprivate let hueLayer: CAGradientLayer
    fileprivate let palettePicker: UIView
    fileprivate let huePicker: UIView

    private var observations = [NSKeyValueObservation]() {
        didSet { oldValue.forEach { $0.invalidate() } }
    }

    fileprivate weak var panGestureRecognizer: UIPanGestureRecognizer?
    fileprivate var panGestureSession: ColorPickerPanSession?

    private var _color = UIColor.white {
        didSet {
            paletteView.hue = hue
            palettePicker.backgroundColor = _color
            huePicker.backgroundColor = UIColor(hue: hue, saturation: 1, brightness: 1, alpha: 1)
        }
    }

    /// Currently picked color, default value is `.white`.
    public var color: UIColor {
        get {
            return _color
        }
        set {
            _color = newValue
            setNeedsLayout()
        }
    }

    override public init(frame: CGRect) {
        paletteView = ColorPickerGradientView(frame: CGRect(origin: .zero, size: frame.size))
        hueLayer = CAGradientLayer()
        palettePicker = UIView()
        huePicker = UIView()
        super.init(frame: frame)

        setup()
    }

    deinit {
        observations = []
    }

    required public init?(coder aDecoder: NSCoder) {
        paletteView = ColorPickerGradientView(frame: CGRect(origin: .zero, size: .zero))
        hueLayer = CAGradientLayer()
        palettePicker = UIView()
        huePicker = UIView()
        super.init(coder: aDecoder)

        setup()
    }

    private func setup() {
        [palettePicker, huePicker].forEach { (picker) in
            picker.bounds.size = CGSize(width: 22, height: 22)
            picker.clipsToBounds = true
            picker.layer.cornerRadius = picker.bounds.width / 2
            picker.layer.borderColor = UIColor.white.cgColor
            picker.layer.borderWidth = 2
        }

        hueLayer.actions = ["bounds": NSNull(), "position": NSNull(), "frame": NSNull()]
        hueLayer.frame = CGRect(x: 20, y: bounds.height - 30, width: bounds.width - 40, height: 10)
        hueLayer.masksToBounds = true
        hueLayer.cornerRadius = hueLayer.bounds.height / 2
        hueLayer.colors = (0...6).map { UIColor(hue: CGFloat($0) / 6, saturation: 1, brightness: 1, alpha: 1).cgColor }
        hueLayer.startPoint = CGPoint(x: 0, y: 0)
        hueLayer.endPoint = CGPoint(x: 1, y: 0)
        layer.addSublayer(hueLayer)

        addSubview(paletteView)
        addSubview(palettePicker)
        addSubview(huePicker)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handle(pan:)))
        pan.delegate = self
        addGestureRecognizer(pan)
        panGestureRecognizer = pan
        let tap = UITapGestureRecognizer(target: self, action: #selector(handle(tap:)))
        addGestureRecognizer(tap)

        observations = [palettePicker, huePicker].map {
            $0.observe(\UIView.center, options: [.new]) { [unowned self] _, _ in
                let palettePickerCenter = self.palettePicker.convert(CGPoint(x: self.palettePicker.bounds.midX,
                                                                             y: self.palettePicker.bounds.midY),
                                                                     to: self.paletteView)
                let saturation = palettePickerCenter.x / self.paletteView.bounds.width
                let brightness = 1 - palettePickerCenter.y / self.paletteView.bounds.height
                self._color = UIColor(hue: self.hue, saturation: saturation, brightness: brightness, alpha: 1)
            }
        }
    }

    override public var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 200)
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: max(200, size.height))
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        let huePickerSpace: CGFloat = 8
        let paletteViewFrame = CGRect(x: palettePicker.bounds.width / 2 + layoutMargins.left,
                                      y: palettePicker.bounds.height / 2 + layoutMargins.top,
                                      width: bounds.width - palettePicker.bounds.width - layoutMargins.left - layoutMargins.right,
                                      height: bounds.height - palettePicker.bounds.height / 2 - layoutMargins.top - huePicker.bounds.height - layoutMargins.bottom - huePickerSpace)
        var hueLayerFrame = CGRect(x: paletteViewFrame.minX, y: 0, width: paletteViewFrame.width, height: 10)
        hueLayerFrame.origin.y = bounds.height - layoutMargins.bottom - huePicker.bounds.height / 2 - hueLayerFrame.height / 2
        hueLayer.frame = hueLayerFrame
        paletteView.frame = paletteViewFrame

        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)

        var huePickerCenter = huePicker.center
        huePickerCenter.x = hueLayer.convert(.zero, to: huePicker.layer.superlayer).x + min(1, hue) * hueLayer.bounds.width
        update(huePickerCenter: huePickerCenter)

        update(palettePickerCenter: CGPoint(x: saturation * paletteViewFrame.width + paletteViewFrame.minX,
                                            y: (1 - brightness) * paletteViewFrame.height + paletteViewFrame.minY))
    }

    public func set(_ newColor: UIColor, animated: Bool) {
        if !animated {
            color = newColor
            return
        }

        UIView.animate(withDuration: 0.3) {
            self.color = newColor
            self.layoutIfNeeded()
        }
    }
}

// MARK: - Actions
fileprivate extension ColorPickerView {

    @objc func handle(pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .ended, .cancelled, .failed, .possible:
            panGestureSession = nil
        case .began:
            panGestureSession = ColorPickerPanSession(palettePicker: palettePicker, huePicker: huePicker)
        case .changed:
            guard let session = panGestureSession else { break }
            let (palette, hue) = session.update(with: pan)
            var changed = false
            if let center = palette {
                changed = changed || update(palettePickerCenter: center)
            }
            if let center = hue {
                changed = changed || update(huePickerCenter: center)
            }

            if changed {
                sendActions(for: .valueChanged)
            }
        }
    }

    @objc func handle(tap: UITapGestureRecognizer) {
        var changed = false

        if let index = (0..<tap.numberOfTouches).first(where: { paletteView.bounds.contains(tap.location(ofTouch: $0, in: paletteView)) }) {
            changed = changed || update(palettePickerCenter: tap.location(ofTouch: index, in: palettePicker.superview))
        }

        assert(hueLayer.superlayer == huePicker.superview?.layer)
        let touchableBounds = hueLayer.frame.insetBy(dx: 0, dy: -20)
        if let index = (0..<tap.numberOfTouches).first(where: { touchableBounds.contains(tap.location(ofTouch: $0, in: huePicker.superview)) }) {
            changed = changed || update(huePickerCenter: tap.location(ofTouch: index, in: huePicker.superview))
        }

        if changed {
            sendActions(for: .valueChanged)
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension ColorPickerView: UIGestureRecognizerDelegate {
    override public func gestureRecognizerShouldBegin(_ gesture: UIGestureRecognizer) -> Bool {
        guard gesture == panGestureRecognizer else { return true }

        let palettePickerBounds = ColorPickerPanSession.touchableBounds(for: palettePicker)
        let huePickerBounds = ColorPickerPanSession.touchableBounds(for: huePicker)
        return (0..<gesture.numberOfTouches).contains(where: {
            palettePickerBounds.contains(gesture.location(ofTouch: $0, in: palettePicker))
                || huePickerBounds.contains(gesture.location(ofTouch: $0, in: huePicker))
        })
    }
}

// MARK: - Private methods

fileprivate extension ColorPickerView {
    var hue: CGFloat {
        return huePicker.layer.convert(CGPoint(x: huePicker.bounds.midX, y: 0), to: hueLayer).x / hueLayer.bounds.width
    }

    @discardableResult
    func update(palettePickerCenter: CGPoint) -> Bool {
        let paletteViewFrame = paletteView.frame
        var center = palettePickerCenter
        center.x = max(paletteViewFrame.minX, min(paletteViewFrame.maxX, center.x))
        center.y = max(paletteViewFrame.minY, min(paletteViewFrame.maxY, center.y))
        if palettePicker.center != center {
            palettePicker.center = center
            return true
        }
        return false
    }

    @discardableResult
    func update(huePickerCenter: CGPoint) -> Bool {
        let hueLayerFrame = hueLayer.frame
        var center = huePickerCenter
        center.x = max(hueLayerFrame.minX, min(hueLayerFrame.maxX, center.x))
        center.y = hueLayer.position.y
        if huePicker.center != center {
            huePicker.center = center
            return true
        }
        return false
    }
}

private class ColorPickerPanSession {
    weak var palettePicker: UIView?
    weak var huePicker: UIView?

    private var indexOfTouchOnPalettePicker: Int?
    private var indexOfTouchOnHuePicker: Int?

    static func touchableBounds(for picker: UIView) -> CGRect {
        let bounds = picker.bounds
        let minSize: CGFloat = 44
        return bounds.insetBy(dx: min((bounds.width - minSize) / 2, 0), dy: min((bounds.height - minSize) / 2, 0))
    }

    init(palettePicker: UIView, huePicker: UIView) {
        self.palettePicker = palettePicker
        self.huePicker = huePicker
    }

    func update(with pan: UIPanGestureRecognizer) -> (palette: CGPoint?, hue: CGPoint?) {
        let trackingCount = (indexOfTouchOnPalettePicker == nil ? 0 : 1) + (indexOfTouchOnHuePicker == nil ? 0 : 1)
        if trackingCount > pan.numberOfTouches {
            indexOfTouchOnPalettePicker = nil
            indexOfTouchOnHuePicker = nil
        }

        if let index = indexOfTouchOnPalettePicker, index >= pan.numberOfTouches {
            indexOfTouchOnPalettePicker = nil
        }
        if let index = indexOfTouchOnHuePicker, index >= pan.numberOfTouches {
            indexOfTouchOnHuePicker = nil
        }

        if indexOfTouchOnPalettePicker == nil {
            let bounds = palettePicker.flatMap { ColorPickerPanSession.touchableBounds(for: $0) } ?? .zero
            indexOfTouchOnPalettePicker = (0..<pan.numberOfTouches).first {
                $0 != indexOfTouchOnHuePicker && bounds.contains(pan.location(ofTouch: $0, in: palettePicker))
            }
        }
        if indexOfTouchOnHuePicker == nil {
            let bounds = huePicker.flatMap { ColorPickerPanSession.touchableBounds(for: $0) } ?? .zero
            indexOfTouchOnHuePicker = (0..<pan.numberOfTouches).first {
                $0 != indexOfTouchOnPalettePicker && bounds.contains(pan.location(ofTouch: $0, in: huePicker))
            }
        }

        return (palette: indexOfTouchOnPalettePicker.flatMap { pan.location(ofTouch: $0, in: palettePicker?.superview ) },
                hue: indexOfTouchOnHuePicker.flatMap { pan.location(ofTouch: $0, in: huePicker?.superview) })
    }
}

private class ColorPickerGradientView: UIView {
    var hue: CGFloat = 0 {
        didSet {
            if abs(hue - oldValue) > 0.00001 {
                setNeedsDisplay()
            }
        }
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else {
            assertionFailure("Failed to create graphics context")
            return
        }

        let unitHeight: CGFloat = 1
        var gradientRect = CGRect(x: 0, y: 0, width: bounds.width, height: unitHeight)
        while gradientRect.minY < bounds.height {
            ctx.saveGState()
            defer { ctx.restoreGState() }

            let brightness = (bounds.height - gradientRect.minY) / bounds.size.height
            let colors: NSArray = [
                UIColor(hue: hue, saturation: 0, brightness: brightness, alpha: 1).cgColor,
                UIColor(hue: hue, saturation: 1, brightness: brightness, alpha: 1).cgColor
            ]
            guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1]) else {
                assertionFailure("Failed to create gradient")
                return
            }

            ctx.clip(to: gradientRect)
            ctx.drawLinearGradient(gradient,
                                   start: CGPoint(x: gradientRect.minX, y: gradientRect.minY),
                                   end: CGPoint(x: gradientRect.maxX, y: gradientRect.maxY),
                                   options: .drawsAfterEndLocation)

            gradientRect = gradientRect.offsetBy(dx: 0, dy: unitHeight)
            if gradientRect.maxY > bounds.height {
                gradientRect.size.height = bounds.height - gradientRect.minY
            }
        }

    }
}
