![Braindrizzle Studio](http://braindrizzlestudio.com/images/logo/logo-overlay-orange-180.png "Braindrizzle Studio:tm:")

# BDGradientNode
#### Version: 1.3.1

### By: [Braindrizzle Studio:tm:](http://braindrizzlestudio.com)


#### What is it?

BDGradientNode is a subclass of SKSpriteNode for adding gradients to textures. This is normally a surprisingly convoluted process! (More on that in the Background section below.) With BDGradientNode you can easily add linear, radial, and sweep gradients--blended or not--to any texture.


## Documentation

I have tried to provide thorough documentation in the BDGradientNode.swift file. The documentation for use is provided in this readme.


## Installation

Simply copy BDGradientNode.swift into your project. Done!
Note: the project requires Xcode 6.3 and Swift 1.2.


## Use

1. Instantiate a BDGradientNode.

2. Enjoy your BDGradientNode!

NOTE: Due to a change in Swift 2 / iOS 9, you are now required to add the line PrefersOpenGL = YES to your info.plist


## Examples

The demo app code will serve as the most useful example, but here are the basics.

#### Instantiation

This will produce the blue cone in the screenshot.
```swift
let color1 = UIColor(hue: 230/360, saturation: 1.0, brightness: 1.0, alpha: 1.0)
let color2 = UIColor(hue: 210/360, saturation: 1.0, brightness: 1.0, alpha: 1.0)
let color3 = UIColor(hue: 190/360, saturation: 1.0, brightness: 1.0, alpha: 1.0)
let colors = [color1, color2, color3]

let blending : Float = 1.0

let firstCenter = CGPoint(x: 0.2, y: 0.2)
let firstRadius : Float = 0.1
        
let secondCenter = CGPoint(x: 0.5, y: 0.5)
let secondRadius : Float = 0.4
        
let nodeSize = CGSize(width: self.size.width, height: self.size.width)
        
let texture = SKTexture(imageNamed: "dummypixel")
        
let myGradientNode = BDGradientNode(radialGradientWithTexture: texture, colors: colors, locations: nil, firstCenter: firstCenter, firstRadius: firstRadius, secondCenter: secondCenter, secondRadius: secondRadius, blending: blending, discardOutsideGradient: true, keepTextureShape: false, size: nodeSize)

addChild(myGradientNode)
```

![Radial Gradient](http://braindrizzlestudio.com/images/other/example-radial.jpg "Radial Gradient")

This will instantiate the linear gradient of 3 colors, blended with the Spacehip, in the screenshot.
```swift
let color1 = UIColor(hue: 0/360, saturation: 1.0, brightness: 1.0, alpha: 1.0)
let color2 = UIColor(hue: 0/360, saturation: 0.0, brightness: 1.0, alpha: 1.0)
let color3 = UIColor(hue: 220/360, saturation: 1.0, brightness: 1.0, alpha: 1.0)
let colors = [color1, color2, color3]

let blending = 0.5
        
let location1 : CGFloat = 0.5
let locations : [CGFloat] = [location1]
        
let startPoint = CGPoint(x: 0.3, y: 0.0)
let endPoint = CGPoint(x: 0.6, y: 0.8)
        
let size = CGSize(width: self.size.width, height: self.size.width)
        
let texture = SKTexture(imageNamed: "Spaceship")
        
let myGradientNode = BDGradientNode(linearGradientWithTexture: texture, colors: colors, locations: nil, startPoint: startPoint, endPoint: endPoint, blending: blending, keepTextureShape: true, size: nodeSize)
```

![Linear Gradient](http://braindrizzlestudio.com/images/other/example-linear.jpg "Linear Gradient")


#### Animation

After instantiating the BDGradientNode you can simply change the properties of that type of node while your program is running and the gradient will change in real-time. This makes animation very simple. The only limitation is changing the number of colors/locations; the colors and locations themselves can be swapped by passing new arrays during runtime, but the arrays have to be the same size as the BDGradientNode you instantiated. (More on this in the Limitations section below.)

To use SKActions to animate you can use runBlock, as in the demo app code.

```swift
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
```


#### Tips

- To have gradients with arbitrary shapes simply pass a texture with your shape and set keepTextureShape to true.

- You can set one of the radial gradient radii to a negative number to get a double-cone effect.

- The radial gradient is by far the most complex of the gradients; it's also the least performant during instantiation. Keep that in mind!

- Linear and radial gradients look much better with colors that are similar. Once we switch the linear interpolation for something better, they'll look better with disparate colors.

- If you're not going to blend with a texture: make a dummy pixel and stretch it to the size you want with the BDGradientNode 'size' parameter.


#### Important Note

- This is in the initializer documentation, but it's worth emphasizing: all points and radii are specified in Apple's normalized coordinate system, with (0, 0) at the bottom left and (1, 1) at the top right.


## Background

We wrote BDGradientNode because gradients are a bit of a pain to set up on the fly in SpriteKit. UIViews are CALayer-backed and have access to CAGradientLayer, making them simple--fairly simple--to make. (Though sweep gradients can't be done.) SKNodes are NOT layer-backed. While you can jump through some hoops to make images, and so textures, from layers that can be assigned to an SKSpriteNode (which is what we first did when we just needed a simple gradient in SpriteKit) it's both cumbersome and inflexible.


## Limitations

- The current version is limited only in not being able to adjust the number of colors/locations without re-initializing a BDGradientNode.

- The shaders use high precision floats--not the most performant setting. But while on the iOS Simulator everything works with lower precisions, on hardware there can be artifacts in certain conditions. You can, of course, change the shaders for your own applications. Make sure you also change the shader-constructor's 'stringRange' instances to match, if required.


#### A Note on the Gamut Gradient

The gamut gradient uses the gamut of the HSB spectrum rather than requiring specified colors and locations. We made shaders for gamut versions of the linear and radial gradients too, but the linear interpolation of GLSL mix() ruined the smooth effect in those cases--they looked no better than using an array of red, purple, blue, etc.. Once we change out the GLSL mix() for something better we'll look at doing linear and radial gamuts again.


## The Demo

The demo app was created solely to give an idea of what you can easily do with BDGradient Node. Make sure you play with all the settings, touch the image, and watch the animations! Try changing the settings, including with image-touches for the gradients that take them, while the animations are running!

Note: the UI of the demo was not designed to fit on iPhone 4S.


## Coming Updates

We have plans for version 2.0; it will be released in 2016. The biggest change will be switching from the linear interpolation of GLSL mix() to something a bit fancier, as long as it's reasonably performant. We hope to receive suggestions from you, too! Alternatively, we're looking into switching from OpenGL to Metal, as that's now the default setting for apps (which is why the new info.plist setting is required).


## Changelog

### 1.3.1
- Due to changes in Swift 2 / iOS 9, a small change was made to the GLSL code
- Added NOTE to users that they now must add PrefersOpenGL = YES to info.plist

### 1.3
- Updated syntax for iOS 9 and Swift 2

### 1.2
- Added the ability to vary blending percentage, rather than just having it off or on.
- Added the option to keep or discard the texture colors outside of the gradient. For example: suppose you have a radial gradient; you'll have the option of whether or not to show the texture through the hole in the middle.

### 1.1
- Switched colors and locations to uniforms, adding the ability to change the colors and locations of gradients on the fly (i.e. without initializing a new BDGradientNode).


## Contact Us!

We'd really like to have feedback and suggestions. Please feel free to do so here on GitHub. 

Better yet, email support@braindrizzlestudio.com 

or visit us at http://www.braindrizzlestudio.com
