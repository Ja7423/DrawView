//
//  CustomDrawView.swift
//  CustomView
//
//  Created by 何家瑋 on 2017/4/10.
//  Copyright © 2017年 何家瑋. All rights reserved.
//

import UIKit
import CoreGraphics

protocol CustomDrawViewDelegate {
        
        func getTotalPath(customDrawView : CustomDrawView) -> ([DrawPath])
        func addPathRecord(customDrawView : CustomDrawView, moveRecord : DrawPath)
        func updatePathRecordWhenMoving(customDrawView : CustomDrawView, eachMovingPoint : [AnyObject])
}

class CustomDrawView: UIView {
        
        var lineColor = UIColor.black
        var drawWidth : CGFloat = 5.0
        var delegate : CustomDrawViewDelegate?
        var currentDrawMode = drawMode.line
        
        private var lastTouchPoint : CGPoint = CGPoint(x: 0.0, y: 0.0)
        private var drawImageView : UIImageView = UIImageView()
        private var eachMoveRecord : [AnyObject]?
        
        //MARK:
        //MARK: init
        override init(frame: CGRect)
        {
                super.init(frame: frame)
                drawImageView.frame = frame
                drawImageView.backgroundColor = UIColor.white
                self.frame = frame
                self.addSubview(drawImageView)
        }
        
        required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }

        
        //MARK:
        //MARK: public
        func currentImage() -> UIImage? {
                
                if drawImageView.image != nil
                {
                        return drawImageView.image
                }
                
                return nil
        }
        
        //MARK:
        // MARK: touch event
        func detectPanGestrue(panGesture : UIPanGestureRecognizer)
        {
                let touchPoint = panGesture.location(in: panGesture.view)
                
                switch panGesture.state {
                case .began:
                        lastTouchPoint = touchPoint
                        
                        if eachMoveRecord == nil
                        {
                                eachMoveRecord = [AnyObject]()
                        }
                        
                        switch currentDrawMode {
                        case .line:
                                eachMoveRecord?.append(lastTouchPoint as AnyObject)  // add first touch point
                        default: break
                        }
                        
                        // append new array
                        let drawPath = DrawPath()
                        drawPath.lineColor = lineColor
                        drawPath.drawWidth = drawWidth
                        drawPath.moveRecord = eachMoveRecord!
                        delegate?.addPathRecord(customDrawView: self, moveRecord: drawPath)
                        
                case .changed:
                        switch currentDrawMode {
                        case .line:
                                lastTouchPoint = touchPoint
                                eachMoveRecord?.append(lastTouchPoint as AnyObject)
                        case .circle:
                                // circle only record last path
                                let path = pathForDrawCircle(start: lastTouchPoint, toPoint: touchPoint)
                                eachMoveRecord?.removeAll()
                                eachMoveRecord?.append(path)
                        case .rectAngle:
                                // rectangle only record last path
                                let path = pathForRectAngle(start: lastTouchPoint, toPoint: touchPoint)
                                eachMoveRecord?.removeAll()
                                eachMoveRecord?.append(path)
                        }
                        
                        if eachMoveRecord != nil
                        {
                                delegate?.updatePathRecordWhenMoving(customDrawView: self, eachMovingPoint: eachMoveRecord!)
                        }
                        
                        setNeedsDisplay()  // update view
                case .ended:
                        eachMoveRecord = nil
                default: break
                }
        }
        
        //MARK:
        //MARK: draw
        override func draw(_ rect: CGRect) {
                // Drawing code
                var isFirstPoint  = true
                var previousPoint : CGPoint?
                var totalPath = [DrawPath]()
                
                totalPath = (delegate?.getTotalPath(customDrawView: self)) ?? [DrawPath]()
                
                UIGraphicsBeginImageContext(drawImageView.frame.size)
                for drawPath in totalPath
                {
                        lineColor = drawPath.lineColor
                        lineColor.set()
                        drawWidth = drawPath.drawWidth
                        
                        if let points = drawPath.moveRecord as? [CGPoint]
                        {
                                for point in points
                                {
                                        if isFirstPoint
                                        {
                                                isFirstPoint = false
                                        }
                                        else
                                        {
                                                pathForDrawLine(move: previousPoint!, toPoint: point).stroke()
                                        }
                                        
                                        previousPoint = point
                                }
                                
                                isFirstPoint = true
                        }
                        else if let paths = drawPath.moveRecord as? [UIBezierPath]
                        {
                                for path in paths
                                {
                                        path.stroke()
                                }
                                
                        }
                }
                
                drawImageView.image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
        }
        
        private func pathForDrawLine(move fromPoint : CGPoint, toPoint : CGPoint) ->UIBezierPath
        {
                let path = UIBezierPath()
                path.move(to: fromPoint)
                path.addLine(to: toPoint)
                path.lineWidth = drawWidth
                
                return path
        }
        
        private func pathForDrawCircle(start firstTouchPoint : CGPoint, toPoint : CGPoint) ->UIBezierPath
        {
                let path = UIBezierPath()
                let dx = toPoint.x - firstTouchPoint.x
                let dy = toPoint.y - firstTouchPoint.y
                let distance = sqrtf(Float(dx * dx + dy * dy))
                
                path.addArc(withCenter: firstTouchPoint, radius: CGFloat(distance), startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
                path.lineWidth = drawWidth
                
                return path
        }
        
        private func pathForRectAngle(start firstTouchPoint : CGPoint, toPoint : CGPoint) ->UIBezierPath
        {
                let width = toPoint.x - firstTouchPoint.x
                let height = toPoint.y - firstTouchPoint.y
                let path = UIBezierPath(rect: CGRect(x: firstTouchPoint.x, y: firstTouchPoint.y, width: width, height: height))
                path.lineWidth = drawWidth
                
                return path
        }
        
}
