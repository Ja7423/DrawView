//
//  ViewController.swift
//  CustomView
//
//  Created by 何家瑋 on 2017/4/8.
//  Copyright © 2017年 何家瑋. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CustomDrawViewDelegate {
        
        private var customDrawView : CustomDrawView?
        {
                didSet {
                        let panGestrue = UIPanGestureRecognizer(target: customDrawView, action: #selector(customDrawView!.detectPanGestrue(panGesture:)))
                        customDrawView?.addGestureRecognizer(panGestrue)
                }
        }

        private var drawToolBar = UIToolbar()
        private var totalPath = [DrawPath]()
        
        // settingView
        private var settingView = UIView()
        private var previewLineColor  = UIView()
        private var drawWidthLabel = UILabel()
        private var redSliderValue : Float = 0.0
        private var greenSliderValue : Float = 0.0
        private var blueSliderValue : Float = 0.0
        private var isShowingSettingView = false
        
        // draw mode toolbar
        private var toolBar = UIToolbar()
        private var isShowingDrawToolBar = false
        private var didSelectDrawButton : UIBarButtonItem?
        {
                willSet {
                        newValue?.isEnabled = false
                }
                
                didSet {
                        oldValue?.isEnabled = true
                }
        }
        
        override func viewDidLoad() {
                super.viewDidLoad()
                // Do any additional setup after loading the view, typically from a nib.
                
                configureDrawView()
                configureNavigationBar()
                configureToolBar()
                configureDrawToolBar()
                configureSettingView()
        }

        override func didReceiveMemoryWarning() {
                super.didReceiveMemoryWarning()
                // Dispose of any resources that can be recreated.
        }
        
        //MARK:
        //MARK: init
        private func drawViewFrame() -> CGRect
        {
                return self.view.frame
        }
        
        private func configureDrawView()
        {
                customDrawView = CustomDrawView(frame: drawViewFrame())
                
                if customDrawView != nil
                {
                        customDrawView!.delegate = self
                        self.view.addSubview(customDrawView!)
                }
        }
        
        private func configureNavigationBar()
        {
                let undoBarButtonItem = UIBarButtonItem(barButtonSystemItem: .undo, target: self, action: #selector(self.didClickButton(_:)))
                undoBarButtonItem.tag = buttonType.undo.rawValue
                self.navigationItem.leftBarButtonItems = [undoBarButtonItem]
                
                let actionBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.didClickActionButton(_:)))
                self.navigationItem.rightBarButtonItems = [actionBarButtonItem]
        }
        
        private func configureToolBar()
        {
                let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
                
                let selectDrawToolBarButtonItem = UIBarButtonItem(title: "tool", style: .done, target: self, action: #selector(self.didClickButton(_:)))
                selectDrawToolBarButtonItem.tag = buttonType.selectTool.rawValue
                
                let settingBarButtonItem = UIBarButtonItem(title: "setting", style: .done, target: self, action: #selector(self.didClickButton(_:)))
                settingBarButtonItem.tag = buttonType.setting.rawValue
                
                let resetBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.didClickButton(_:)))
                resetBarButtonItem.tag = buttonType.trash.rawValue
                
                toolBar.frame = CGRect(x: 0, y: drawViewFrame().height - 64, width: drawViewFrame().width, height: 64)
                toolBar.items = [selectDrawToolBarButtonItem, flexibleSpace, settingBarButtonItem, flexibleSpace, resetBarButtonItem]
                self.view.addSubview(toolBar)
        }
        
        private func configureDrawToolBar()
        {
                let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
                
                let pencilBarButtonItem = UIBarButtonItem(title: "✐", style: .done, target: self, action: #selector(self.setDrawMode(_:)))
                pencilBarButtonItem.tag = drawMode.line.rawValue
                didSelectDrawButton = pencilBarButtonItem
                
                let circleBarButtonItem = UIBarButtonItem(title: "◯", style: .done, target: self, action: #selector(self.setDrawMode(_:)))
                circleBarButtonItem.tag = drawMode.circle.rawValue
                
                let rectAngleBarButtonItem = UIBarButtonItem(title: "☐", style: .done, target: self, action: #selector(self.setDrawMode(_:)))
                rectAngleBarButtonItem.tag = drawMode.rectAngle.rawValue
                
                drawToolBar.frame = CGRect(x: 0, y: drawViewFrame().height - 128, width: drawViewFrame().width, height: 64)
                drawToolBar.items = [pencilBarButtonItem, flexibleSpace, circleBarButtonItem, flexibleSpace, rectAngleBarButtonItem]
        }
        
        private func configureSettingView()
        {
                settingView.frame = CGRect(x: 0, y: drawViewFrame().height - 364, width: drawViewFrame().width, height: 300)
                settingView.backgroundColor = UIColor.lightGray
                
                let redSlider = UISlider(frame: CGRect(x: 5, y: 0, width: settingView.frame.width - 5, height: settingView.frame.height / 4))
                redSlider.thumbTintColor = UIColor.red
                redSlider.minimumTrackTintColor = UIColor.red
                redSlider.maximumValue = 255.0
                redSlider.minimumValue = 0.0
                redSlider.value = 0.0
                redSlider.tag = sliderTag.red.rawValue
                redSlider.addTarget(self, action: #selector(sliderValueChange(_:)), for: .valueChanged)
                settingView.addSubview(redSlider)
                
                let greenSlider = UISlider(frame: CGRect(x: 5, y: settingView.frame.height / 4, width: settingView.frame.width - 5, height: settingView.frame.height / 4))
                greenSlider.thumbTintColor = UIColor.green
                greenSlider.minimumTrackTintColor = UIColor.green
                greenSlider.maximumValue = 255.0
                greenSlider.minimumValue = 0.0
                greenSlider.value = 0.0
                greenSlider.tag = sliderTag.green.rawValue
                greenSlider.addTarget(self, action: #selector(sliderValueChange(_:)), for: .valueChanged)
                settingView.addSubview(greenSlider)
                
                let blueSlider = UISlider(frame: CGRect(x: 5, y: settingView.frame.height / 4 * 2, width: settingView.frame.width - 5, height: settingView.frame.height / 4))
                blueSlider.thumbTintColor = UIColor.blue
                blueSlider.minimumTrackTintColor = UIColor.blue
                blueSlider.maximumValue = 255.0
                blueSlider.minimumValue = 0.0
                blueSlider.value = 0.0
                blueSlider.tag = sliderTag.blue.rawValue
                blueSlider.addTarget(self, action: #selector(sliderValueChange(_:)), for: .valueChanged)
                settingView.addSubview(blueSlider)
                
                let drawWidthSlider = UISlider(frame: CGRect(x: 5, y: settingView.frame.height / 4 * 3, width: drawViewFrame().width / 2, height: 30))
                drawWidthSlider.maximumValue = 25.0
                drawWidthSlider.minimumValue = 0.0
                drawWidthSlider.value = 5.0
                drawWidthSlider.tag = sliderTag.width.rawValue
                drawWidthSlider.addTarget(self, action: #selector(sliderValueChange(_:)), for: .valueChanged)
                settingView.addSubview(drawWidthSlider)
                
                drawWidthLabel.frame = CGRect(x: drawViewFrame().width / 2 + 20, y: settingView.frame.height / 4 * 3, width: 50, height: 30)
                drawWidthLabel.text = String(Int(drawWidthSlider.value))
                settingView.addSubview(drawWidthLabel)
                
                previewLineColor.frame = CGRect(x: drawViewFrame().width - settingView.frame.height / 4, y: settingView.frame.height / 4 * 3 - 10, width: settingView.frame.height / 4, height: settingView.frame.height / 4)
                previewLineColor.backgroundColor = UIColor.black
                settingView.addSubview(previewLineColor)
        }
        
        //MARK:
        // MARK: CustomDrawViewDelegate
        func getTotalPath(customDrawView : CustomDrawView) -> ([DrawPath])
        {
                return totalPath
        }
        
        func addPathRecord(customDrawView : CustomDrawView, moveRecord : DrawPath)
        {
                totalPath.append(moveRecord)
        }
        
        func updatePathRecordWhenMoving(customDrawView : CustomDrawView, eachMovingPoint : [AnyObject])
        {
                let drawPath = totalPath.last
                drawPath?.moveRecord = eachMovingPoint
        }
        
        //MARK:
        //MARK: slider action
        func sliderValueChange(_ sender : UISlider)
        {
                switch sender.tag {
                case sliderTag.red.rawValue:
                        redSliderValue = sender.value/255.0
                case sliderTag.green.rawValue:
                        greenSliderValue = sender.value/255.0
                case sliderTag.blue.rawValue:
                        blueSliderValue = sender.value/255.0
                case sliderTag.width.rawValue:
                        customDrawView?.drawWidth = CGFloat(sender.value)
                        drawWidthLabel.text = String(Int(sender.value))
                default: break
                }
                
                let color = UIColor(colorLiteralRed: redSliderValue, green: greenSliderValue, blue: blueSliderValue, alpha: 1.0)
                customDrawView?.lineColor = color
                
                // update preview color
                previewLineColor.backgroundColor = color
        }
        
        //MARK:
        //MARK: button action
        func didClickButton(_ sender : UIButton)
        {
                switch sender.tag {
                case buttonType.undo.rawValue:
                        if totalPath.count == 0 { return }
                        totalPath.removeLast()
                        customDrawView?.setNeedsDisplay()
                case buttonType.trash.rawValue:
                        totalPath.removeAll()
                        customDrawView?.setNeedsDisplay()
                case buttonType.selectTool.rawValue:
                        isShowingDrawToolBar = !isShowingDrawToolBar
                        showSubview(subView: drawToolBar, show: isShowingDrawToolBar)
                case buttonType.setting.rawValue:
                        isShowingSettingView = !isShowingSettingView
                        showSubview(subView: settingView, show: isShowingSettingView)
                default: break
                }
        }
        
        func didClickActionButton(_ sender : UIButton)
        {
                if let image = customDrawView?.currentImage()
                {
                        let items = [image]
                        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
                        DispatchQueue.main.async {
                                self.present(activityVC, animated: true, completion: nil)
                        }
                }
        }
        
        func setDrawMode(_ sender : UIBarButtonItem)
        {
                customDrawView?.currentDrawMode = drawMode(rawValue: sender.tag)!
                didSelectDrawButton = sender
        }
        
        //MARK:
        //MARK: Show view
        func showDrawTool(show : Bool)
        {
                if show
                {
                        self.view.addSubview(drawToolBar)
                }
                else
                {
                        drawToolBar.removeFromSuperview()
                }
        }
        
        func showSubview(subView : UIView, show : Bool)
        {
                if show
                {
                        self.view.addSubview(subView)
                }
                else
                {
                        subView.removeFromSuperview()
                }
        }
}

