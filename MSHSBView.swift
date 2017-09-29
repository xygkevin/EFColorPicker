//
//  MSHSBView.swift
//  EFColorPicker
//
//  Created by EyreFree on 2017/9/29.
//

import UIKit

// The view to edit HSB color components.
public class MSHSBView: UIView, MSColorView, UITextFieldDelegate {

    let MSColorSampleViewHeight: CGFloat = 30.0
    let MSViewMargin: CGFloat = 20.0
    let MSColorWheelDimension: CGFloat = 200.0

    private let colorWheel: MSColorWheelView = MSColorWheelView()
    private let brightnessView: MSColorComponentView = MSColorComponentView()
    private let colorSample: UIView = UIView()

    private var colorComponents: HSB = HSB(1, 1, 1, 1)
    private var layoutConstraints: [NSLayoutConstraint] = []

    weak public var delegate: MSColorViewDelegate?

    public var color: UIColor {
        get {
            return UIColor(
                hue: colorComponents.hue,
                saturation: colorComponents.saturation,
                brightness: colorComponents.brightness,
                alpha: colorComponents.alpha
            )
        }
        set {
            colorComponents = MSRGB2HSB(rgb: MSRGBColorComponents(color: newValue))
            self.reloadData()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.ms_baseInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.ms_baseInit()
    }

    func reloadData() {
        colorSample.backgroundColor = self.color
        colorSample.accessibilityValue = MSHexStringFromColor(color: self.color)
        self.ms_reloadViewsWithColorComponents(colorComponents: colorComponents)
    }

    override public func updateConstraints() {
        self.ms_updateConstraints()
        super.updateConstraints()
    }

    // MARK:- Private methods
    private func ms_baseInit() {
        self.accessibilityLabel = "hsb_view"

        colorSample.accessibilityLabel = "color_sample"
        colorSample.layer.borderColor = UIColor.black.cgColor
        colorSample.layer.borderWidth = 0.5
        colorSample.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(colorSample)

        colorWheel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(colorWheel)

        brightnessView.title = NSLocalizedString("Brightness", comment: "")
        brightnessView.maximumValue = MSHSBColorComponentMaxValue
        brightnessView.format = "%.2f"
        brightnessView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(brightnessView)

        colorWheel.addTarget(
            self, action: #selector(ms_colorDidChangeValue(sender:)), for: UIControlEvents.valueChanged
        )
        brightnessView.addTarget(
            self, action: #selector(ms_brightnessDidChangeValue(sender:)), for: UIControlEvents.valueChanged
        )

        self.setNeedsUpdateConstraints()
    }

    private func ms_updateConstraints() {
        // remove all constraints first
        if !layoutConstraints.isEmpty {
            self.removeConstraints(layoutConstraints)
        }

        layoutConstraints = UIUserInterfaceSizeClass.compact == self.traitCollection.verticalSizeClass
            ? self.ms_constraintsForCompactVerticalSizeClass()
            : self.ms_constraintsForRegularVerticalSizeClass()

        self.addConstraints(layoutConstraints)
    }

    private func ms_constraintsForRegularVerticalSizeClass() -> [NSLayoutConstraint] {
        let metrics = [
            "margin" : MSViewMargin,
            "height" : MSColorSampleViewHeight,
            "color_wheel_dimension" : MSColorWheelDimension
        ]
        let views = [
            "colorSample" : colorSample,
            "colorWheel" : colorWheel,
            "brightnessView" : brightnessView
        ]

        var layoutConstraints: [NSLayoutConstraint] = []
        layoutConstraints.append(
            contentsOf: NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-margin-[colorSample]-margin-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: metrics,
                views: views
            )
        )
        layoutConstraints.append(
            contentsOf: NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-margin-[colorWheel(>=color_wheel_dimension)]-margin-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: metrics,
                views: views
            )
        )
        layoutConstraints.append(
            contentsOf: NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-margin-[brightnessView]-margin-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: metrics,
                views: views
            )
        )
        layoutConstraints.append(
            contentsOf: NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-margin-[colorSample(height)]-margin-[colorWheel]-margin-[brightnessView]-(>=margin@250)-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: metrics,
                views: views
            )
        )
        layoutConstraints.append(
            NSLayoutConstraint(
                item: colorWheel,
                attribute: NSLayoutAttribute.width,
                relatedBy: NSLayoutRelation.equal,
                toItem: colorWheel,
                attribute: NSLayoutAttribute.height,
                multiplier: 1,
                constant: 0)
        )
        return layoutConstraints
    }

    private func ms_constraintsForCompactVerticalSizeClass() -> [NSLayoutConstraint] {
        let metrics = [
            "margin" : MSViewMargin,
            "height" : MSColorSampleViewHeight,
            "color_wheel_dimension" : MSColorWheelDimension
        ]
        let views = [
            "colorSample" : colorSample,
            "colorWheel" : colorWheel,
            "brightnessView" : brightnessView
        ]

        var layoutConstraints: [NSLayoutConstraint] = []
        layoutConstraints.append(
            contentsOf: NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-margin-[colorSample]-margin-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: metrics,
                views: views
            )
        )
        layoutConstraints.append(
            contentsOf: NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-margin-[colorWheel(>=color_wheel_dimension)]-margin-[brightnessView]-(margin@500)-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: metrics,
                views: views
            )
        )
        layoutConstraints.append(
            contentsOf: NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-margin-[colorSample(height)]-margin-[colorWheel]-(margin@500)-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: metrics,
                views: views
            )
        )
        layoutConstraints.append(
            NSLayoutConstraint(
                item: colorWheel,
                attribute: NSLayoutAttribute.width,
                relatedBy: NSLayoutRelation.equal,
                toItem: colorWheel,
                attribute: NSLayoutAttribute.height,
                multiplier: 1,
                constant: 0)
        )
        layoutConstraints.append(
            NSLayoutConstraint(
                item: brightnessView,
                attribute: NSLayoutAttribute.centerY,
                relatedBy: NSLayoutRelation.equal,
                toItem: self,
                attribute: NSLayoutAttribute.centerY,
                multiplier: 1,
                constant: 0)
        )
        return layoutConstraints
    }

    private func ms_reloadViewsWithColorComponents(colorComponents: HSB) {
        colorWheel.hue = colorComponents.hue
        colorWheel.saturation = colorComponents.saturation
        self.ms_updateSlidersWithColorComponents(colorComponents: colorComponents)
    }

    private func ms_updateSlidersWithColorComponents(colorComponents: HSB) {
        brightnessView.value = colorComponents.brightness
        let tmp: UIColor = UIColor(hue: colorComponents.hue, saturation: colorComponents.saturation , brightness: 1, alpha: 1)
        brightnessView.setColors(colors: [UIColor.black.cgColor, tmp.cgColor])
    }

    @objc private func ms_colorDidChangeValue(sender: MSColorWheelView) {
        colorComponents.hue = sender.hue
        colorComponents.saturation = sender.saturation
        self.delegate?.colorView(colorView: self, didChangeColor: self.color)
        self.reloadData()
    }

    @objc private func ms_brightnessDidChangeValue(sender: MSColorComponentView) {
        colorComponents.brightness = sender.value
        self.delegate?.colorView(colorView: self, didChangeColor: self.color)
        self.reloadData()
    }
}
