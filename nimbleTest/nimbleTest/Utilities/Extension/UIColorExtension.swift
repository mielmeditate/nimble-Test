//
//  UIColorExtension.swift
//  nimbleTest
//
//  Created by Miel on 3/25/2560 BE.
//  Copyright © 2560 Lumos. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
    static func mainBackground() -> UIColor {
        return UIColor(netHex: 0x00B8A9)
    }
    
    static func textAndIcon() -> UIColor {
        return UIColor(netHex: 0xF8F3D4)
    }
    
    static func losingBackground() -> UIColor {
        return UIColor(netHex: 0xF6416C)
    }
    
    static func timer() -> UIColor {
        return UIColor(netHex: 0xFFDE7D)
    }
    
    static func randomColor() -> UIColor? {
        let randomRed: CGFloat = CGFloat(drand48())
        let randomGreen: CGFloat = CGFloat(drand48())
        let randomBlue: CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
}
