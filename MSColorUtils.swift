//
//  MSColorUtils.swift
//  EFColorPicker
//
//  Created by EyreFree on 2017/9/28.
//

import UIKit
import CoreGraphics

// The structure to represent a color in the Red-Green-Blue-Alpha color space.
struct RGB {
    var red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat

    init(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}

// The structure to represent a color in the hue-saturation-brightness color space.
struct HSB {
    var hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat

    init(_ hue: CGFloat, _ saturation: CGFloat, _ brightness: CGFloat, _ alpha: CGFloat) {
        self.hue = hue
        self.saturation = saturation
        self.brightness = brightness
        self.alpha = alpha
    }
}

// The maximum value of the RGB color components.
let MSRGBColorComponentMaxValue: CGFloat = 255.0

// The maximum value of the alpha component.
let MSAlphaComponentMaxValue: CGFloat = 100.0

// The maximum value of the HSB color components.
let MSHSBColorComponentMaxValue: CGFloat = 1.0

// Converts an RGB color value to HSV.
// Assumes r, g, and b are contained in the set [0, 1] and
// returns h, s, and b in the set [0, 1].
// @param rgb   The rgb color values
// @return The hsb color values
func MSRGB2HSB(rgb: RGB) -> HSB {
    let rd = Double(rgb.red)
    let gd = Double(rgb.green)
    let bd = Double(rgb.blue)
    let max = fmax (rd, fmax(gd, bd))
    let min = fmin(rd, fmin(gd, bd))
    var h = 0.0, b = max

    let d = max - min

    let s = max == 0 ? 0 : d / max

    if max == min {
        h = 0 // achromatic
    } else {
        if max == rd {
            h = (gd - bd) / d + (gd < bd ? 6 : 0)
        } else if max == gd {
            h = (bd - rd) / d + 2
        } else if max == bd {
            h = (rd - gd) / d + 4
        }

        h /= 6
    }

    return HSB(CGFloat(h), CGFloat(s), CGFloat(b), CGFloat(rgb.alpha))
}

// Converts an HSB color value to RGB.
// Assumes h, s, and b are contained in the set [0, 1] and
// returns r, g, and b in the set [0, 255].
// @param outRGB   The rgb color values
// @return The hsb color values
func MSHSB2RGB(hsb: HSB) -> RGB {
    var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0

    let i: Int = Int(hsb.hue * 6)
    let f = hsb.hue * 6 - CGFloat(i)
    let p = hsb.brightness * (1 - hsb.saturation)
    let q = hsb.brightness * (1 - f * hsb.saturation)
    let t = hsb.brightness * (1 - (1 - f) * hsb.saturation)

    switch i % 6 {
    case 0:
        r = hsb.brightness
        g = t
        b = p
        break
    case 1:
        r = q
        g = hsb.brightness
        b = p
        break
    case 2:
        r = p
        g = hsb.brightness
        b = t
        break
    case 3:
        r = p
        g = q
        b = hsb.brightness
        break
    case 4:
        r = t
        g = p
        b = hsb.brightness
        break
    case 5:
        r = hsb.brightness
        g = p
        b = q
        break
    default:
        break
    }
    return RGB(r, g, b, hsb.alpha)
}

// Returns the rgb values of the color components.
// @param color The color value.
// @return The values of the color components (including alpha).
func MSRGBColorComponents(color: UIColor) -> RGB {
    var result = RGB(1, 1, 1, 1)
    guard let colorSpaceModel: CGColorSpaceModel = color.cgColor.colorSpace?.model else {
        return result
    }

    if (CGColorSpaceModel.rgb != colorSpaceModel && CGColorSpaceModel.monochrome != colorSpaceModel) {
        return result
    }

    guard let components = color.cgColor.components else {
        return result
    }

    if CGColorSpaceModel.monochrome == colorSpaceModel {
        result.red = components[0]
        result.green = components[0]
        result.blue = components[0]
        result.alpha = components[1]
    } else {
        result.red = components[0]
        result.green = components[1]
        result.blue = components[2]
        result.alpha = components[3]
    }

    return result
}

// Converts hex string to the UIColor representation.
// @param color The color value.
// @return The hex string color value.
func MSHexStringFromColor(color: UIColor) -> String? {
    guard let colorSpaceModel: CGColorSpaceModel = color.cgColor.colorSpace?.model else {
        return nil
    }

    if (CGColorSpaceModel.rgb != colorSpaceModel && CGColorSpaceModel.monochrome != colorSpaceModel) {
        return nil
    }

    guard let components = color.cgColor.components else {
        return nil
    }
    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0

    if CGColorSpaceModel.monochrome == colorSpaceModel {
        red = components[0]
        green = components[0]
        blue = components[0]
        alpha = components[1]
    } else {
        red = components[0]
        green = components[1]
        blue = components[2]
        alpha = components[3]
    }

    return String(
        format: "#%02lX%02lX%02lX%02lX",
        UInt64(red * MSRGBColorComponentMaxValue),
        UInt64(green * MSRGBColorComponentMaxValue),
        UInt64(blue * MSRGBColorComponentMaxValue),
        UInt64(alpha * MSRGBColorComponentMaxValue)
    )
}

// Converts UIColor value to the hex string.
// @param hexString The hex string color value.
// @return The color value.
func MSColorFromHexString(hexColor: String) -> UIColor? {
    if !hexColor.hasPrefix("#") {
        return nil
    }

    let scanner = Scanner(string: hexColor)
    scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")

    var hexNum: UInt32 = 0
    if !scanner.scanHexInt32(&hexNum) {
        return nil
    }

    let r: CGFloat = CGFloat((hexNum >> 24) & 0xFF)
    let g: CGFloat = CGFloat((hexNum >> 16) & 0xFF)
    let b: CGFloat = CGFloat((hexNum >> 8) & 0xFF)
    let a: CGFloat = CGFloat((hexNum) & 0xFF)

    return UIColor(
        red: r / MSRGBColorComponentMaxValue,
        green: g / MSRGBColorComponentMaxValue,
        blue: b / MSRGBColorComponentMaxValue,
        alpha: a / MSRGBColorComponentMaxValue
    )
}
