![Braindrizzle Studio](http://braindrizzlestudio.com/images/logo/logo-overlay-orange-180.png "Braindrizzle Studio:tm:")

# BDGradientNode
#### Version: 1.0
Important: Written in Swift 1.2 using Xcode 6.3 beta.

### By: [Braindrizzle Studio:tm:](http://braindrizzlestudio.com)


#### What is it?

BDGradientNode is a subclass of SKSpriteNode for adding gradients to textures. This is normally a surprisingly convoluted process! (More on that in the Background section below.) With BDGradientNode you can easily add linear, radial, and sweep gradients--blended or not--to any texture.


## Documentation

I have tried to provide thorough documentation in the BDGradientNode.swift file. The documentation for use is provided in this readme.


## Installation

Simply copy BDGradientNode.swift into your project. Done!


## Use

1. Instantiate a BDGradientNode.

2. Enjoy your BDGradientNode!


## Examples

The demo app code will serve as the most useful example, but here are the basics.

#### Instantiation

This will produce the blue cone in the screencap.
```swift
let color1 = UIColor(hue: 230/360, saturation: 1.0, brightness: 1.0, alpha: 1.0)
let color2 = UIColor(hue: 210/360, saturation: 1.0, brightness: 1.0, alpha: 1.0)
let color3 = UIColor(hue: 190/360, saturation: 1.0, brightness: 1.0, alpha: 1.0)
let colors = [color1, color2, color3]
        
let firstCenter = CGPoint(x: 0.2, y: 0.2)
let firstRadius : Float = 0.1
        
let secondCenter = CGPoint(x: 0.5, y: 0.5)
let secondRadius : Float = 0.4
        
let nodeSize = CGSize(width: self.size.width, height: self.size.width)
        
let texture = SKTexture(imageNamed: "dummypixel")
        
let myGradientNode = BDGradientNode(radialGradientWithTexture: texture, colors: colors, locations: nil, firstCenter: firstCenter, firstRadius: firstRadius, secondCenter: secondCenter, secondRadius: secondRadius, blended: false, keepShape: false, size: nodeSize)
addChild(myGradientNode)
```

This will instantiate a linear gradient of 3 colors, the first color taking most of the gradient, not blended with the texture, going from the bottom left corner of the screen to the top right.
```swift
let color1 = UIColor(hue: 20/360, saturation: 1.0, brightness: 1.0, alpha: 1.0)
let color2 = UIColor(hue: 40/360, saturation: 1.0, brightness: 1.0, alpha: 1.0)
let color3 = UIColor(hue: 50/360, saturation: 1.0, brightness: 1.0, alpha: 1.0)
let colors = [color1, color2, color3]

let location1 : CGFloat = 0.75
let locations : [CGFloat] = [location1]

let startPoint = CGPoint(x: 0.0, y: 0.0)
let endPoint = CGPoint(x: 1.0, y: 1.0)

let texture = SKTexture(imageNamed: "dummypixel")

let myGradientNode = BDGradientNode(linearGradientWithTexture: texture, colors: colors, locations: locations, startPoint: startPoint, endPoint: endPoint, blended: false, keepShape: false, size: self.size)
addChild(myGradientNode)
```

Fun Use!

2. After instantiating the BDGradientNode you can simply change the properties of that type of node while your program is running and the gradient will change in real-time. This makes animation very simple. The only exceptions--at least for v1.0--are the colors and locations; these would require recompilation. (More on this in the Limitations section below.)


Tips:

- To have gradients with arbitrary shapes simply pass a texture with your shape and either set blended to true, or blended to false with keepShape as true.
- You can set one of the radialGradient radii to a negative number to get a double-cone effect.
- If you're not going to blend with a texture: make a dummy pixel and stretch it to the size you want with the BDGradientNode 'size' parameter.

It's important to note that all points and radii are specified in Apple's normalized coordinate system, with (0, 0) at the bottom left and (1, 1) at the top right.


A performance note: The Apple docs for SKShader recommend initializing shaders ... etc.. Recompilation, etc..
We initally had hardcoded indices, but the shader code was very easily broken and MUCH less readable.


Background

We wrote BDGradientNode because gradients are a bit of a pain to set up on the fly in SpriteKit. UIViews are CALayer-backed and have access to CAGradientLayer, making them simple--fairly simple--to make. (Though sweep gradients aren't an option.) SKNodes are NOT layer-backed. While you can jump through some hoops to make images, and so textures, from layers that can be assigned to an SKSpriteNode (which is what we first did when we just needed a simple gradient in SpriteKit) it's both cumbersome and inflexible.


Limitations

- Version 1.0 is limited only in not being able to adjust colors or locations without recompilation.
- The shaders use high precision floats--not the most performant setting. But while on the iOS Simulator everything works with lower precisions, on hardware there can be artifacts in certain conditions. You can, of course, change the shaders for your own applications. Make sure you also change the shader-constructor's 'stringRange' instances to match.


Gamut Gradient

The gamut gradient uses the gamut of the HSB spectrum rather than requiring specified colors and locations. Since it's particularly pretty we made it its own thing. We made shaders for gamut versions of the linear and radial gradients too, but the linear interpolation of GLSL mix() ruined the smooth effect in those cases--they looked no better than using an array of red, purple, blue, etc.. 

- We had made gamut gradients 


Linear Gradient

- 

Tip: linear gradients look MUCH better with colors that are similar. Once we switch the linear interpolation for something better, they'll look good with disparate colors too.


Radial Gradient

- This is by far the most complex of the gradients; it's also the least performant. 


Sweep Gradient

- 


Tips: 

- The radial gradient can be used to make a sort of expanding linear gradient. Simply have the smaller circle be completely outside of the larger one.



The Shaders

SKUniform has neither a bool type or a true array type. Where we wanted bools we used floats at either 0.0 or 1.0; where we wanted arrays (colors and locations) we did hacky things.


The Demo

The demo app was created solely to give an idea of what you can easily do with BDGradient Node. Make sure you play with all the settings, and watch the animations! (We especially like the radial gradient animation with blended and keepShape false.) You can change the settings, including with image touches for the gradients that take them, while the animations are running.

WILL WE DO THIS?
The only feature not demonstrated is the ability to adjust the locations of the stops in the gradient. This involves no more than passing an array of CGFloats, but squeezing such a selection into the simple interface of the demo didn't seem worth the trouble. Do note that the NUMBER of locations automatically adjusts when you change the number of colors.
Note: the UI of the demo was not designed to fit on iPhone 4S.


Coming Updates

We have plans for version 2.0; it will be released later in 2015. The biggest change will be switching from the linear interpolation of GLSL mix() to something a bit fancier, as long as it's performant. We might also include the ability to swap colors and locations on the fly by passing new arrays. (Though not the number of each--that would require recompilation.) We hope to receive suggestions from you, too!
