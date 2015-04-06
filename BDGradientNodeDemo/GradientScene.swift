//
//  GradientScene.swift
//  BDGradientNodeDemo
//
//  Created by Braindrizzle Studio.
//  http://braindrizzlestudio.com
//  Copyright (c) 2015 Braindrizzle Studio. All rights reserved.
//
//  This application is a demo of BDGradientNode.
//


import SpriteKit

class GradientScene : SKScene {
    
    
    // MARK: - Properties
    
    
    // The pretty Apple blue for text/strokes
    var blue = UIColor(red: 0.0, green: 122/255, blue: 1.0, alpha: 1.0)
    
    
    // The colors to pass to the BDGradientNode. Recompilation is required when colors are changed (except for gamut, which is always the gamut).
    var colors = [UIColor]() {
        didSet {
            if gradientNode.gradientType != "gamut" { resetCurrentNode() }
        }
    }
    
    // The currently displayed texture
    var currentTexture = SKTexture(imageNamed: "Spaceship")
    
    // Our BDGradientNode
    var gradientNode : BDGradientNode! = BDGradientNode()
    
    // The size of the BDGradientNode
    var nodeSize = CGSizeZero
    
    
    // The current number of colors. Changes the label when changed.
    var numberOfColors = 6 {
        didSet {
            (view?.viewWithTag(99) as! UILabel).text = "\(numberOfColors)"
        }
    }
    
    
    
    // MARK: - ViewController
    
    
    override func didMoveToView(view: SKView) {
        
        backgroundColor = UIColor.whiteColor()
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            nodeSize = CGSize(width: self.size.width * 2 / 3, height: self.size.width * 2 / 3)
        } else {
            nodeSize = CGSize(width: self.size.width - 10, height: self.size.width - 10)
        }
        
        colorsButtonPressed()
        
        setupUI()
        
        gamutGradientButtonPressed()
    }
    
    
    func setupUI () {
        
        setupButtons()
        setupLabels()
        setupSliders()
    }
    
    
    
    // MARK: - Buttons and Labels
    
    
    func setupButtons () {
        
        // Animation
        setupAnimationButton()
        
        // Colors
        setupColorsButton()
        setupNumberOfColorsButtons()
        
        // Gradients
        setupGamutGradientButton()
        setupLinearGradientButton()
        setupRadialGradientButton()
        setupSweepGradientButton()
        
        // Locations
        setupLocationsButton()
        
        // Options
        setupBlendedButton()
        setupKeepShapeButton()
    }
    
    
    
    // MARK: Animation
    
    
    func setupAnimationButton () {
        
        let origin = convertPointToView(CGPoint(x: self.size.width * 15 / 21, y: self.size.height - self.size.width * 0.2 / 21))
        let size = CGSize(width: self.size.width * 5 / 21, height: self.size.height * 1 / 21)
        let frame = CGRect(origin: origin, size: size)
        let button = setupButton(frame: frame, title: "Animate: No", action: "animateButtonPressed")
        button.tag = 30
    }
    
    
    
    // MARK: Colors
    
    
    func setupColorsButton () {
        
        let origin = convertPointToView(CGPoint(x: self.size.width * 1 / 21, y: self.size.height - nodeSize.height * 12.5 / 10))
        let size = CGSize(width: self.size.width * 4 / 21, height: self.size.height * 1 / 21)
        let frame = CGRect(origin: origin, size: size)
        let button = setupButton(frame: frame, title: "Colors", action: "colorsButtonPressed")
        button.tag = 96
    }
    
    
    func setupNumberOfColorsButtons () {
        
        // Minus
        
        let minusorigin = convertPointToView(CGPoint(x: self.size.width * 1 / 21, y: self.size.height - nodeSize.height * 13.5 / 10))
        let MinusSize = CGSize(width: self.size.height * 1 / 21, height: self.size.height * 1 / 21)
        let MinusFrame = CGRect(origin: minusorigin, size: MinusSize)
        let minusButton = setupButton(frame: MinusFrame, title: "-", action: "minusColorsButtonPressed")
        minusButton.tag = 98
        
        // Number of Colors Label
        let numberOrigin = convertPointToView(CGPoint(x: self.size.width * 4.5 / 21, y: self.size.height - nodeSize.height * 13.5 / 10))
        let numberSize = CGSize(width: self.size.height * 1 / 21, height: self.size.height * 1 / 21)
        let numberFrame = CGRect(origin: numberOrigin, size: numberSize)
        let numberOfButtonLabel = setupLabel(frame: numberFrame, text: "\(numberOfColors)")
        numberOfButtonLabel.tag = 99
        
        // Plus
        let plusOrigin = convertPointToView(CGPoint(x: self.size.width * 8 / 21, y: self.size.height - nodeSize.height * 13.5 / 10))
        let plusSize = CGSize(width: self.size.height * 1 / 21, height: self.size.height * 1 / 21)
        let plusFrame = CGRect(origin: plusOrigin, size: plusSize)
        let plusButton = setupButton(frame: plusFrame, title: "+", action: "plusColorsButtonPressed")
        plusButton.tag = 97
    }
    
    
    
    // MARK: Gradients
    
    
    func setupGamutGradientButton () {
        
        let origin = convertPointToView(CGPoint(x: self.size.width * 1 / 21, y: self.size.height - nodeSize.height * 11.5 / 10))
        let size = CGSize(width: self.size.width * 4 / 21, height: self.size.height * 1 / 21)
        let frame = CGRect(origin: origin, size: size)
        setupButton(frame: frame, title: "Gamut", action: "gamutGradientButtonPressed")
    }
    
    
    func setupLinearGradientButton () {
        
        let origin = convertPointToView(CGPoint(x: self.size.width * 6 / 21, y: self.size.height - nodeSize.height * 11.5 / 10))
        let size = CGSize(width: self.size.width * 4 / 21, height: self.size.height * 1 / 21)
        let frame = CGRect(origin: origin, size: size)
        setupButton(frame: frame, title: "Linear", action: "linearGradientButtonPressed")
    }
    
    
    func setupRadialGradientButton () {
        
        let origin = convertPointToView(CGPoint(x: self.size.width * 11 / 21, y: self.size.height - nodeSize.height * 11.5 / 10))
        let size = CGSize(width: self.size.width * 4 / 21, height: self.size.height * 1 / 21)
        let frame = CGRect(origin: origin, size: size)
        setupButton(frame: frame, title: "Radial", action: "radialGradientButtonPressed")
    }
    
    
    func setupSweepGradientButton () {
        
        let origin = convertPointToView(CGPoint(x: self.size.width * 16 / 21, y: self.size.height - nodeSize.height * 11.5 / 10))
        let size = CGSize(width: self.size.width * 4 / 21, height: self.size.height * 1 / 21)
        let frame = CGRect(origin: origin, size: size)
        setupButton(frame: frame, title: "Sweep", action: "sweepGradientButtonPressed")
    }
    
    
    
    // MARK: Locations
    
    var locationsButtonStatus = "default"
    func setupLocationsButton () {
        
        let origin = convertPointToView(CGPoint(x: self.size.width * 6 / 21, y: self.size.height - nodeSize.height * 12.5 / 10))
        let size = CGSize(width: self.size.width * 4 / 21, height: self.size.height * 1 / 21)
        let frame = CGRect(origin: origin, size: size)
        let button = setupButton(frame: frame, title: "Locations", action: "locationsButtonPressed")
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.tag = 93
    }
    
    
    
    // MARK: Options
    
    
    func setupBlendedButton () {
        
        let origin = convertPointToView(CGPoint(x: self.size.width * 11 / 21, y: self.size.height - nodeSize.height * 12.5 / 10))
        let size = CGSize(width: self.size.width * 9 / 21, height: self.size.height * 1 / 21)
        let frame = CGRect(origin: origin, size: size)
        let button = setupButton(frame: frame, title: "Blend Colors: Yes", action: "blendColorsButtonPressed")
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.tag = 95
    }
    
    
    func setupKeepShapeButton () {
        
        let origin = convertPointToView(CGPoint(x: self.size.width * 11 / 21, y: self.size.height - nodeSize.height * 13.5 / 10))
        let size = CGSize(width: self.size.width * 9 / 21, height: self.size.height * 1 / 21)
        let frame = CGRect(origin: origin, size: size)
        let button = setupButton(frame: frame, title: "Keep Shape: Yes", action: "keepShapeButtonPressed")
        button.tag = 94
        disableButtonForTag(94)
        
        let subOrigin = convertPointToView(CGPoint(x: self.size.width * 11 / 21, y: self.size.height - nodeSize.height * 14.5 / 10))
        let subSize = CGSize(width: self.size.width * 9 / 21, height: self.size.height * 0.5 / 21)
        let subFrame = CGRect(origin: subOrigin, size: subSize)
        let label = UILabel(frame: subFrame)
        label.text = "'Keep Shape' is ignored if 'Blend Colors' is true."
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .Center
        label.numberOfLines = 0
        view?.addSubview(label)
    }
    
    
    
    // MARK: Labels
    
    
    func setupLabels() {
        
        setupCenterLabel()
        setupCentersDragLabel()
        setupLinkLabel()
        setupStartEndDragLabel()
    }
    
    
    func setupCenterLabel () {
        
        let origin = convertPointToView(CGPoint(x: self.size.width * 1 / 21, y: self.size.height - nodeSize.height * 17 / 10))
        let size = CGSize(width: self.size.width * 9 / 21, height: self.size.height * 1 / 21)
        let frame = CGRect(origin: origin, size: size)
        let label = UILabel(frame: frame)
        label.text = "Drag the image \rto move the center!"
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .Center
        label.textColor = blue
        label.numberOfLines = 0
        label.tag = 20
        view?.addSubview(label)
    }
    
    
    func setupCentersDragLabel () {
        
        let origin = convertPointToView(CGPoint(x: self.size.width * 1 / 21, y: self.size.height - nodeSize.height * 17 / 10))
        let size = CGSize(width: self.size.width * 9 / 21, height: self.size.height * 1 / 21)
        let frame = CGRect(origin: origin, size: size)
        let label = UILabel(frame: frame)
        label.text = "Drag the two circles to move their centers!"
        label.adjustsFontSizeToFitWidth = true
        label.hidden = true
        label.textAlignment = .Center
        label.textColor = blue
        label.numberOfLines = 0
        label.tag = 22
        view?.addSubview(label)
    }
    
    
    func setupLinkLabel () {
        
        let origin = convertPointToView(CGPoint(x: self.size.width * 1 / 21, y: self.size.height * 21 / 21))
        let size = CGSize(width: self.size.width * 9 / 21, height: self.size.height * 1 / 21)
        let frame = CGRect(origin: origin, size: size)
        let text = UITextView(frame: frame)
        text.editable = false
        text.dataDetectorTypes = .All
        text.text = "braindrizzlestudio.com"
        text.textAlignment = .Center
        text.textColor = blue
        text.tag = 10
        view?.addSubview(text)
        if let textView = view?.viewWithTag(10) as? UITextView {
            view?.bringSubviewToFront(textView)
        }
    }
    
    
    func setupStartEndDragLabel () {
        
        let origin = convertPointToView(CGPoint(x: self.size.width * 1 / 21, y: self.size.height - nodeSize.height * 17 / 10))
        let size = CGSize(width: self.size.width * 9 / 21, height: self.size.height * 1 / 21)
        let frame = CGRect(origin: origin, size: size)
        let label = UILabel(frame: frame)
        label.text = "Drag the top and bottom to move the start/end points!"
        label.adjustsFontSizeToFitWidth = true
        label.hidden = true
        label.textAlignment = .Center
        label.textColor = blue
        label.numberOfLines = 0
        label.tag = 21
        view?.addSubview(label)
    }
    
    
    
    // MARK: Button and Label Makers
    
    
    func setupButton (#frame: CGRect, title: String, action: Selector) -> UIButton {

        let button = UIButton(frame: frame)
        
        button.layer.cornerRadius = 8.0
        button.layer.borderWidth = 0.5
        button.layer.borderColor = blue.CGColor!
        
        button.setTitle(title, forState: .Normal)
        button.setTitleColor(blue, forState: .Normal)
        button.titleLabel!.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        
        button.titleLabel!.adjustsFontSizeToFitWidth = true
        
        button.addTarget(self, action: action, forControlEvents: .TouchUpInside)
        
        view?.addSubview(button)
        
        return button
    }
    
    
    func setupLabel (#frame: CGRect, text: String) -> UILabel {
        
        let label = UILabel(frame: frame)
        
        label.layer.cornerRadius = 8.0
        label.layer.borderWidth = 0.5
        label.layer.borderColor = blue.CGColor!
        
        label.text = text
        label.adjustsFontSizeToFitWidth = true
        label.textColor = blue
        label.textAlignment = .Center
        
        view?.addSubview(label)
        
        return label
    }
    
    
    
    // MARK: - Sliders
    
    
    func setupSliders () {
        
        setupStartAngleSlider()
        setupFirstRadiusSlider()
        setupSecondRadiusSlider()
    }
    
    
    func setupStartAngleSlider () {
        
        let origin = convertPointToView(CGPoint(x: self.size.width * 1 / 21, y: self.size.height - nodeSize.height * 15.5 / 10))
        let size = CGSize(width: self.size.width * 9 / 21, height: self.size.height * 1 / 21)
        let frame = CGRect(origin: origin, size: size)
        let slider = UISlider(frame: frame)
        slider.minimumValue = Float(0.0)
        slider.maximumValue = Float(2 * M_PI)
        slider.maximumTrackTintColor = UIColor.darkGrayColor()
        slider.value = gradientNode.startAngle
        slider.addTarget(self, action: "startAngleSliderChanged", forControlEvents: .ValueChanged)
        slider.tag = 50
        view?.addSubview(slider)
        
        let subOrigin = convertPointToView(CGPoint(x: self.size.width * 1 / 21, y: self.size.height - nodeSize.height * 15 / 10))
        let subSize = CGSize(width: self.size.width * 9 / 21, height: self.size.height * 0.5 / 21)
        let subFrame = CGRect(origin: subOrigin, size: subSize)
        let label = UILabel(frame: subFrame)
        label.text = "Start Angle"
        label.textColor = blue
        label.textAlignment = .Center
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.tag = 51
        view?.addSubview(label)
    }
    
    
    func setupFirstRadiusSlider () {
        
        let origin = convertPointToView(CGPoint(x: self.size.width * 11 / 21, y: self.size.height - nodeSize.height * 15.5 / 10))
        let size = CGSize(width: self.size.width * 9 / 21, height: self.size.height * 1 / 21)
        let frame = CGRect(origin: origin, size: size)
        let slider = UISlider(frame: frame)
        slider.minimumValue = Float(0.0)
        slider.maximumValue = Float(1.0)
        slider.maximumTrackTintColor = UIColor.darkGrayColor()
        slider.value = gradientNode.firstRadius
        slider.addTarget(self, action: "firstRadiusSliderChanged", forControlEvents: .ValueChanged)
        slider.tag = 52
        view?.addSubview(slider)
        
        let subOrigin = convertPointToView(CGPoint(x: self.size.width * 11 / 21, y: self.size.height - nodeSize.height * 15 / 10))
        let subSize = CGSize(width: self.size.width * 9 / 21, height: self.size.height * 0.5 / 21)
        let subFrame = CGRect(origin: subOrigin, size: subSize)
        let label = UILabel(frame: subFrame)
        label.text = "First Radius"
        label.textColor = blue
        label.textAlignment = .Center
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.tag = 53
        view?.addSubview(label)
    }
    
    
    func setupSecondRadiusSlider () {
        
        let origin = convertPointToView(CGPoint(x: self.size.width * 11 / 21, y: self.size.height - nodeSize.height * 17 / 10))
        let size = CGSize(width: self.size.width * 9 / 21, height: self.size.height * 1 / 21)
        let frame = CGRect(origin: origin, size: size)
        let slider = UISlider(frame: frame)
        slider.minimumValue = Float(0.0)
        slider.maximumValue = Float(1.0)
        slider.maximumTrackTintColor = UIColor.darkGrayColor()
        slider.value = gradientNode.secondRadius
        slider.addTarget(self, action: "secondRadiusSliderChanged", forControlEvents: .ValueChanged)
        slider.tag = 54
        view?.addSubview(slider)
        
        let subOrigin = convertPointToView(CGPoint(x: self.size.width * 11 / 21, y: self.size.height - nodeSize.height * 16.5 / 10))
        let subSize = CGSize(width: self.size.width * 9 / 21, height: self.size.height * 0.5 / 21)
        let subFrame = CGRect(origin: subOrigin, size: subSize)
        let label = UILabel(frame: subFrame)
        label.text = "Second Radius"
        label.textColor = blue
        label.textAlignment = .Center
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.tag = 55
        view?.addSubview(label)
    }
    
    
    
    // MARK: - Actions
    
    
    // MARK: Animation
    
    
    func animateButtonPressed () {

        if let animateButton = view?.viewWithTag(30) as? UIButton {
            
            switch animateButton.titleLabel!.text! {
                
                case "Animate: Yes":
                    animateButton.setTitle("Animate: No", forState: .Normal)
                    gradientNode.removeAllActions()

                case "Animate: No":
                    animateButton.setTitle("Animate: Yes", forState: .Normal)
                    
                    switch gradientNode.gradientType {
                        case "gamut": gamutAnimation()
                        case "linear": linearAnimation()
                        case "radial": radialAnimation()
                        case "sweep": sweepAnimation()
                        default: return
                    }
                default: return
            }
    
            
        }
    }
    
    
    func gamutAnimation () {
        
        
        self.gradientNode.center.x += 0.001
        self.gradientNode.center.y += 0.001
        
        let angleAction = SKAction.runBlock {
            
            self.gradientNode.startAngle = (self.gradientNode.startAngle + 0.1) % Float(2 * M_PI)
            if let slider = self.view?.viewWithTag(50) as? UISlider {
                slider.value = self.gradientNode.startAngle
            }
        }
        
        let centerAction = SKAction.runBlock {
            
            let angle : CGFloat = 0.03
            self.gradientNode.center = self.rotatePoint(self.gradientNode.center, byAngle: angle)
            
            let multiplier = CGFloat(sin(self.gradientNode.startAngle) / 100)
            var normalizedPoint = self.gradientNode.center
            normalizedPoint.x -= 0.5
            normalizedPoint.y -= 0.5
            let length = sqrt(pow(normalizedPoint.x, 2) + pow(normalizedPoint.y, 2))
            normalizedPoint.x /= length
            normalizedPoint.y /= length
            
            self.gradientNode.center.x += multiplier * normalizedPoint.x
            self.gradientNode.center.y -= multiplier * normalizedPoint.y
        }
        
        let radiusAction = SKAction.runBlock {
            
            let change = Float(sin(self.angleOfPoint(self.gradientNode.center))) / 100
            self.gradientNode.radius += change
            if let slider = self.view?.viewWithTag(52) as? UISlider {
                slider.value = self.gradientNode.radius
            }
        }
        
        let delayAction = SKAction.waitForDuration(0.05)
        
        let actionGroup = SKAction.group([angleAction, centerAction, radiusAction, delayAction])
        
        gradientNode.runAction(SKAction.repeatActionForever(actionGroup))
    }
    
    
    func linearAnimation () {
        
        let startAction = SKAction.runBlock {
            
            let angle : CGFloat = 0.03
            self.gradientNode.startPoint = self.rotatePoint(self.gradientNode.startPoint, byAngle: angle)
            
            let multiplier = sin(self.angleOfPoint(self.gradientNode.startPoint)) / 100
            var normalizedPoint = self.gradientNode.startPoint
            normalizedPoint.x -= 0.5
            normalizedPoint.y -= 0.5
            let length = sqrt(pow(normalizedPoint.x, 2) + pow(normalizedPoint.y, 2))
            normalizedPoint.x /= length
            normalizedPoint.y /= length
            
            self.gradientNode.startPoint.x += multiplier * normalizedPoint.x
            self.gradientNode.startPoint.y += multiplier * normalizedPoint.y
        }
        
        let endAction = SKAction.runBlock {
            
            let angle : CGFloat = 0.03
            self.gradientNode.endPoint = self.rotatePoint(self.gradientNode.endPoint, byAngle: angle)
            
            let multiplier = sin(self.angleOfPoint(self.gradientNode.endPoint)) / 100
            var normalizedPoint = self.gradientNode.endPoint
            normalizedPoint.x -= 0.5
            normalizedPoint.y -= 0.5
            let length = sqrt(pow(normalizedPoint.x, 2) + pow(normalizedPoint.y, 2))
            normalizedPoint.x /= length
            normalizedPoint.y /= length
            
            self.gradientNode.endPoint.x -= multiplier * normalizedPoint.x
            self.gradientNode.endPoint.y -= multiplier * normalizedPoint.y
        }
        
        let delayAction = SKAction.waitForDuration(0.05)
        
        let actionGroup = SKAction.group([startAction, endAction, delayAction])
        
        gradientNode.runAction(SKAction.repeatActionForever(actionGroup))
    }
    
    
    func radialAnimation () {
        
        self.gradientNode.firstCenter.x += 0.001
        self.gradientNode.firstCenter.y += 0.001
        self.gradientNode.secondCenter.x -= 0.001
        self.gradientNode.secondCenter.y -= 0.001
        
        let firstCenterAction = SKAction.runBlock {
            
            let angle : CGFloat = 0.03
            self.gradientNode.firstCenter = self.rotatePoint(self.gradientNode.firstCenter, byAngle: angle)
            
            let multiplier = sin(self.angleOfPoint(self.gradientNode.firstCenter)) / 100
            var normalizedPoint = self.gradientNode.firstCenter
            normalizedPoint.x -= 0.5
            normalizedPoint.y -= 0.5
            let length = sqrt(pow(normalizedPoint.x, 2) + pow(normalizedPoint.y, 2))
            normalizedPoint.x /= length
            normalizedPoint.y /= length
            
            self.gradientNode.firstCenter.x += multiplier * normalizedPoint.x
            self.gradientNode.firstCenter.y += multiplier * normalizedPoint.y
        }
        
        let firstRadiusAction = SKAction.runBlock {
            
            let change = Float(sin(self.angleOfPoint(self.gradientNode.firstCenter))) / 100
            self.gradientNode.firstRadius = min(max(self.gradientNode.firstRadius + change, 0.0), 1.0)
            if let slider = self.view?.viewWithTag(52) as? UISlider {
                slider.value = self.gradientNode.firstRadius
            }
        }
        
        let secondCenterAction = SKAction.runBlock {
            
            let angle : CGFloat = 0.03
            self.gradientNode.secondCenter = self.rotatePoint(self.gradientNode.secondCenter, byAngle: angle)
            
            let multiplier = sin(self.angleOfPoint(self.gradientNode.secondCenter)) / 100
            var normalizedPoint = self.gradientNode.secondCenter
            normalizedPoint.x -= 0.5
            normalizedPoint.y -= 0.5
            let length = sqrt(pow(normalizedPoint.x, 2) + pow(normalizedPoint.y, 2))
            normalizedPoint.x /= length
            normalizedPoint.y /= length
            
            self.gradientNode.secondCenter.x -= multiplier * normalizedPoint.x
            self.gradientNode.secondCenter.y -= multiplier * normalizedPoint.y
        }
        
        let secondRadiusAction = SKAction.runBlock {
            
            let change = Float(sin(self.angleOfPoint(self.gradientNode.secondCenter))) / 100
            self.gradientNode.secondRadius = min(max(self.gradientNode.secondRadius + change, 0.0), 1.0)
            if let slider = self.view?.viewWithTag(54) as? UISlider {
                slider.value = self.gradientNode.secondRadius
            }
        }
        
        let delayAction = SKAction.waitForDuration(0.05)
        
        let actionGroup = SKAction.group([firstCenterAction, firstRadiusAction, secondCenterAction, secondRadiusAction, delayAction])
        
        gradientNode.runAction(SKAction.repeatActionForever(actionGroup))
    }
    
    
    func sweepAnimation () {
        
        self.gradientNode.center.x += 0.001
        self.gradientNode.center.y += 0.001
        
        let angleAction = SKAction.runBlock {
            
            self.gradientNode.startAngle = (self.gradientNode.startAngle + 0.1) % Float(2 * M_PI)
            if let slider = self.view?.viewWithTag(50) as? UISlider {
                slider.value = self.gradientNode.startAngle
            }
        }
        
        let centerAction = SKAction.runBlock {
            
            let angle : CGFloat = 0.03
            self.gradientNode.center = self.rotatePoint(self.gradientNode.center, byAngle: angle)
            
            let multiplier = CGFloat(sin(self.gradientNode.startAngle) / 100)
            var normalizedPoint = self.gradientNode.center
            normalizedPoint.x -= 0.5
            normalizedPoint.y -= 0.5
            let length = sqrt(pow(normalizedPoint.x, 2) + pow(normalizedPoint.y, 2))
            normalizedPoint.x /= length
            normalizedPoint.y /= length
            
            self.gradientNode.center.x += multiplier * normalizedPoint.x
            self.gradientNode.center.y -= multiplier * normalizedPoint.y
        }
        
        let radiusAction = SKAction.runBlock {
            
            let change = Float(sin(self.angleOfPoint(self.gradientNode.center))) / 100
            self.gradientNode.radius += change
            if let slider = self.view?.viewWithTag(52) as? UISlider {
                slider.value = self.gradientNode.radius
            }
        }
        
        let delayAction = SKAction.waitForDuration(0.05)
        
        let actionGroup = SKAction.group([angleAction, centerAction, radiusAction, delayAction])
        
        gradientNode.runAction(SKAction.repeatActionForever(actionGroup))
    }
    
    
    
    // MARK: Colors
    
    
    func colorsButtonPressed () {
        
        colors = randomColorArray(numberOfColors)
    }
    
    
    func minusColorsButtonPressed () {
        
        if numberOfColors == 2 { return }
        if numberOfColors == 3 { disableButtonForTag(98) }
        
        numberOfColors = numberOfColors - 1
        colorsButtonPressed()
    }
    
    
    func plusColorsButtonPressed () {
        
        if numberOfColors == 2 { enableButtonForTag(98) }
        
        numberOfColors = numberOfColors + 1
        colorsButtonPressed()
    }
    
    
    
    // MARK: Gradients
    
    
    func gamutGradientButtonPressed () {
        
        let currentType = gradientNode.gradientType
        switchToGradient("gamut")
        if currentType == "gamut" { return }
    }
    
    
    func linearGradientButtonPressed () {
        
        let currentType = gradientNode.gradientType
        switchToGradient("linear")
        if currentType == "linear" { return }
    }
    
    
    func radialGradientButtonPressed () {
        
        let currentType = gradientNode.gradientType
        switchToGradient("radial")
        if currentType == "radial" { return }
    }
    
    
    func sweepGradientButtonPressed () {
        
        let currentType = gradientNode.gradientType
        switchToGradient("sweep")
        if currentType == "sweep" { return }
    }
    
    
    func switchToGradient(gradient: String) {
        
        let blended = gradientNode.blended
        let center = gradientNode.center
        let endPoint = gradientNode.endPoint
        let firstCenter = gradientNode.firstCenter
        let firstRadius = gradientNode.firstRadius
        let keepShape = gradientNode.keepShape
        let radius = gradientNode.radius
        let secondCenter = gradientNode.secondCenter
        let secondRadius = gradientNode.secondRadius
        let startAngle = gradientNode.startAngle
        let startPoint = gradientNode.startPoint
        
        gradientNode.removeFromParent()
        gradientNode = nil
        
        switch gradient {
            
            case "gamut": gradientNode = BDGradientNode(gamutGradientWithTexture: currentTexture, center: center, radius: radius, startAngle: startAngle, blended: blended, keepShape: keepShape, size: nodeSize)
            case "linear": gradientNode = BDGradientNode(linearGradientWithTexture: currentTexture, colors: colors, locations: nil, startPoint: startPoint, endPoint: endPoint, blended: blended, keepShape: keepShape, size: nodeSize)
            case "radial": gradientNode = BDGradientNode(radialGradientWithTexture: currentTexture, colors: colors, locations: nil, firstCenter: firstCenter, firstRadius: firstRadius, secondCenter: secondCenter, secondRadius: secondRadius, blended: blended, keepShape: keepShape, size: nodeSize)
            case "sweep": gradientNode = BDGradientNode(sweepGradientWithTexture: currentTexture, colors: colors, locations: nil, center: center, radius: radius, startAngle: startAngle, blended: blended, keepShape: keepShape, size: nodeSize)
            default: return
        }
        
        gradientNode.position = CGPoint(x: self.size.width / 2, y: self.size.height - nodeSize.height / 2 - nodeSize.height * 1 / 10)
        addChild(gradientNode)
        adjustUIForGradient(gradient)
    }
    
    
    
    // MARK: Locations
    
    // If the gradient is using default locations, add random locations; if random, add default.
    func locationsButtonPressed () {

        if let locations = gradientNode.locations {
            
            switch locationsButtonStatus {
                
                case "default":
                
                    var newLocations = [Float]()
                    var lastLocation : Float = 0.01
                    let jump = 0.25 / Float(gradientNode.colors.count)
                    for var i = 0; i < locations.count; i++ {
                        lastLocation = Float(random(min: CGFloat(lastLocation + jump), max: min(CGFloat(lastLocation + 6.0 * jump), 0.99)))
                        newLocations.append(lastLocation)
                    }
                    gradientNode.locations = newLocations
                    locationsButtonStatus = "random"
                
                case "random":
                
                    gradientNode.locations = nil
                    locationsButtonStatus = "default"
                
                default: return
            }
        }
    }
    
    
    
    // MARK: Options
    
    
    func blendColorsButtonPressed () {

        let button = (view?.viewWithTag(95) as! UIButton)
        
        switch button.titleLabel!.text! {
            case "Blend Colors: Yes":
                button.setTitle("Blend Colors: No", forState: .Normal)
                enableButtonForTag(94)
            case "Blend Colors: No":
                button.setTitle("Blend Colors: Yes", forState: .Normal)
                disableButtonForTag(94)
            default: return
        }
        
        gradientNode.blended = !gradientNode.blended
    }
    
    
    func keepShapeButtonPressed () {
        
        let button = (view?.viewWithTag(94) as! UIButton)
        
        switch button.titleLabel!.text! {
        case "Keep Shape: Yes":
            button.setTitle("Keep Shape: No", forState: .Normal)
        case "Keep Shape: No":
            button.setTitle("Keep Shape: Yes", forState: .Normal)
        default: return
        }
        
        gradientNode.keepShape = !gradientNode.keepShape
    }
    
    
    
    // MARK: Sliders
    
    
    func startAngleSliderChanged () {
        
        gradientNode.startAngle = (view?.viewWithTag(50) as! UISlider).value
    }
    
    
    func firstRadiusSliderChanged () {
        
        if gradientNode.gradientType == "gamut" || gradientNode.gradientType == "sweep" { gradientNode.radius = (view?.viewWithTag(52) as! UISlider).value }
        if gradientNode.gradientType == "radial" { gradientNode.firstRadius = (view?.viewWithTag(52) as! UISlider).value }
    }
    
    
    func secondRadiusSliderChanged () {
        
        gradientNode.secondRadius = (view?.viewWithTag(54) as! UISlider).value
    }

    
    
    // MARK: - Touch Handling
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        for touch in touches {
            
            if let touch = touch as? UITouch {
                let positionInScene = touch.locationInNode(self)
                let touchedNode = self.nodeAtPoint(positionInScene)
                
                if let gradientNode = touchedNode as? BDGradientNode {
                    
                    var point = self.convertPoint(positionInScene, toNode: gradientNode)
                    point.x = point.x / gradientNode.size.width + 0.5
                    point.y = point.y / gradientNode.size.height + 0.5
                    
                    switch gradientNode.gradientType {
                        
                        case "gamut": gradientNode.center = point
                        
                        case "linear":
                            let closest = chooseCloserPoint(point, otherPoint1: gradientNode.startPoint, otherPoint2: gradientNode.endPoint)
                            if closest == 1 { gradientNode.startPoint = point }
                            else if closest == 2 || closest == 3 { gradientNode.endPoint = point }
                        
                        case "sweep": gradientNode.center = point
                        
                        case "radial":
                            let closest = chooseCloserPoint(point, otherPoint1: gradientNode.firstCenter, otherPoint2: gradientNode.secondCenter)
                            if closest == 1 { gradientNode.firstCenter = point }
                            else if closest == 2 || closest == 3 { gradientNode.secondCenter = point }
                        
                        default: return
                    }
                }
            }
        }
    }
    
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        for touch in touches {
            
            if let touch = touch as? UITouch {
                let positionInScene = touch.locationInNode(self)
                let touchedNode = self.nodeAtPoint(positionInScene)
                
                if let gradientNode = touchedNode as? BDGradientNode {
                    
                    var point = self.convertPoint(positionInScene, toNode: gradientNode)
                    point.x = point.x / gradientNode.size.width + 0.5
                    point.y = point.y / gradientNode.size.height + 0.5
                    
                    switch gradientNode.gradientType {
                        
                        case "gamut": gradientNode.center = point
                        
                        case "linear":
                            let closest = chooseCloserPoint(point, otherPoint1: gradientNode.startPoint, otherPoint2: gradientNode.endPoint)
                            if closest == 1 { gradientNode.startPoint = point }
                            else if closest == 2 || closest == 3 { gradientNode.endPoint = point }
                        
                        case "radial":
                            let closest = chooseCloserPoint(point, otherPoint1: gradientNode.firstCenter, otherPoint2: gradientNode.secondCenter)
                            if closest == 1 { gradientNode.firstCenter = point }
                            else if closest == 2 || closest == 3 { gradientNode.secondCenter = point }
                        
                        case "sweep": gradientNode.center = point
                        
                        default: return
                    }
                }
            }
        }
    }
    
    
    
    // MARK: - Helpers
    
    
    /**
    
    Adjusts the UI elements for the given gradient.
    
    :param: gradient A gradientType of BDGradientNode.
    
    */
    func adjustUIForGradient (gradient: String) {
        
        switch gradientNode.gradientType {
            
        case "gamut":
            if let label = view?.viewWithTag(20) as? UILabel { label.hidden = false }
            if let label = view?.viewWithTag(21) as? UILabel { label.hidden = true }
            if let label = view?.viewWithTag(22) as? UILabel { label.hidden = true }
            if let button = view?.viewWithTag(30) as? UIButton { button.setTitle("Animate: No", forState: .Normal) }
            enableSliderForTag(50)
            enableSliderForTag(52)
            if let slider = view?.viewWithTag(52) as? UISlider { slider.value = gradientNode.radius }
            if let label = view?.viewWithTag(53) as? UILabel { label.text = "Radius" }
            disableSliderForTag(54)
            disableButtonForTag(93)
            if buttonForTag(95)!.titleLabel!.text == "Blend Colors: No" { enableButtonForTag(94) }
            disableButtonForTag(96)
            disableButtonForTag(97)
            disableButtonForTag(98)
            disableLabelForTag(99)
        case "linear":
            if let label = view?.viewWithTag(20) as? UILabel { label.hidden = true }
            if let label = view?.viewWithTag(21) as? UILabel { label.hidden = false }
            if let label = view?.viewWithTag(22) as? UILabel { label.hidden = true }
            if let button = view?.viewWithTag(30) as? UIButton { button.setTitle("Animate: No", forState: .Normal) }
            disableSliderForTag(50)
            disableSliderForTag(52)
            disableSliderForTag(54)
            enableButtonForTag(93)
            if buttonForTag(95)!.titleLabel!.text == "Blend Colors: No" { enableButtonForTag(94) }
            enableButtonForTag(96)
            enableButtonForTag(97)
            enableButtonForTag(98)
            enableLabelForTag(99)
        case "radial":
            if let label = view?.viewWithTag(20) as? UILabel { label.hidden = true }
            if let label = view?.viewWithTag(21) as? UILabel { label.hidden = true }
            if let label = view?.viewWithTag(22) as? UILabel { label.hidden = false }
            if let button = view?.viewWithTag(30) as? UIButton { button.setTitle("Animate: No", forState: .Normal) }
            disableSliderForTag(50)
            enableSliderForTag(52)
            if let slider = view?.viewWithTag(52) as? UISlider { slider.value = gradientNode.firstRadius }
            if let label = view?.viewWithTag(53) as? UILabel { label.text = "First Radius" }
            enableSliderForTag(54)
            enableButtonForTag(93)
            if buttonForTag(95)!.titleLabel!.text == "Blend Colors: No" { enableButtonForTag(94) }
            enableButtonForTag(96)
            enableButtonForTag(97)
            enableButtonForTag(98)
            enableLabelForTag(99)
        case "sweep":
            if let label = view?.viewWithTag(20) as? UILabel { label.hidden = false }
            if let label = view?.viewWithTag(21) as? UILabel { label.hidden = true }
            if let label = view?.viewWithTag(22) as? UILabel { label.hidden = true }
            if let button = view?.viewWithTag(30) as? UIButton { button.setTitle("Animate: No", forState: .Normal) }
            enableSliderForTag(50)
            enableSliderForTag(52)
            if let slider = view?.viewWithTag(52) as? UISlider { slider.value = gradientNode.radius }
            if let label = view?.viewWithTag(53) as? UILabel { label.text = "Radius" }
            disableSliderForTag(54)
            enableButtonForTag(93)
            if buttonForTag(95)!.titleLabel!.text == "Blend Colors: No" { enableButtonForTag(94) }
            enableButtonForTag(96)
            enableButtonForTag(97)
            enableButtonForTag(98)
            enableLabelForTag(99)
        default: return
        }
    }
    
    
    /**
    
    The angle of a point around (0.5, 0.5).
    
    :param: point A point.
    
    :returns: The angle, in radians, of the vector of the given point around (0.5, 0.5).
    
    */
    func angleOfPoint (point: CGPoint) -> CGFloat {
        
        var newPoint = point
        newPoint.x -= 0.5
        newPoint.y -= 0.5
        
        return abs(atan2(newPoint.x, newPoint.y) - CGFloat(M_PI))
    }
    
    
    /**
    
    Compares the point to check against the two other points to see which it's closer to.
    
    :param: pointToCheck The point to compare.
    
    :param: otherPoint1 The first other point.
    
    :param: otherPoint2 The second other point.
    
    :returns: If pointToCheck is closer to otherPoint1 than to otherPoint2: returns 1. If pointToCheck is closer to otherPoint2 than to otherPoint1: returns 2. If the distances are equal: returns 3. If somehow none of those conditions obtains: returns 0.
    
    */
    func chooseCloserPoint(pointToCheck: CGPoint, otherPoint1: CGPoint, otherPoint2: CGPoint) -> Int {
        
        let distance1 = distanceBetweenPoints(pointToCheck, secondPoint: otherPoint1)
        let distance2 = distanceBetweenPoints(pointToCheck, secondPoint: otherPoint2)
        
        if distance1 < distance2 { return 1 }
        if distance2 < distance1 { return 2 }
        if distance1 == distance2 { return 3 }
        
        return 0
    }
    
    
    /**
    
    Disables the UIButton at the given tag.
    
    :param: tag The tag of the desired UIButton.
    
    */
    func disableButtonForTag (tag: Int) {
        
        if let button = (view?.viewWithTag(tag) as? UIButton) {
            button.enabled = false
            button.layer.borderColor = UIColor.lightGrayColor().CGColor!
            button.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        }
    }
    
    
    /**
    
    Disables the UILabel at the given tag.
    
    :param: tag The tag of the desired UILabel.
    
    */
    func disableLabelForTag (tag: Int) {
        
        if let label = (view?.viewWithTag(tag) as? UILabel) {
            label.enabled = false
            label.layer.borderColor = UIColor.lightGrayColor().CGColor!
            label.textColor = UIColor.lightGrayColor()
        }
    }
    
    
    /**
    
    Disables the UISlider at the given tag.
    
    :param: tag The tag of the desired UISlider.
    
    */
    func disableSliderForTag (tag: Int) {
        
        if let slider = view?.viewWithTag(tag) as? UISlider {
            if slider.userInteractionEnabled {
                slider.userInteractionEnabled = false
                slider.minimumTrackTintColor = UIColor.lightGrayColor()
                slider.maximumTrackTintColor = UIColor.lightGrayColor()
                
                if let label = view?.viewWithTag(tag + 1) as? UILabel {
                    label.textColor = UIColor.lightGrayColor()
                }
            }
        }
    }
    
    
    /**
    
    The distance between two points.
    
    :param: firstPoint The first point.
    
    :param: secondPoint The second Point.
    
    :returns: The distance between the two given points.
    
    */
    func distanceBetweenPoints(firstPoint: CGPoint, secondPoint: CGPoint) -> CGFloat {
        
        let xDistance = secondPoint.x - firstPoint.x
        let yDistance = secondPoint.y - firstPoint.y
        
        return sqrt(pow(xDistance, 2) + pow(yDistance, 2))
    }
    
    
    /**
    
    Enables the UIButton at the given tag.
    
    :param: tag The tag of the desired UIButton.
    
    */
    func enableButtonForTag (tag: Int) {
        
        if let button = (view?.viewWithTag(tag) as? UIButton) {
            button.enabled = true
            button.layer.borderColor = blue.CGColor!
            button.setTitleColor(blue, forState: .Normal)
        }
    }
    
    
    /**
    
    Enables the UILabel at the given tag.
    
    :param: tag The tag of the desired UILabel.
    
    */
    func enableLabelForTag (tag: Int) {
        
        if let label = (view?.viewWithTag(tag) as? UILabel) {
            label.enabled = true
            label.layer.borderColor = blue.CGColor!
            label.textColor = blue
        }
    }
    
    
    /**
    
    Enables the UISlider at the given tag.
    
    :param: tag The tag of the desired UISlider.
    
    */
    func enableSliderForTag (tag: Int) {
        
        if let slider = view?.viewWithTag(tag) as? UISlider {
            if slider.userInteractionEnabled == false {
                slider.userInteractionEnabled = true
                slider.minimumTrackTintColor = blue
                slider.maximumTrackTintColor = UIColor.darkGrayColor()
                
                if let label = view?.viewWithTag(tag + 1) as? UILabel {
                    label.textColor = blue
                }
            }
        }
    }
    
    
    /**
    
    Generates a random CGFloat between the given min and max.
    
    :param: min The lowest possible return value.
    
    :param: max The highest possible return value.
    
    :returns: A random CGFloat between the given min and max.
    
    */
    func random(#min: CGFloat, max: CGFloat) -> CGFloat {
        
        let random = CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        return random * (max - min) + min
    }
    
    
    /**
    
    Creates an array of the given number of random colors.
    
    :param: numberOfColors The number of colors that will be in the array.
    
    :returns: An array of the given number of random colors.
    
    */
    func randomColorArray(numberOfColors: Int) -> [UIColor] {
        
        var newColors = [UIColor]()
        
        for var i = 0; i < numberOfColors; i++ {
            
            let newColor = UIColor(hue: random(min: 0.0, max: 1.0), saturation: random(min: 0.33, max: 1.0), brightness: random(min: 0.75, max: 1.0), alpha: 1.0)
            newColors.append(newColor)
        }
        
        return newColors
    }
    
    
    /**
    
    Resets the currently selected BDGradientNode with the current settings. Note that only colors and locations are not updated in real-time.
    
    */
    func resetCurrentNode () {
        
        gradientNode.removeAllActions()
        
        locationsButtonStatus = "default"
        
        if let button = view?.viewWithTag(30) as? UIButton { button.setTitle("Animate: No", forState: .Normal) }
        
        switch gradientNode.gradientType {
            
        case "gamut": gamutGradientButtonPressed()
        case "linear": linearGradientButtonPressed()
        case "sweep": sweepGradientButtonPressed()
        case "radial": radialGradientButtonPressed()
        default: return
        }
    }
    
    
    /**
    
    Rotates a point around (0.5, 0.5) by the given angle.
    
    :param: point The starting point.
    
    :param: angle The angle by which the point will be rotated in radians.
    
    :returns: A point rotated from the starting point, around (0.5, 0.5), by the given angle.
    
    */
    func rotatePoint (point: CGPoint, byAngle angle: CGFloat) -> CGPoint {
        
        let sinAngle = sin(angle)
        let cosAngle = cos(angle)
        
        var newPoint = point
        newPoint.x -= 0.5
        newPoint.y -= 0.5
        
        newPoint.x = newPoint.x * cosAngle - newPoint.y * sinAngle
        newPoint.y = newPoint.x * sinAngle + newPoint.y * cosAngle
        
        newPoint.x += 0.5
        newPoint.y += 0.5
        
        return newPoint
    }
    
    
    /**
    
    A UIButton for a given tag.
    
    :param: tag The tag for the desired UIButton.
    
    :returns: The UIButton at the tag, if it exists; nil otherwise.
    
    */
    func buttonForTag (tag: Int) -> UIButton? {
        
        if let button = view?.viewWithTag(tag) as? UIButton { return button }
        else { return nil }
    }
}
