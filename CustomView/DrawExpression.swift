//
//  DrawExpression.swift
//  CustomView
//
//  Created by 何家瑋 on 2017/4/23.
//  Copyright © 2017年 何家瑋. All rights reserved.
//

import Foundation
import UIKit

class DrawPath {
        var lineColor = UIColor.clear
        var drawWidth : CGFloat = 5.0
        var moveRecord = [AnyObject]()
}

enum drawMode : Int {
        case line
        case circle
        case rectAngle
}

enum buttonType : Int {
        case undo
        case trash
        case selectTool
        case setting
}

enum sliderTag : Int {
        case red
        case green
        case blue
        case width
}
