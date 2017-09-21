//
//  ViewController.swift
//  Example
//
//  Created by Tony Li on 21/09/17.
//  Copyright © 2017 Tony Li. All rights reserved.
//

import UIKit
import Colory

class ViewController: UIViewController {

    private var colorView: UIView?
    private var hexLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()

        colorView = UIView()
        colorView?.clipsToBounds = true
        colorView?.layer.cornerRadius = 4
        colorView?.layer.borderWidth = 1
        colorView?.layer.borderColor = UIColor.gray.cgColor
        view.addSubview(colorView!)

        hexLabel = UILabel()
        view.addSubview(hexLabel!)

        let pickerView = ColorPickerView()
        pickerView.addTarget(self, action: #selector(colorChanged(_:)), for: .valueChanged)
        view.addSubview(pickerView)

        colorView?.translatesAutoresizingMaskIntoConstraints = false
        hexLabel?.translatesAutoresizingMaskIntoConstraints = false
        pickerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            pickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            hexLabel!.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            hexLabel!.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hexLabel!.bottomAnchor.constraint(equalTo: pickerView.topAnchor),

            colorView!.widthAnchor.constraint(equalTo: colorView!.heightAnchor),
            colorView!.heightAnchor.constraint(equalToConstant: 30),
            colorView!.centerYAnchor.constraint(equalTo: hexLabel!.centerYAnchor),
            colorView!.trailingAnchor.constraint(equalTo: hexLabel!.leadingAnchor, constant: -10)
            ])

        update(with: pickerView.color)
    }

    @objc private func colorChanged(_ pickerView: ColorPickerView) {
        update(with: pickerView.color)
    }

    private func update(with color: UIColor) {
        colorView?.backgroundColor = color
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: nil)
        hexLabel?.text = String(format: "#%02X%02X%02X", arguments: [red, green, blue].map { Int($0 * 255) })
    }

}

