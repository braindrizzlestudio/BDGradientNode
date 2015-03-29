//
//  GradientScene.swift
//  BDGradientNodeDemo
//
//  Created by Braindrizzle Studio.
//  http://braindrizzlestudio.com
//  Copyright (c) 2015 Braindrizzle Studio. All rights reserved.
//

import SpriteKit

class GradientScene : SKScene {
    
    // MARK: - Properties
    
    var displayedNode = BDGradientNode()
    
    let starTexture = SKTexture(imageNamed: "star")
    
    // BDGradientNode Properties
    var blended = true
    var center = CGPoint(x: 0.5, y: 0.5)
    var colors = [UIColor]() {
        didSet {
            if displayedNode.gradientType != "gamut" { resetCurrentNode() }
        }
    }
    var endPoint = CGPoint(x: 0.5, y: 1.0)
    var firstCenter = CGPoint(x: 0.2, y: 0.2)
    var firstRadius : CGFloat = 0.1
    var keepShape = true
    var locations = [CGFloat(0.5)]
    var nodeSize = CGSizeZero
    var numberOfColors = 6 {
        didSet {
            (view?.viewWithTag(99) as! UILabel).text = "\(numberOfColors)"
        }
    }
    var secondCenter = CGPoint(x: 0.8, y: 0.8)
    var secondRadius : CGFloat = 0.5
    var startAngle : Float = 0.0
    var startPoint = CGPoint(x: 0.5, y: 0.0)
    var currentTexture = SKTexture(imageNamed: "Spaceship")
  
    // MARK: - ViewController
    
    
    override func didMoveToView(view: SKView) {
        
        backgroundColor = UIColor.whiteColor()
        
        nodeSize = CGSize(width: self.size.width - 10, height: self.size.width - 10)
        
        randomColorsButtonPressed()
        
        setupUI()
        
        gamutGradientButtonPressed()
    }
    
    
    func setupUI () {
        
        setupButtons()
        setupSliders()
    }
    
    
    // MARK: - Buttons
    
    
    func setupButtons () {
        
        // Gradients
        setupGamutGradientButton()
        setupLinearGradientButton()
        setupSweepGradientButton()
        setupRadialGradientButton()
        
        // Colors
        setupRandomColorButton()
        setupNumberOfColorsButtons()
        
        // Options
        setupBlendedButton()
        setupKeepShapeButton()
    }
    
    // MARK: Gradients
    
    func setupGamutGradientButton () {
        
        let origin = convertPointToView(CGPoint(x: self.size.width * 1 / 21, y: self.size.height - self.size.width))
        let size = CGSize(width: self.size.width * 4 / 21, height: self.size.height * 1 / 21)
        let frame = CGRect(origin: origin, size: size)
        setupButton(frame: frame, title: "Gamut", action: "gamutGradientButtonPressed")
    }
    
    
    func setupLinearGradientButton () {
        
        let origin = convertPointToView(CGPoint(x: self.size.width * 6 / 21, y: self.size.height - self.size.width))
        let size = CGSize(width: self.size.width * 4 / 21, height: self.size.height * 1 / 21)
        let frame = CGRect(origin: origin, size: size)
        setupButton(frame: frame, title: "Linear", action: "linearGradientButtonPressed")
    }
    
    
    func setupSweepGradientButton () {
        
        let origin = convertPointToView(CGPoint(x: self.size.width * 11 / 21, y: self.size.height - self.size.width))
        let size = CGSize(width: self.size.width * 4 / 21, height: self.size.height * 1 / 21)
        let frame = CGRect(origin: origin, size: size)
        setupButton(frame: frame, title: "Sweep", action: "sweepGradientButtonPressed")
    }
    
    
    func setupRadialGradientButton () {
        
        let origin = convertPointToView(CGPoint(x: self.size.width * 16 / 21, y: self.size.height - self.size.width))
        let size = CGSize(width: self.size.width * 4 / 21, height: self.size.height * 1 / 21)
        let frame = CGRect(origin: origin, size: size)
        let button = setupButton(frame: frame, title: "Radial", action: "radialGradientButtonPressed")
        button.tag = 53
    }
    
    
    // MARK: Colors
    
    
    func setupRandomColorButton () {
        
        let origin = convertPointToView(CGPoint(x: self.size.width * 1 / 21, y: self.size.height - self.size.width - self.size.width * 3 / 21))
        let size = CGSize(width: self.size.width * 9 / 21, height: self.size.height * 1 / 21)
        let frame = CGRect(origin: origin, size: size)
        let button = setupButton(frame: frame, title: "Random Colors", action: "randomColorsButtonPressed")
        button.tag = 96
    }
    
    
    func setupNumberOfColorsButtons () {
        
        // Minus
        
        let minusorigin = convertPointToView(CGPoint(x: self.size.width * 1 / 21, y: self.size.height - self.size.width - self.size.width * 5 / 21))
        let MinusSize = CGSize(width: self.size.height * 1 / 21, height: self.size.height * 1 / 21)
        let MinusFrame = CGRect(origin: minusorigin, size: MinusSize)
        let minusButton = setupButton(frame: MinusFrame, title: "-", action: "minusColorsButtonPressed")
        minusButton.tag = 98
        
        // Number of Colors Label
        let numberOrigin = convertPointToView(CGPoint(x: self.size.width * 4.5 / 21, y: self.size.height - self.size.width - self.size.width * 5 / 21))
        let numberSize = CGSize(width: self.size.height * 1 / 21, height: self.size.height * 1 / 21)
        let numberFrame = CGRect(origin: numberOrigin, size: numberSize)
        let numberOfButtonLabel = setupLabel(frame: numberFrame, text: "\(numberOfColors)")
        numberOfButtonLabel.tag = 99
        
        // Plus
        let plusOrigin = convertPointToView(CGPoint(x: self.size.width * 8 / 21, y: self.size.height - self.size.width - self.size.width * 5 / 21))
        let plusSize = CGSize(width: self.size.height * 1 / 21, height: self.size.height * 1 / 21)
        let plusFrame = CGRect(origin: plusOrigin, size: plusSize)
        let plusButton = setupButton(frame: plusFrame, title: "+", action: "plusColorsButtonPressed")
        plusButton.tag = 97
    }
    
    
    // MARK: Options
    
    func setupBlendedButton () {
        
        let origin = convertPointToView(CGPoint(x: self.size.width * 11 / 21, y: self.size.height - self.size.width - self.size.width * 3 / 21))
        let size = CGSize(width: self.size.width * 9 / 21, height: self.size.height * 1 / 21)
        let frame = CGRect(origin: origin, size: size)
        let button = setupButton(frame: frame, title: "Blend Colors: Yes", action: "blendColorsButtonPressed")
        button.tag = 95
    }
    
    
    func setupKeepShapeButton () {
        
        let origin = convertPointToView(CGPoint(x: self.size.width * 11 / 21, y: self.size.height - self.size.width - self.size.width * 5 / 21))
        let size = CGSize(width: self.size.width * 9 / 21, height: self.size.height * 1 / 21)
        let frame = CGRect(origin: origin, size: size)
        let button = setupButton(frame: frame, title: "Keep Shape: Yes", action: "keepShapeButtonPressed")
        button.tag = 94
        disableButtonForTag(94)
        
        let subOrigin = convertPointToView(CGPoint(x: self.size.width * 11 / 21, y: self.size.height - self.size.width - self.size.width * 7 / 21))
        let subSize = CGSize(width: self.size.width * 9 / 21, height: self.size.height * 0.5 / 21)
        let subFrame = CGRect(origin: subOrigin, size: subSize)
        let label = UILabel(frame: subFrame)
        label.text = "'Keep Shape' is ignored if 'Blend Colors' is true."
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        view?.addSubview(label)
    }
    
    
    // MARK: Button and Label Makers
    
    func setupButton (#frame: CGRect, title: String, action: Selector) -> UIButton {

        let button = UIButton(frame: frame)
        
        button.layer.cornerRadius = 8.0
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.blueColor().CGColor!
        
        button.setTitle(title, forState: .Normal)
        button.setTitleColor(UIColor.blueColor(), forState: .Normal)
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
        label.layer.borderColor = UIColor.blueColor().CGColor!
        
        label.text = text
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.blueColor()
        label.textAlignment = .Center
        
        view?.addSubview(label)
        
        return label
    }
    
    
    
    // MARK: - Sliders
    
    
    func setupSliders () {
        
        setupStartAngleSlider()
    }
    
    
    func setupStartAngleSlider () {
        
        let origin = convertPointToView(CGPoint(x: self.size.width * 1 / 21, y: self.size.height - self.size.width - self.size.width * 9 / 21))
        let size = CGSize(width: self.size.width * 9 / 21, height: self.size.height * 1 / 21)
        let frame = CGRect(origin: origin, size: size)
        let slider = UISlider(frame: frame)
        
        slider.minimumValue = Float(0.0)
        slider.maximumValue = Float(2 * M_PI)
        
        slider.addTarget(self, action: "startAngleSliderChanged", forControlEvents: .ValueChanged)
        
        slider.tag = 50
        
        view?.addSubview(slider)
    }
    
    
    
    // MARK: - Actions
    
    
    // MARK: Gradients
    
    
    func gamutGradientButtonPressed () {
        
        displayedNode.removeFromParent()
        displayedNode = BDGradientNode(gamutGradientWithTexture: currentTexture, center: center, startAngle: startAngle, blended: blended, keepShape: keepShape, size: nodeSize)
        displayedNode.position = CGPoint(x: self.size.width / 2, y: self.size.height - self.size.width / 2)
        addChild(displayedNode)
        
        adjustButtonsForGradient("gamut")
    }
    
    
    func linearGradientButtonPressed () {
        
        displayedNode.removeFromParent()
        displayedNode = BDGradientNode(linearGradientWithTexture: currentTexture, colors: colors, locations: locations, startPoint: startPoint, endPoint: endPoint, blended: blended, keepShape: keepShape, size: nodeSize)
        displayedNode.position = CGPoint(x: self.size.width / 2, y: self.size.height - self.size.width / 2)
        addChild(displayedNode)
        
        adjustButtonsForGradient("linear")
    }
    
    
    func sweepGradientButtonPressed () {
        
        displayedNode.removeFromParent()
        displayedNode = BDGradientNode(sweepGradientWithTexture: currentTexture, colors: colors, locations: locations, center: center, startAngle: startAngle, blended: blended, keepShape: keepShape, size: nodeSize)
        displayedNode.position = CGPoint(x: self.size.width / 2, y: self.size.height - self.size.width / 2)
        addChild(displayedNode)
        
        adjustButtonsForGradient("sweep")
    }
    
    
    func radialGradientButtonPressed () {
        
        displayedNode.removeFromParent()
        displayedNode = BDGradientNode(radialGradientWithTexture: currentTexture, colors: colors, locations: locations, firstCenter: firstCenter, firstRadius: firstRadius, secondCenter: secondCenter, secondRadius: secondRadius, blended: blended, size: nodeSize)
        displayedNode.position = CGPoint(x: self.size.width / 2, y: self.size.height - self.size.width / 2)
        addChild(displayedNode)
        
        adjustButtonsForGradient("radial")
    }
    
    
    // MARK: Colors
    
    
    func randomColorsButtonPressed () {
        
        colors = randomColorArray(numberOfColors)
    }
    
    
    func minusColorsButtonPressed () {
        
        if numberOfColors == 2 { return }
        
        numberOfColors = numberOfColors - 1
        randomColorsButtonPressed()
    }
    
    
    func plusColorsButtonPressed () {
        
        numberOfColors = numberOfColors + 1
        randomColorsButtonPressed()
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
        
        blended = !blended
        resetCurrentNode()
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
        
        keepShape = !keepShape
        if displayedNode.gradientType != "radial" { resetCurrentNode() }
    }
    
    
    // MARK: Sliders
    
    
    func startAngleSliderChanged () {
        
        displayedNode.startAngle = (view?.viewWithTag(50) as! UISlider).value
    }

    
    
    // MARK: - Helpers
    
    
    func adjustButtonsForGradient (gradient: String) {
        
        switch displayedNode.gradientType {
            
        case "gamut":
            disableButtonForTag(96)
            disableButtonForTag(97)
            disableButtonForTag(98)
            disableLabelForTag(99)
        case "linear":
            enableButtonForTag(96)
            enableButtonForTag(97)
            enableButtonForTag(98)
            enableLabelForTag(99)
        case "sweep":
            enableButtonForTag(96)
            enableButtonForTag(97)
            enableButtonForTag(98)
            enableLabelForTag(99)
        case "radial":
            enableButtonForTag(96)
            enableButtonForTag(97)
            enableButtonForTag(98)
            enableLabelForTag(99)
        default: return
        }
    }
    
    func disableButtonForTag (tag: Int) {
        
        let button = (view?.viewWithTag(tag) as! UIButton)
        button.enabled = false
        button.layer.borderColor = UIColor.lightGrayColor().CGColor!
        button.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
    }
    
    func disableLabelForTag (tag: Int) {
        
        let label = (view?.viewWithTag(tag) as! UILabel)
        label.enabled = false
        label.layer.borderColor = UIColor.lightGrayColor().CGColor!
        label.textColor = UIColor.lightGrayColor()
    }
    
    func enableButtonForTag (tag: Int) {
        
        let button = (view?.viewWithTag(tag) as! UIButton)
        button.enabled = true
        button.layer.borderColor = UIColor.blueColor().CGColor!
        button.setTitleColor(UIColor.blueColor(), forState: .Normal)
    }
    
    func enableLabelForTag (tag: Int) {
        
        let label = (view?.viewWithTag(tag) as! UILabel)
        label.enabled = true
        label.layer.borderColor = UIColor.blueColor().CGColor!
        label.textColor = UIColor.blueColor()
    }
    
    
    func resetCurrentNode () {
        
        switch displayedNode.gradientType {
            
            case "gamut": gamutGradientButtonPressed()
            case "linear": linearGradientButtonPressed()
            case "sweep": sweepGradientButtonPressed()
            case "radial": radialGradientButtonPressed()
            default: return
        }
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
    
    Generates a random CGFloat between the given min and max.
    Thanks to https://github.com/raywenderlich/SKTUtils
    
    :param: min The lowest possible return value.
    
    :param: max The highest possible return value.
    
    :returns: A random CGFloat between the given.
    
    */
    func random(#min: CGFloat, max: CGFloat) -> CGFloat {

        let random = CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        return random * (max - min) + min
    }
}
