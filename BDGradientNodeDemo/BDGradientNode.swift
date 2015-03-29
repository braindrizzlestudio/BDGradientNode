/**

The MIT License (MIT)

Copyright (c) 2015 Braindrizzle Studio
http://braindrizzlestudio.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Version: 1.0

*/

import SpriteKit

class BDGradientNode : SKSpriteNode {
    
    
    // MARK: - Properties
    
    /// The type of gradient of the node: gamut, linear, radial, or sweep.
    var gradientType = ""
    
    // MARK: Uniforms
    private var uniforms = [SKUniform]()
    
    private let u_startAngle = SKUniform(name: "u_startAngle", float: 0.0)
    
    /// An angle in radians between 0 and 2Pi, where 0 is to the right along the x axis. Default is 0.
    var startAngle : Float = 0.0 {
        didSet {
            u_startAngle.floatValue = startAngle / Float(2 * M_PI) % 1.0
        }
    }
    
    
    
    
    // MARK: - Initialization
    
    /// Use the appropriate convenience initializer to get your BDGradientNode; this isn't the initializer you're looking for.
    internal override init (texture: SKTexture!, color: UIColor!, size: CGSize) {
        
        super.init(texture: texture, color: color, size: size)
    }

    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: Gamut Gradients

    
    /**
    
    An SKSpriteNode with the gamut of the spectrum.
    
    :param: texture The texture to be shaded.
    
    :param: center A optional point in the coordinate system of (0.0, 0.0) to (1.0, 1.0), where (0.0, 0.0) is the bottom left corner of the sprite and (1.0, 1.0) is the top right. Default is (0.5, 0.5).
    
    :param: startAngle An optional angle in radians between 0 and 2Pi, where 0 is to the right along the x axis. Red will start at this angle. Default is 0.
    
    :param: blended If true, the given colors will be blended with the texture's existing colors; if false the node will have purely the given colors. Note that if true the keepShape value will be ignored.
    
    :param: keepShape If true, the resulting node will have the shape of the given texture by only drawing where the texture alpha channel is non-zero; if false it will fill the given size. Note that this value will be ignored if blended is true.
    
    :param: size The desired size of the node.
    
    */
    convenience init (gamutGradientWithTexture texture: SKTexture, center: CGPoint?, startAngle: Float?, blended: Bool, keepShape: Bool, size: CGSize) {

        self.init(texture: texture, color: nil, size: size)
        
        gradientType = "gamut"
        
        // Setup Shader
        shader = gamutGradientShader(center: center, startAngle: startAngle, blended: blended, keepShape: keepShape)
        shader?.uniforms = uniforms
    }
    

    
    // MARK: Linear Gradient

    /**
    
    A SKSpriteNode with a linear gradient from bottom to top in the given texture.
    
    :param: texture The texture to be shaded.
    
    :param: colors An array of two or more colors.
    
    :param: locations An optional array of monotonically increasing color locations, where 0.0 is the start and 1.0 is the end (neither 0.0 nor 1.0 should be included in this array). The first color in colors is automatically at 0.0; the last is automatically at 1.0; the rest are at the locations in this array. For that reason: locations must contain  colors.count - 2  CGFloats. If the number of locations is nil or different than required: colors will be spread out evenly.
    
    :param: startPoint An optional point from which the gradient should start. If this is not nil then endPoint must also have a value. If it is nil then it will default to the bottom center of the texture (0.5, 0.0).
    
    :param: endPoint An optional point at which the gradient should end. If this is not nil then startPoint must also have a value. If it is nil then it will default to the top center of the texture (0.5, 1.0).
    
    :param: blended If true, the given colors will be blended with the texture's existing colors; if false the node will have purely the given colors. Note that if true the keepShape value will be ignored.
    
    :param: keepShape If true, the resulting node will have the shape of the given texture by only drawing where the texture alpha channel is non-zero; if false it will fill the given size. Note that this value will be ignored if blended is true.
    
    :param: size The desired size of the node.
    
    */
    convenience init (linearGradientWithTexture texture: SKTexture, colors: [UIColor], locations: [CGFloat]?, startPoint: CGPoint?, endPoint: CGPoint?, blended: Bool, keepShape: Bool, size: CGSize) {
        
        self.init(texture: texture, color: nil, size: size)
        
        gradientType = "linear"
        
        shader = linearGradientShader(colors: colors, locations: locations, startPoint: startPoint, endPoint: endPoint, blended: blended, keepShape: keepShape)
        shader?.uniforms = uniforms
    }
       
    
    // MARK: Radial Gradient
    
    /**
    
    An SKSpriteNode with a radial gradient between the two specified circles. At least one circle must have a radius specified. Note that the coordinate system for the firstCenter and secondCenter has its anchor point (0.0, 0.0) at the bottom left of the texture; (texture.size().width, texture.size().height) is at the top right.
    
    :param: texture The texture to be shaded.
    
    :param: colors An array of two or more colors.
    
    :param: locations An optional array of monotonically increasing color locations, where 0.0 is the start and 1.0 is the end (neither 0.0 nor 1.0 should be included in this array). The first color in colors is automatically at 0.0; the last is automatically at 1.0; the rest are at the locations in this array. For that reason: locations must contain  colors.count - 2  CGFloats. If the number of locations is nil or different than required: colors will be spread out evenly.
    
    :param: firstCenter An optional point that specifies the center of the first circle in the coordinate system of (0.0, 0.0) to (1.0, 1.0), where (0.0, 0.0) is the bottom left corner of the sprite and (1.0, 1.0) is the top right. Default is the center of the node.
    
    :param: firstRadius An optional radius of the first circle in the coordinate system of (0.0, 0.0) to (1.0, 1.0), where (0.0, 0.0) is the bottom left corner of the sprite and (1.0, 1.0) is the top right. Default is 0.
    
    :param: secondCenter An optional point that specifies the center of the second circle in the coordinate system of (0.0, 0.0) to (1.0, 1.0), where (0.0, 0.0) is the bottom left corner of the sprite and (1.0, 1.0) is the top right. Default is the center of the node.
    
    :param: secondRadius An optional radius of the second circle in the coordinate system of (0.0, 0.0) to (1.0, 1.0), where (0.0, 0.0) is the bottom left corner of the sprite and (1.0, 1.0) is the top right. Default is 0.
    
    :param: size The desired size of the node. Note: if this size is not the size of the passed texture then the "circles" will be ellipses.
    
    */
    convenience init (radialGradientWithTexture texture: SKTexture, colors: [UIColor], locations: [CGFloat]?, firstCenter: CGPoint?, firstRadius: CGFloat?, secondCenter: CGPoint?, secondRadius: CGFloat?, blended: Bool, size: CGSize) {
        
        self.init(texture: texture, color: nil, size: size)

        gradientType = "radial"
        
        shader = radialGradientShader(colors: colors, locations: locations, firstCenter: firstCenter, firstRadius: firstRadius, secondCenter: secondCenter, secondRadius: secondRadius, blended: blended)
        shader?.uniforms = uniforms
    }
    
    
    
    // MARK: Sweep Gradient
    
    
    /**
    
    An SKSpriteNode shaded wtih a sweeping gradient (i.e. a gradient determined by angle).
    
    :param: texture The texture to be shaded.
    
    :param: colors An array of two or more colors.
    
    :param: locations An optional array of monotonically increasing color locations, where 0.0 is the start and 1.0 is the end; 0.0 = 1.0 (neither 0.0 nor 1.0 should be included in this array). The first color in colors is automatically at startAngle; the rest are at these locations. For that reason: locations must contain  colors.count - 1  CGFloats. If the number of locations is nil or different than required: colors will be spread out evenly.
    
    :param: center A optional point in the coordinate system of (0.0, 0.0) to (1.0, 1.0), where (0.0, 0.0) is the bottom left corner of the sprite and (1.0, 1.0) is the top right. Default is (0.5, 0.5).
    
    :param: startAngle An optional angle in radians between 0 and 2Pi, where 0 is to the right along the x axis. The first color will start at this angle; colors will progress counter-clockwise. Default is 0.
    
    :param: blended If true, the given colors will be blended with the texture's existing colors; if false the node will have purely the given colors. Note that if true the keepShape value will be ignored.
    
    :param: keepShape If true, the resulting node will have the shape of the given texture by only drawing where the texture alpha channel is non-zero; if false it will fill the given size. Note that this value will be ignored if blended is true.
    
    :param: size The desired size of the node.
    
    */
    convenience init (sweepGradientWithTexture texture: SKTexture, colors: [UIColor], locations: [CGFloat]?, center: CGPoint?, startAngle: Float?, blended: Bool, keepShape: Bool, size: CGSize) {
        
        self.init(texture: texture, color: nil, size: size)
        
        gradientType = "sweep"
        
        shader = sweepGradientShader(colors: colors, locations: locations, center: center, startAngle: startAngle, blended: blended, keepShape: keepShape)
        shader?.uniforms = uniforms
    }
    
    
    // MARK: - Shaders
    
    
    // MARK: Gamut Gradient

    
    /**
    
    Returns a shader that produces a circle with the gamut of color.
    
    :param: center A optional point in the coordinate system of (0.0, 0.0) to (1.0, 1.0), where (0.0, 0.0) is the bottom left corner of the sprite and (1.0, 1.0) is the top right. Default is (0.5, 0.5).
    
    :param: startAngle An optional angle in radians between 0 and 2Pi, where 0 is to the right along the x axis. Red will start at this angle. Default is 0.  The related uniform is u_startAngle.
    
    :param: blended If true, the given colors will be blended with the texture's existing colors; if false the node will have purely the given colors. Note that if true the keepShape value will be ignored.
    
    :param: keepShape If true, the resulting node will have the shape of the given texture by only drawing where the texture alpha channel is non-zero; if false it will fill the given size. Note that this value will be ignored if blended is true.
    
    :returns: A shader that produces a circle with the gamut of color. This shader makes use of the hsv2rgb method from http://stackoverflow.com/a/17897228/605869
    
    */
    private func gamutGradientShader(#center: CGPoint?, startAngle: Float?, blended: Bool, keepShape: Bool) -> SKShader {
        
        
        // Sanitization
        
        
        // center
        var x : CGFloat = 0.5
        var y : CGFloat = 0.5
        if center != nil {
            x = min(max(center!.x, 0.0), 1.0)
            y = min(max(center!.y, 0.0), 1.0)
        }
        
        // startAngle
        if startAngle != nil {
            self.startAngle = startAngle!
        }
        uniforms.append(u_startAngle)
        
        
        // Shader Creation
        
        
        var gamutGradientShader = "vec3 hsv2rgb(vec3 c) { vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0); vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www); return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y); } float M_PI = 3.1415926535897932384626433832795; void main() { vec2 coord = v_tex_coord.xy; float angle = atan(coord.y, coord.x); angle = mod(angle / (2.0 * M_PI) - u_startAngle, 1.0); float distanceFromCenter = length(coord); vec3 color = hsv2rgb(vec3(angle, distanceFromCenter, 1.0)); gl_FragColor = vec4(color, 1.0); }"
        
        var stringRange : NSRange
        var string = ""
        
        
        // blended
        if blended {

            string = " * texture2D(u_texture, v_tex_coord)"
            stringRange = (gamutGradientShader as NSString).rangeOfString("gl_FragColor = vec4(color, 1.0)")
            gamutGradientShader = gamutGradientShader.insert(string: string, atIndex: stringRange.location + stringRange.length)
            
        } else {
            
            // keepShape
            if keepShape {
                
                string = "vec4 textureColor = texture2D(u_texture, v_tex_coord); if (textureColor.w == 0.0) { discard; } "
                stringRange = (gamutGradientShader as NSString).rangeOfString("vec3 color = hsv2rgb(vec3(angle, distanceFromCenter, 1.0)); ")
                gamutGradientShader = gamutGradientShader.insert(string: string, atIndex: stringRange.location + stringRange.length)
            }
        }
        
        
        // Remap (0, 0)
        string = "coord = coord * 2.0 - vec2(\(2 * x), \(2 * y)); "
        stringRange = (gamutGradientShader as NSString).rangeOfString("vec2 coord = v_tex_coord.xy; ")
        gamutGradientShader = gamutGradientShader.insert(string: string, atIndex: stringRange.location + stringRange.length)
        
        
        return SKShader(source: gamutGradientShader)
    }
    
    
    
    
    // MARK: Linear Gradient
    
    
    /**
    
    Returns an SKShader that creates a linear gradient in the node's texture, from bottom to top, of the colors given.
    
    :param: colors An array of two or more colors.
    
    :param: locations An optional array of monotonically increasing color locations, where 0.0 is the start and 1.0 is the end (neither 0.0 nor 1.0 should be included in this array). The first color in colors is automatically at 0.0; the last is automatically at 1.0; the rest are at the locations in this array. For that reason: locations must contain  colors.count - 2  CGFloats. If the number of locations is nil or different than required: colors will be spread out evenly.
    
    :param: startPoint An optional point from which the gradient should start. If this is not nil then endPoint must also have a value. If it is nil then it will default to the bottom center of the texture (0.5, 0.0).
    
    :param: endPoint An optional point at which the gradient should end. If this is not nil then startPoint must also have a value. If it is nil then it will default to the top center of the texture (0.5, 1.0).
    
    :param: blended If true, the given colors will be blended with the texture's existing colors; if false the node will have purely the given colors. Note that if true the keepShape value will be ignored.
    
    :param: keepShape If true, the resulting node will have the shape of the given texture by only drawing where the texture alpha channel is non-zero; if false it will fill the given size. Note that this value will be ignored if blended is true.
    
    :returns: An SKShader that will produce a linear gradient. Note: the current implementation simply uses the GLSL mix function, which is a linear interpolation. For colors near to each other on the spectrum the results are fine; for very different colors the results can be pretty ugly. If you need a gradient between very different colors then you can simply add more colors in between to narrow the relative distances.
    
    */
    func linearGradientShader(#colors: [UIColor], locations: [CGFloat]?, startPoint: CGPoint?, endPoint: CGPoint?, blended: Bool, keepShape: Bool) -> SKShader {
        
        
        // Sanitization
        
        
        // If there aren't at least two colors: return an empty shader.
        if colors.count < 2 { return SKShader() }
        
        
        // Colors in CGFloat-array form
        var colorFloats = [[CGFloat]]()
        for color in colors {
            colorFloats.append(colorToRGBAComponentCGFloatArray(color))
        }
        
        
        // Locations
        var locationArray = [CGFloat(0.5)]
        if locations != nil {
            
            locationArray.removeLast()
            
            var lastValue : CGFloat = 0.000001
            var newValue : CGFloat = 0.0
            for location in locations! {
                
                newValue = min(max(location, lastValue), 1.0)
                locationArray.append(newValue)
                lastValue = newValue + 0.000001
            }
        }
        
        
        // Start and end points
        var start = CGPoint(x: 0.5, y: 0.0)
        var end = CGPoint(x: 0.5, y: 1.0)
        if startPoint != nil && endPoint != nil {
            
            start = CGPoint(x: min(max(startPoint!.x, 0.0), 1.0), y: min(max(startPoint!.y, 0.0), 1.0))
            end = CGPoint(x: min(max(endPoint!.x, 0.0), 1.0), y: min(max(endPoint!.y, 0.0), 1.0))
        }
        
        
        // 2D Stop Array Creation
        var stopsArray = [start]
        let vector = CGPoint(x: end.x - start.x, y: end.y - start.y)
        
        // colors.count - 2 is the expected number of locations. If the number is different: spread out evenly.
        if locationArray.count == colors.count - 2 {
            
            for var i = 0; i < colors.count - 2; i++ {
                
                let newStopVector = CGPoint(x: vector.x * locationArray[i], y: vector.y * locationArray[i])
                stopsArray.append(CGPoint(x: start.x + newStopVector.x, y: start.y + newStopVector.y))
            }
            
        }   else {
        
            for var i = 0; i < colors.count - 2; i++ {
                
                let stop = (CGFloat(i) + 1.0) / (CGFloat(colors.count) - 1.0)
                let newStopVector = CGPoint(x: vector.x * stop, y: vector.y * stop)
                stopsArray.append(CGPoint(x: start.x + newStopVector.x, y: start.y + newStopVector.y))
            }
        }
        stopsArray.append(end)

        
        // Shader Creation
        
        
        var linearGradientShader = "precision mediump float; void main (void) { vec2 coord = v_tex_coord; vec4 color = mix(color0, color1, smoothstep(dot(stop0, vector), dot(stop1, vector), dot(coord, vector))); gl_FragColor = color; }"
        
        var stringRange : NSRange
        var string = ""
        
        
        // blended
        if blended {
            
            string = " * texture2D(u_texture, coord)"
            stringRange = (linearGradientShader as NSString).rangeOfString("gl_FragColor = color")
            linearGradientShader = linearGradientShader.insert(string: string, atIndex: stringRange.location + stringRange.length)
        } else {
            
            // keepShape
            if keepShape {
                
                string = "vec4 textureColor = texture2D(u_texture, coord); if (textureColor.w == 0.0) { discard; }"
                stringRange = (linearGradientShader as NSString).rangeOfString("smoothstep(dot(stop0, vector), dot(stop1, vector), dot(coord, vector))); ")
                linearGradientShader = linearGradientShader.insert(string: string, atIndex: stringRange.location + stringRange.length)
            }
        }
        
        
        // Add the gradients
        stringRange = (linearGradientShader as NSString).rangeOfString("smoothstep(dot(stop0, vector), dot(stop1, vector), dot(coord, vector))); ")
        for var i = colors.count - 1; i > 1 ; i-- {
            
            string = "color = mix(color, color\(i), smoothstep(dot(stop\(i - 1), vector), dot(stop\(i), vector), dot(coord, vector))); "
            linearGradientShader = linearGradientShader.insert(string: string, atIndex: stringRange.location + stringRange.length)
        }
        
        
        // Add the stops
        stringRange = (linearGradientShader as NSString).rangeOfString("precision mediump float; ")
        for (index, point) in enumerate(stopsArray) {
            
            string = "vec2 stop\(index) = vec2(\(point.x), \(point.y)); "
            linearGradientShader = linearGradientShader.insert(string: string, atIndex: stringRange.location + stringRange.length)
        }
        
        
        // Add the colors
        stringRange = (linearGradientShader as NSString).rangeOfString("precision mediump float; ")
        for (index, components) in enumerate(colorFloats) {
            
            string = "vec4 color\(index) = vec4(\(components[0]), \(components[1]), \(components[2]), \(components[3])); "
            linearGradientShader = linearGradientShader.insert(string: string, atIndex: stringRange.location + stringRange.length)
        }
        
        
        // Add the vectors
        string = "vec2 vector = vec2(\(vector.x), \(vector.y)); "
        stringRange = (linearGradientShader as NSString).rangeOfString("precision mediump float; ")
        linearGradientShader = linearGradientShader.insert(string: string, atIndex: stringRange.location + stringRange.length)

        return SKShader(source: linearGradientShader)
    }

    
    
    // MARK: Radial Gradient
    
    
    /**
    
    An SKShader for a radial gradient between two specified circles. At least one circle must have a radius specified.
    
    :param: texture The texture to be shaded.
    
    :param: colors An array of two or more colors.
    
    :param: locations An optional array of monotonically increasing color locations, where 0.0 is the start and 1.0 is the end (neither 0.0 nor 1.0 should be included in this array). The first color in colors is automatically at 0.0; the last is automatically at 1.0; the rest are at the locations in this array. For that reason: locations must contain  colors.count - 2  CGFloats. If the number of locations is nil or different than required: colors will be spread out evenly.
    
    :param: firstCenter An optional point that specifies the center of the first circle in the coordinate system of (0.0, 0.0) to (1.0, 1.0), where (0.0, 0.0) is the bottom left corner of the sprite and (1.0, 1.0) is the top right. Default is the center of the node.
    
    :param: firstRadius An optional radius of the first circle in the coordinate system of (0.0, 0.0) to (1.0, 1.0), where (0.0, 0.0) is the bottom left corner of the sprite and (1.0, 1.0) is the top right. Default is 0.
    
    :param: secondCenter An optional point that specifies the center of the second circle in the coordinate system of (0.0, 0.0) to (1.0, 1.0), where (0.0, 0.0) is the bottom left corner of the sprite and (1.0, 1.0) is the top right. Default is the center of the node.
    
    :param: secondRadius An optional radius of the second circle in the coordinate system of (0.0, 0.0) to (1.0, 1.0), where (0.0, 0.0) is the bottom left corner of the sprite and (1.0, 1.0) is the top right. Default is 0.
    
    :param: blended If true, the given colors will be blended with the texture's existing colors; if false the node will have purely the given colors. Note that if true the keepShape value will be ignored.
    
    :returns: An SKShader that produced a radial gradient with colors begining at the first circle and ending at the second.
    
    */
    func radialGradientShader (#colors: [UIColor], locations: [CGFloat]?, firstCenter: CGPoint?, firstRadius: CGFloat?, secondCenter: CGPoint?, secondRadius: CGFloat?, blended: Bool) -> SKShader {
        
        
        // Sanitizaton
        
        
        // If there aren't at least two colors: return an empty shader.
        if colors.count < 2 { return SKShader() }
        
        
        // Centers
        
        var center0 = CGPoint(x: 0.5, y: 0.5)
        if firstCenter != nil {
            center0.x = min(max(firstCenter!.x, 0.0), 1.0)
            center0.y = min(max(firstCenter!.y, 0.0), 1.0)
        }
        var center1 = CGPoint(x: 0.5, y: 0.5)
        if secondCenter != nil {
            center1.x = min(max(secondCenter!.x, 0.0), 1.0)
            center1.y = min(max(secondCenter!.y, 0.0), 1.0)
        }
        
        
        // Colors in CGFloat-array form
        var colorFloats = [[CGFloat]]()
        for color in colors {
            colorFloats.append(colorToRGBAComponentCGFloatArray(color))
        }
        
        
        // Locations
        // colors.count - 2 is the expected number of locations. If the number is different: spread out evenly.
        var locationArray = [CGFloat]()
        if locations != nil && locations!.count == colors.count - 2 {
            
            locationArray.append(CGFloat(0.0))
            var lastValue : CGFloat = 0.000001
            var newValue : CGFloat = 0.0
            for location in locations! {
                
                newValue = min(max(location, lastValue), 1.0)
                locationArray.append(newValue)
                lastValue = newValue + 0.000001
            }
            locationArray.append(CGFloat(1.0))
            
        } else {
            
            for var i = 0; i < colors.count; i++ {
                
                let location = CGFloat(i) / CGFloat(colors.count)
                locationArray.append(location)
            }
        }
        
       
        // Radii
        var radius0 : CGFloat = 0.0
        if firstRadius != nil { radius0 = min(max(firstRadius!, 0.0), 1.0) }
        var radius1 : CGFloat = 0.0
        if secondRadius != nil { radius1 = min(max(secondRadius!, 0.0), 1.0) }
        
        
        // Shader Creation
        
        var radialGradientShader = "precision mediump float; void main() { float coordX = v_tex_coord.x; float coordY = v_tex_coord.y; float theSqrt = sqrt(radius1 * radius1 * ((center0X - coordX) * (center0X - coordX) + (center0Y - coordY) * (center0Y - coordY)) - 2.0 * radius0 * radius1 * ((center0X - coordX) * (center1X - coordX) + (center0Y - coordY) * (center1Y - coordY)) + radius0 * radius0 * ((center1X - coordX) * (center1X - coordX) + (center1Y - coordY) * (center1Y - coordY)) - ((center1X * center0Y - coordX * center0Y - center0X * center1Y + coordX * center1Y + center0X * coordY - center1X * coordY) * (center1X * center0Y - coordX * center0Y - center0X * center1Y + coordX * center1Y + center0X * coordY - center1X * coordY))); float t; if(distance(v_tex_coord.xy, vec2(center1X, center1Y)) > radius1) { t = (-radius1 * (radius0 - radius1) + (center0X - center1X) * (center1X - coordX) + (center0Y - center1Y) * (center1Y - coordY) + theSqrt) / ((radius0 - radius1) * (radius0 - radius1) - (center0X - center1X) * (center0X - center1X) - (center0Y - center1Y) * (center0Y - center1Y)); } else { t = (-radius1 * (radius0 - radius1) + (center0X - center1X) * (center1X - coordX) + (center0Y - center1Y) * (center1Y - coordY) - theSqrt) / ((radius0 - radius1) * (radius0 - radius1) - (center0X - center1X) * (center0X - center1X) - (center0Y - center1Y) * (center0Y - center1Y)); } if (t >= 0.0 && t <= 1.0) { vec4 color = mix(color0, color1, smoothstep(location0, location1, t)); gl_FragColor = color; } else { discard; } }"
        
        
        var stringRange : NSRange
        var string = ""
        
        
        // blended
        if blended {
            string = " * texture2D(u_texture, v_tex_coord)"
            stringRange = (radialGradientShader as NSString).rangeOfString("gl_FragColor = color")
            radialGradientShader = radialGradientShader.insert(string: string, atIndex: stringRange.location + stringRange.length)
        }
        
        
        // Add the gradients
        stringRange = (radialGradientShader as NSString).rangeOfString("vec4 color = mix(color0, color1, smoothstep(location0, location1, t)); ")
        for var i = colors.count - 1; i > 1 ; i-- {
            
            string = "color = mix(color, color\(i), smoothstep(location\(i - 1), location\(i), t)); "
            radialGradientShader = radialGradientShader.insert(string: string, atIndex: stringRange.location + stringRange.length)
        }
        
        
        // Add the colors
        stringRange = (radialGradientShader as NSString).rangeOfString("precision mediump float; ")
        for (index, components) in enumerate(colorFloats) {
            
            string = "vec4 color\(index) = vec4(\(components[0]), \(components[1]), \(components[2]), \(components[3])); "
            radialGradientShader = radialGradientShader.insert(string: string, atIndex: stringRange.location + stringRange.length)
        }
        
        
        // Add the locations
        stringRange = (radialGradientShader as NSString).rangeOfString("precision mediump float; ")
        for (index, location) in enumerate(locationArray) {
            
            string = "float location\(index) = \(location); "
            radialGradientShader = radialGradientShader.insert(string: string, atIndex: stringRange.location + stringRange.length)
        }
        
        
        // Add the centers
        string = "float center0X = \(center0.x); float center0Y = \(center0.y); float center1X = \(center1.x); float center1Y = \(center1.y); "
        stringRange = (radialGradientShader as NSString).rangeOfString("precision mediump float; ")
        radialGradientShader = radialGradientShader.insert(string: string, atIndex: stringRange.location + stringRange.length)
        
        
        // Add the radii
        string = "float radius0 = \(radius0); float radius1 = \(radius1); "
        stringRange = (radialGradientShader as NSString).rangeOfString("precision mediump float; ")
        radialGradientShader = radialGradientShader.insert(string: string, atIndex: stringRange.location + stringRange.length)
        
        
        return SKShader(source: radialGradientShader)
    }
    
    
    
    // MARK: Sweep Gradient
    
    
    /**
    
    Returns an SKShader that creates a sweep gradient, starting from the left along the x axis and moving counter-clockwise, of the colors given in the texture of the node.
    
    :param: colors An array of two or more colors.
    
    :param: locations An optional array of monotonically increasing color locations, where 0.0 is the start and 1.0 is the end; 0.0 = 1.0 (neither 0.0 nor 1.0 should be included in this array). The first color in colors is automatically at startAngle; the rest are at these locations. For that reason: locations must contain  colors.count - 1  CGFloats. If the number of locations is nil or different than required: colors will be spread out evenly.
    
    :param: center A optional point in the coordinate system of (0.0, 0.0) to (1.0, 1.0), where (0.0, 0.0) is the bottom left corner of the sprite and (1.0, 1.0) is the top right. Default is (0.5, 0.5).
    
    :param: startAngle An optional angle in radians between 0 and 2Pi, where 0 is to the right along the x axis. The first color will start at this angle; colors will progress counter-clockwise. Default is 0. The related uniform is u_startAngle.
    
    :param: blended If true, the given colors will be blended with the texture's existing colors; if false the node will have purely the given colors. Note that if true the keepShape value will be ignored.
    
    :param: keepShape If true, the resulting node will have the shape of the given texture by only drawing where the texture alpha channel is non-zero; if false it will fill the given size. Note that this value will be ignored if blended is true.
    
    :returns: An SKShader that will produce a sweep gradient. Note: the current implementation simply uses the GLSL mix function, which is a linear interpolation. For colors near to each other on the spectrum the results are fine; for very different colors the results can be pretty ugly. If you need a gradient between very different colors then you can simply add more clors in between to narrow the relative distances.
    
    */
    private func sweepGradientShader(#colors: [UIColor], locations: [CGFloat]?, center: CGPoint?, startAngle: Float?, blended: Bool, keepShape: Bool) -> SKShader {
        
        
        // Sanitization
        
        
        // If there aren't at least two colors: return an empty shader.
        if colors.count < 2 { return SKShader() }
        
        
        // centerPoint
        var centerPoint = CGPoint(x: 0.5, y: 0.5)
        if center != nil { centerPoint = center! }
        let x = min(max(centerPoint.x, 0.0), 1.0)
        let y = min(max(centerPoint.y, 0.0), 1.0)
        
        
        // Colors in CGfloat-array form
        var colorFloats = [[CGFloat]]()
        for color in colors {
            colorFloats.append(colorToRGBAComponentCGFloatArray(color))
        }
        
        
        // Locations
        // colors.count - 1 is the expected number of locations. If the number is different: spread out evenly.
        var locationArray = [CGFloat]()
        if locations != nil && locations!.count == colors.count - 1 {
            
            locationArray.append(CGFloat(0.0))
            var lastValue : CGFloat = 0.000001
            var newValue : CGFloat = 0.0
            for location in locations! {
                
                newValue = min(max(location, lastValue), 1.0)
                locationArray.append(newValue)
                lastValue = newValue + 0.000001
            }
        } else {
            
            for var i = 0; i < colors.count; i++ {
                
                let location = CGFloat(i) / CGFloat(colors.count)
                locationArray.append(location)
            }
        }
        
        
        // startAngle
        if startAngle != nil {
            self.startAngle = startAngle!
        }
        uniforms.append(u_startAngle)
        
        
        // Shader Construction
        
        var sweepGradientShader = "float M_PI = 3.1415926535897932384626433832795; void main() { vec2 coord = v_tex_coord.xy; float angle = atan(coord.y, coord.x); angle = mod(angle / (2.0 * M_PI) - u_startAngle, 1.0); vec4 color = mix(color0, color1, smoothstep(location0, location1, angle)); gl_FragColor = color; }"
        
        
        var stringRange : NSRange
        var string = ""
        
        
        // blended
        if blended {
            
            string = " * texture2D(u_texture, v_tex_coord)"
            stringRange = (sweepGradientShader as NSString).rangeOfString("gl_FragColor = color")
            sweepGradientShader = sweepGradientShader.insert(string: string, atIndex: stringRange.location + stringRange.length)
            
        } else {
            
            // keepShape
            if keepShape {
                
                string = "vec4 textureColor = texture2D(u_texture, v_tex_coord); if (textureColor.w == 0.0) { discard; } "
                stringRange = (sweepGradientShader as NSString).rangeOfString("vec4 color = mix(color0, color1, smoothstep(location0, location1, angle)); ")
                sweepGradientShader = sweepGradientShader.insert(string: string, atIndex: stringRange.location + stringRange.length)
            }
        }
        
        
        // Add the last gradient
        string = "color = mix(color, color0, smoothstep(location\(colors.count - 1), location0 + 1.0, angle)); "
        stringRange = (sweepGradientShader as NSString).rangeOfString("vec4 color = mix(color0, color1, smoothstep(location0, location1, angle)); ")
        sweepGradientShader = sweepGradientShader.insert(string: string, atIndex: stringRange.location + stringRange.length)
        
        
        // Add the gradients
        stringRange = (sweepGradientShader as NSString).rangeOfString("vec4 color = mix(color0, color1, smoothstep(location0, location1, angle)); ")
        for var i = colors.count - 1; i > 1; i-- {
            
            string = "color = mix(color, color\(i), smoothstep(location\(i - 1), location\(i), angle)); "
            sweepGradientShader = sweepGradientShader.insert(string: string, atIndex: stringRange.location + stringRange.length)
        }
        
        
        // Remap (0, 0)
        string = "coord = coord * 2.0 - vec2(\(2 * x), \(2 * y)); "
        stringRange = (sweepGradientShader as NSString).rangeOfString("vec2 coord = v_tex_coord.xy; ")
        sweepGradientShader = sweepGradientShader.insert(string: string, atIndex: stringRange.location + stringRange.length)
        
        
        // Add the locations
        stringRange = (sweepGradientShader as NSString).rangeOfString("float M_PI = 3.1415926535897932384626433832795; ")
        for var i = 0; i < colors.count; i++ {
            
            string = "float location\(i) = \(locationArray[i]); "
            sweepGradientShader = sweepGradientShader.insert(string: string, atIndex: stringRange.location + stringRange.length)
        }
        
        
        // Add the colors
        stringRange = (sweepGradientShader as NSString).rangeOfString("float M_PI = 3.1415926535897932384626433832795; ")
        for (index, components) in enumerate(colorFloats) {
            
            string = "vec4 color\(index) = vec4(\(components[0]), \(components[1]), \(components[2]), \(components[3])); "
            sweepGradientShader = sweepGradientShader.insert(string: string, atIndex: stringRange.location + stringRange.length)
        }
        
        
        println(sweepGradientShader)
                
        return SKShader(source: sweepGradientShader)
    }
    


    // MARK: - Helpers

    /**

    Translates a UIColor into an array of its RGBA components.

    :param: color A color.

    :returns: An array of the RGBA components, with values from 0.0 to 1.0, of the given color.

    */
    private func colorToRGBAComponentCGFloatArray (color: UIColor) -> [CGFloat] {
        
        var red = CGFloat(0.0), green = CGFloat(0.0), blue = CGFloat(0.0), alpha = CGFloat(0.0)
        
        let components = color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return [red, green, blue, alpha]
    }
}


// MARK: - Extensions


extension String {
    
    /**
    
    Creates a new String by inserting a String at the given index into the messaged String. Note that I don't believe that this method is unicode-safe.
    
    :param: string The string to insert.
    
    :param: atIndex The index at which the string should be inserted.
    
    :returns: The original string with the new string inserted at the given index.
    
    */
    func insert(#string: String, atIndex index: Int) -> String {
        
        return  prefix(self, index) + string + suffix(self, count(self) - index)
    }
}