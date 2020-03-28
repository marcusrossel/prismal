//
//  Extensions.swift
//  Prismal
//
//  Created by Marcus Rossel on 13.11.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

extension CGRect {
    
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
    
    init(center: CGPoint, size: CGSize) {
        let origin = CGPoint(
            x: center.x - size.width / 2,
            y: center.y - size.height / 2
        )
        
        self.init(origin: origin, size: size)
    }
}

extension UIColor {
    
    static var random: UIColor {
        // Generates four random numbers between 0 and 1.
        let components = (1...4).map { _ in CGFloat.random(in: 0...1) }
        
        return UIColor(
            hue:        components[0],
            saturation: components[1],
            brightness: components[2],
            alpha:      components[3]
        )
    }
    
    /// Returns an array containing the color's HSBA-component values:
    /// `[*hue*, *saturation*, *brightness*, *alpha*]`.
    var hsbaComponents: [CGFloat] {
        var hue: CGFloat = .nan
        var saturation: CGFloat = .nan
        var brightness: CGFloat = .nan
        var alpha: CGFloat = .nan
        
        getHue(        &hue,
                       saturation: &saturation,
                       brightness: &brightness,
                       alpha:      &alpha
        )
        
        return [hue, saturation, brightness, alpha]
    }
}
