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

Version: 1.3.1

*/

/*
 
 NOTE: Because of a change in Swift 2 / iOS 9, apps now use Metal rather than OpenGL by default. For this version of BDGradientNodes to work you must add PrefersOpenGL = YES to your info.plist, as described in https://forums.developer.apple.com/message/71424#71424
 
*/


import SpriteKit

class BDGradientNode : SKSpriteNode {
    
    
    // MARK: - Properties
    
    
    /// The type of gradient of the instantiated node: gamut, linear, radial, or sweep. (Read Only.)
    private(set) var gradientType = ""
    
    
    // MARK: Uniforms
    
    
    // This array will be filled with the appropriate uniforms and passed to the shader.
    private var uniforms = [SKUniform]()
    
    private let u_blending = SKUniform(name: "u_blending", float: 0.5)
    /// (All Gradients) A number between 0.0 and 1.0. If blending == 0.0, the shader adds no color to the texture; if blending == 1.0, the passed colors are solid; otherwise, the passed colors are blended with those of the texture using the given blending weight. Default is 0.5.
    var blending : Float = 0.5 {
        didSet {
            u_blending.floatValue = blending
        }
    }
    
    private let u_center = SKUniform(name: "u_center", floatVector2: GLKVector2Make(0.5, 0.5))
    /// (Gamut and Sweep) The center of the sweeping gradient in the coordinate system of (0.0, 0.0) to (1.0, 1.0), where (0.0, 0.0) is the bottom left corner of the texture and (1.0, 1.0) is the top right. Default is (0.5, 0.5).
    var center = CGPoint(x: 0.5, y: 0.5) {
        didSet {
            u_center.floatVector2Value = GLKVector2Make(Float(center.x), Float(center.y))
        }
    }
    
    private var u_colors = [SKUniform]()
    private var backupColors = [UIColor]()
    /// (Linear, Radial, and Sweep) The gradient's colors. This can only be updated with an array that contains the same number of colors as the initializaed gradient.
    var colors = [UIColor]() {
        didSet {
            if backupColors.count != colors.count { colors = backupColors }
            else { updateColors() }
        }
        willSet {
            backupColors = colors
        }
    }
    
    private let u_discardOutsideGradient = SKUniform(name: "u_discardOutsideGradient", float: 1.0)
    /// (Gamut, Radial, and Sweep) If true, the non-gradient areas will not be drawn. In particular: outside the radius of the gamut, sweep, or outer radial circle, and inside the inner radial circle; if false, the texture colors will be visible.
    var discardOutsideGradient = true {
        didSet {
            if discardOutsideGradient == true { u_discardOutsideGradient.floatValue = 1.0 }
            if discardOutsideGradient == false { u_discardOutsideGradient.floatValue = 0.0 }
        }
    }
    
    private let u_endPoint = SKUniform(name: "u_endPoint", floatVector2: GLKVector2Make(0.5, 0.0))
    /// (Linear) The point from which the gradient will start. If this is not nil then startPoint must also have a value. If it is nil then it will default to the bottom center of the texture (0.5, 1.0).
    var endPoint = CGPoint(x: 0.5, y: 1.0) {
        didSet {
            u_endPoint.floatVector2Value = GLKVector2Make(Float(endPoint.x), Float(endPoint.y))
            updateLocations()
        }
    }
    
    private let u_firstCenter = SKUniform(name: "u_firstCenter", floatVector2: GLKVector2Make(0.5, 0.5))
    /// (Radial) The center of the first circle in the coordinate system of (0.0, 0.0) to (1.0, 1.0), where (0.0, 0.0) is the bottom left corner of the texture and (1.0, 1.0) is the top right. Default is (0.5, 0.5).
    var firstCenter = CGPoint(x: 0.5, y: 0.5) {
        didSet {
            u_firstCenter.floatVector2Value = GLKVector2Make(Float(firstCenter.x), Float(firstCenter.y))
        }
    }
    
    private let u_firstRadius = SKUniform(name: "u_firstRadius", float: 0.1)
    /// (Radial) The radius of the first circle in the coordinate system of (0.0, 0.0) to (1.0, 1.0), where (0.0, 0.0) is the bottom left corner of the texture and (1.0, 1.0) is the top right. Default is 0.1.
    var firstRadius : Float = 0.1 {
        didSet {
            u_firstRadius.floatValue = firstRadius
        }
    }
    
    private let u_keepTextureShape = SKUniform(name: "u_keepTextureShape", float: 1.0)
    /// (All Gradients) If true, the resulting node will have the shape of the given texture by only drawing where the texture alpha channel is non-zero; if false it will fill the given size.
    var keepTextureShape = true {
        didSet {
            if keepTextureShape == true { u_keepTextureShape.floatValue = 1.0 }
            if keepTextureShape == false { u_keepTextureShape.floatValue = 0.0 }
        }
    }
    
    private var u_locations = [SKUniform]()
    /// (Linear, Radial, and Sweep) An array of monotonically increasing color locations, where 0.0 is the start and 1.0 is the end; neither 0.0 nor 1.0 should be included in this array. The first color in colors is automatically at 0.0; the last is automatically at 1.0; the rest are at the locations in this array. If the number of locations is not appropriate for the initialized gradient, or the values are out of range, locations will be set to nil and the colors will be evenly spread out. Linear and Radial must have (number of colors - 2) locations; Sweep must have (number of colors - 1) locations.
    var locations : [Float]? {
        didSet {
            updateLocations()
        }
    }
    
    private let u_radius = SKUniform(name: "u_radius", float: 1.0)
    /// (Gamut and Sweep) The radius of the gradient circle in the coordinate system of (0.0, 0.0) to (1.0, 1.0), where (0.0, 0.0) is the bottom left corner of the sprite and (1.0, 1.0) is the top right. Default is 1.0.
    var radius : Float = 0.5 {
        didSet {
            u_radius.floatValue = radius
        }
    }
    
    private let u_secondCenter = SKUniform(name: "u_secondCenter", floatVector2: GLKVector2Make(0.5, 0.5))
    /// (Radial Gradient) The center of the second circle in the coordinate system of (0.0, 0.0) to (1.0, 1.0), where (0.0, 0.0) is the bottom left corner of the sprite and (1.0, 1.0) is the top right. Default is (0.5, 0.5).
    var secondCenter = CGPoint(x: 0.5, y: 0.5) {
        didSet {
            u_secondCenter.floatVector2Value = GLKVector2Make(Float(secondCenter.x), Float(secondCenter.y))
        }
    }
    
    private let u_secondRadius = SKUniform(name: "u_secondRadius", float: 0.0)
    /// (Radial) The radius of the second circle in the coordinate system of (0.0, 0.0) to (1.0, 1.0), where (0.0, 0.0) is the bottom left corner of the sprite and (1.0, 1.0) is the top right. Default is 0.5.
    var secondRadius : Float = 0.5 {
        didSet {
            u_secondRadius.floatValue = secondRadius
        }
    }
    
    private let u_startAngle = SKUniform(name: "u_startAngle", float: 0.0)
    /// (Gamut and Sweep) The angle at which the first color of the gradient will start (red for gamut) in radians between 0 and 2Pi, where 0 is to the right along the x axis and the colors proceed counter-clockwise. Default is 0.
    var startAngle : Float = 0.0 {
        didSet {
            u_startAngle.floatValue = startAngle / Float(2 * M_PI) % 1.0
        }
    }
    
    private let u_startPoint = SKUniform(name: "u_startPoint", floatVector2: GLKVector2Make(0.5, 0.0))
    /// (Linear) The point from which the gradient will start. If this is not nil then endPoint must also have a value. If it is nil then it will default to the bottom center of the texture (0.5, 0.0).
    var startPoint = CGPoint(x: 0.5, y: 0.0) {
        didSet {
            u_startPoint.floatVector2Value = GLKVector2Make(Float(startPoint.x), Float(startPoint.y))
            updateLocations()
        }
    }
    
    
    
    // MARK: - Initialization
    
    
    /// Use the appropriate convenience initializer to get your BDGradientNode; this isn't the initializer you're looking for.
    internal override init (texture: SKTexture?, color: UIColor, size: CGSize) {
        
        super.init(texture: texture, color: color, size: size)
    }

    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: Gamut Gradients
    
    
    /**
    
    An SKSpriteNode with the gamut of the spectrum.
    
    - parameter texture: The texture to be shaded.
    
    - parameter center: The center of the sweeping gradient in the coordinate system of (0.0, 0.0) to (1.0, 1.0), where (0.0, 0.0) is the bottom left corner of the texture and (1.0, 1.0) is the top right. Default is (0.5, 0.5).
    
    - parameter radius: The radius of the gradient circle in the coordinate system of (0.0, 0.0) to (1.0, 1.0), where (0.0, 0.0) is the bottom left corner of the sprite and (1.0, 1.0) is the top right. Default is 0.5.
    
    - parameter startAngle: The angle at which the red in the gradient will start in radians between 0 and 2Pi, where 0 is to the right along the x axis and the colors proceed counter-clockwise. Default is 0.
    
    - parameter blending: A number between 0.0 and 1.0. If blending == 0.0, the shader adds no color to the texture; if blending == 1.0, the passed colors are solid; otherwise, the passed colors are blended with those of the texture using the given blending weight. Default is 0.5.
    
    - parameter discardOutsideGradient: If true, the non-gradient areas will not be drawn. In particular: outside the radius of the gamut, sweep, or outer radial circle, and inside the inner radial circle; if false, the texture colors will be visible.
    
    - parameter keepTextureShape: If true, the resulting node will have the shape of the given texture by only drawing where the texture alpha channel is non-zero; if false it will fill the given size. Note that this value will be ignored if blending is true.
    
    - parameter size: The desired size of the node.
    
    */
    convenience init (gamutGradientWithTexture texture: SKTexture, center: CGPoint?, radius: Float?, startAngle: Float?, blending: Float, discardOutsideGradient: Bool, keepTextureShape: Bool, size: CGSize) {

        self.init(texture: texture, color: UIColor.clearColor(), size: size)
        
        gradientType = "gamut"
        
        // Setup Shader
        shader = gamutGradientShader(center: center, radius: radius, startAngle: startAngle, blending: blending, discardOutsideGradient: discardOutsideGradient, keepTextureShape: keepTextureShape)
        shader?.uniforms = uniforms
    }
    

    
    // MARK: Linear Gradient

    
    /**
    
    A SKSpriteNode with a linear gradient from bottom to top in the given texture.
    
    - parameter texture: The texture to be shaded.
    
    - parameter colors: An array of two or more colors.
    
    - parameter locations: An array of monotonically increasing color locations, where 0.0 is the start and 1.0 is the end; neither 0.0 nor 1.0 should be included in this array. The first color in colors is automatically at 0.0; the last is automatically at 1.0; the rest are at the locations in this array. For that reason: locations must contain  colors.count - 2  Floats. If the array is nil or the number of locations is different than required: colors will be spread out evenly.
    
    - parameter startPoint: The point from which the gradient will start. If this is not nil then endPoint must also have a value. If it is nil then it will default to the bottom center of the texture (0.5, 0.0).
    
    - parameter endPoint: The point from which the gradient will start. If this is not nil then startPoint must also have a value. If it is nil then it will default to the bottom center of the texture (0.5, 1.0).
    
    - parameter blending: A number between 0.0 and 1.0. If blending == 0.0, the shader adds no color to the texture; if blending == 1.0, the passed colors are solid; otherwise, the passed colors are blended with those of the texture using the given blending weight. Default is 0.5.
    
    - parameter keepTextureShape: If true, the resulting node will have the shape of the given texture by only drawing where the texture alpha channel is non-zero; if false it will fill the given size. Note that this value will be ignored if blending is true.
    
    - parameter size: The desired size of the node.
    
    */
    convenience init (linearGradientWithTexture texture: SKTexture, colors: [UIColor], locations: [Float]?, startPoint: CGPoint?, endPoint: CGPoint?, blending: Float, keepTextureShape: Bool, size: CGSize) {
        
        self.init(texture: texture, color: UIColor.clearColor(), size: size)
        
        gradientType = "linear"
        self.colors = colors
        
        shader = linearGradientShader(colors: colors, locations: locations, startPoint: startPoint, endPoint: endPoint, blending: blending, keepTextureShape: keepTextureShape)
        shader?.uniforms = uniforms
    }
       
    
    
    // MARK: Radial Gradient
    
    
    /**
    
    An SKSpriteNode with a radial gradient between the two specified circles. At least one circle must have a radius specified. Note that the coordinate system for the firstCenter and secondCenter has its anchor point (0.0, 0.0) at the bottom left of the texture; (texture.size().width, texture.size().height) is at the top right.
    
    - parameter texture: The texture to be shaded.
    
    - parameter colors: An array of two or more colors.
    
    - parameter locations: An array of monotonically increasing color locations, where 0.0 is the start and 1.0 is the end; neither 0.0 nor 1.0 should be included in this array. The first color in colors is automatically at 0.0; the last is automatically at 1.0; the rest are at the locations in this array. For that reason: locations must contain  colors.count - 2  Floats. If the array is nil or the number of locations is different than required: colors will be spread out evenly.
    
    - parameter firstCenter: The center of the first circle in the coordinate system of (0.0, 0.0) to (1.0, 1.0), where (0.0, 0.0) is the bottom left corner of the texture and (1.0, 1.0) is the top right. Default is (0.5, 0.5).
    
    - parameter firstRadius: The radius of the first circle in the coordinate system of (0.0, 0.0) to (1.0, 1.0), where (0.0, 0.0) is the bottom left corner of the texture and (1.0, 1.0) is the top right. Default is 0.1.
    
    - parameter secondCenter: The center of the second circle in the coordinate system of (0.0, 0.0) to (1.0, 1.0), where (0.0, 0.0) is the bottom left corner of the sprite and (1.0, 1.0) is the top right. Default is (0.5, 0.5).
    
    - parameter secondRadius: The radius of the second circle in the coordinate system of (0.0, 0.0) to (1.0, 1.0), where (0.0, 0.0) is the bottom left corner of the sprite and (1.0, 1.0) is the top right. Default is 0.5.
    
    - parameter blending: A number between 0.0 and 1.0. If blending == 0.0, the shader adds no color to the texture; if blending == 1.0, the passed colors are solid; otherwise, the passed colors are blended with those of the texture using the given blending weight. Default is 0.5.
    
    - parameter discardOutsideGradient: If true, the non-gradient areas will not be drawn. In particular: outside the radius of the gamut, sweep, or outer radial circle, and inside the inner radial circle; if false, the texture colors will be visible.
    
    - parameter keepTextureShape: If true, the resulting node will have the shape of the given texture by only drawing where the texture alpha channel is non-zero; if false it will fill the given size. Note that this value will be ignored if blending is true.
    
    - parameter size: The desired size of the node. Note: if this size is not the size of the passed texture then the "circles" will be ellipses.
    
    */
    convenience init (radialGradientWithTexture texture: SKTexture, colors: [UIColor], locations: [Float]?, firstCenter: CGPoint?, firstRadius: Float?, secondCenter: CGPoint?, secondRadius: Float?, blending: Float, discardOutsideGradient: Bool, keepTextureShape: Bool, size: CGSize) {
        
        self.init(texture: texture, color: UIColor.clearColor(), size: size)

        gradientType = "radial"
        self.colors = colors
        
        shader = radialGradientShader(colors: colors, locations: locations, firstCenter: firstCenter, firstRadius: firstRadius, secondCenter: secondCenter, secondRadius: secondRadius, blending: blending, discardOutsideGradient: discardOutsideGradient, keepTextureShape: keepTextureShape)
        shader?.uniforms = uniforms
    }
    
    
    
    // MARK: Sweep Gradient
    
    
    /**
    
    An SKSpriteNode shaded wtih a sweeping gradient (i.e. a gradient determined by angle).
    
    - parameter texture: The texture to be shaded.
    
    - parameter colors: An array of two or more colors.
    
    - parameter locations: An array of monotonically increasing color locations, where 0.0 is the start and 1.0 is the end; 0.0 = 1.0; neither 0.0 nor 1.0 should be included in this array. The first color in colors is automatically at startAngle; the rest are at these locations. For that reason: locations must contain  colors.count - 1  Floats. If the array is nil or the number of locations is different than required: colors will be spread out evenly.
    
    - parameter center: The center of the sweeping gradient in the coordinate system of (0.0, 0.0) to (1.0, 1.0), where (0.0, 0.0) is the bottom left corner of the texture and (1.0, 1.0) is the top right. Default is (0.5, 0.5).
    
    - parameter radius: The radius of the gradient circle in the coordinate system of (0.0, 0.0) to (1.0, 1.0), where (0.0, 0.0) is the bottom left corner of the sprite and (1.0, 1.0) is the top right. Default is 0.5.
    
    - parameter startAngle: The angle at which the first color of the gradient will start in radians between 0 and 2Pi, where 0 is to the right along the x axis and the colors proceed counter-clockwise. Default is 0.
    
    - parameter blending: A number between 0.0 and 1.0. If blending == 0.0, the shader adds no color to the texture; if blending == 1.0, the passed colors are solid; otherwise, the passed colors are blended with those of the texture using the given blending weight. Default is 0.5.
    
    - parameter discardOutsideGradient: If true, the non-gradient areas will not be drawn. In particular: outside the radius of the gamut, sweep, or outer radial circle, and inside the inner radial circle; if false, the texture colors will be visible.
    
    - parameter keepTextureShape: If true, the resulting node will have the shape of the given texture by only drawing where the texture alpha channel is non-zero; if false it will fill the given size. Note that this value will be ignored if blending is true.
    
    - parameter size: The desired size of the node.
    
    */
    convenience init (sweepGradientWithTexture texture: SKTexture, colors: [UIColor], locations: [Float]?, center: CGPoint?, radius: Float?, startAngle: Float?, blending: Float, discardOutsideGradient: Bool, keepTextureShape: Bool, size: CGSize) {
        
        self.init(texture: texture, color: UIColor.clearColor(), size: size)
        
        gradientType = "sweep"
        self.colors = colors
        
        shader = sweepGradientShader(colors: colors, locations: locations, center: center, radius: radius, startAngle: startAngle, blending: blending, discardOutsideGradient: discardOutsideGradient, keepTextureShape: keepTextureShape)
        shader?.uniforms = uniforms
    }
    
    
    
    // MARK: - Shaders
    
    
    // MARK: Gamut Gradient

    
    /**
    
    Returns a shader that produces a circle with the gamut of color.
    
    - parameter center: The center of the sweeping gradient in the coordinate system of (0.0, 0.0) to (1.0, 1.0), where (0.0, 0.0) is the bottom left corner of the texture and (1.0, 1.0) is the top right. Default is (0.5, 0.5).
    
    - parameter radius: The radius of the gradient circle in the coordinate system of (0.0, 0.0) to (1.0, 1.0), where (0.0, 0.0) is the bottom left corner of the sprite and (1.0, 1.0) is the top right. Default is 0.5.
    
    - parameter startAngle: The angle at which the red in the gradient will start in radians between 0 and 2Pi, where 0 is to the right along the x axis and the colors proceed counter-clockwise. Default is 0.
    
    - parameter blending: A number between 0.0 and 1.0. If blending == 0.0, the shader adds no color to the texture; if blending == 1.0, the passed colors are solid; otherwise, the passed colors are blended with those of the texture using the given blending weight. Default is 0.5.
    
    - parameter discardOutsideGradient: If true, the non-gradient areas will not be drawn. In particular: outside the radius of the gamut, sweep, or outer radial circle, and inside the inner radial circle; if false, the texture colors will be visible.
    
    - parameter keepTextureShape: If true, the resulting node will have the shape of the given texture by only drawing where the texture alpha channel is non-zero; if false it will fill the given size. Note that this value will be ignored if blending is true.
    
    - returns: A shader that produces a circle with the gamut of color. This shader makes use of the hsv2rgb method from http://stackoverflow.com/a/17897228/605869
    
    */
    private func gamutGradientShader(center center: CGPoint?, radius: Float?, startAngle: Float?, blending: Float, discardOutsideGradient: Bool, keepTextureShape: Bool) -> SKShader {
        
        
        // Sanitization
        
        // blending
        self.blending = min(max(blending, 0.0), 1.0)
        uniforms.append(u_blending)
        
        // center
        if center != nil {
            self.center = CGPoint(x: min(max(center!.x, 0.0), 1.0), y: min(max(center!.y, 0.0), 1.0))
        }
        uniforms.append(u_center)
        
        // discardOutsideGradient
        self.discardOutsideGradient = discardOutsideGradient
        uniforms.append(u_discardOutsideGradient)
        
        // keepTextureShape
        self.keepTextureShape = keepTextureShape
        uniforms.append(u_keepTextureShape)
        
        // radius
        if radius != nil {
            self.radius = min(max(radius!, 0.0), 1.0)
        }
        uniforms.append(u_radius)
        
        // startAngle
        if startAngle != nil {
            self.startAngle = startAngle!
        }
        uniforms.append(u_startAngle)
        
        
        // Shader Creation
        
        let gamutGradientShader = "highp float; vec3 hsv2rgb(vec3 c) { vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0); vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www); return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y); } float M_PI = 3.1415926535897932384626433832795; vec4 color; void main() { vec2 coord = v_tex_coord.xy - u_center; if (u_keepTextureShape == 1.0) { vec4 textureColor = texture2D(u_texture, v_tex_coord); if (textureColor.w == 0.0) { discard; } } if (distance(coord, vec2(0.0, 0.0)) > u_radius) { if (u_discardOutsideGradient == 1.0) { discard; } else { gl_FragColor = texture2D(u_texture, v_tex_coord); return; } } if (u_blending == 0.0) { gl_FragColor = texture2D(u_texture, v_tex_coord); return; } float angle = atan(coord.y, coord.x); angle = mod(angle / (2.0 * M_PI) - u_startAngle, 1.0); float distanceFromCenter = length(coord); color = vec4(hsv2rgb(vec3(angle, distanceFromCenter, 1.0)), 1.0); if (u_blending < 1.0) { color = mix(color, texture2D(u_texture, v_tex_coord), 1.0 - u_blending); } gl_FragColor = color; }"
        
        
        return SKShader(source: gamutGradientShader)
    }
    
    
    
    // MARK: Linear Gradient
    
    
    /**
    
    Returns an SKShader that creates a linear gradient in the node's texture, from bottom to top, of the colors given.
    
    - parameter colors: An array of two or more colors.
    
    - parameter locations: An array of monotonically increasing color locations, where 0.0 is the start and 1.0 is the end; neither 0.0 nor 1.0 should be included in this array. The first color in colors is automatically at 0.0; the last is automatically at 1.0; the rest are at the locations in this array. For that reason: locations must contain  colors.count - 2  Floats. If the array is nil or the number of locations is different than required: colors will be spread out evenly.
    
    - parameter startPoint: The point from which the gradient will start. If this is not nil then endPoint must also have a value. If it is nil then it will default to the bottom center of the texture (0.5, 0.0).
    
    - parameter endPoint: The point from which the gradient will start. If this is not nil then startPoint must also have a value. If it is nil then it will default to the bottom center of the texture (0.5, 1.0).
    
    - parameter blending: A number between 0.0 and 1.0. If blending == 0.0, the shader adds no color to the texture; if blending == 1.0, the passed colors are solid; otherwise, the passed colors are blended with those of the texture using the given blending weight. Default is 0.5.
    
    - parameter keepTextureShape: If true, the resulting node will have the shape of the given texture by only drawing where the texture alpha channel is non-zero; if false it will fill the given size. Note that this value will be ignored if blending is true.
    
    - returns: An SKShader that will produce a linear gradient. Note: the current implementation simply uses the GLSL mix function, which is a linear interpolation. For colors near to each other on the spectrum the results are fine; for very different colors the results can be pretty ugly. If you need a gradient between very different colors then you can simply add more colors in between to narrow the relative distances.
    
    */
    private func linearGradientShader(colors colors: [UIColor], locations: [Float]?, startPoint: CGPoint?, endPoint: CGPoint?, blending: Float, keepTextureShape: Bool) -> SKShader {
        
        
        // Sanitization and Uniforms
        
        // If there aren't at least two colors: return an empty shader.
        if colors.count < 2 { return SKShader() }
        
        
        // blending
        self.blending = min(max(blending, 0.0), 1.0)
        uniforms.append(u_blending)
        
        
        // Colors in CGFloat-array form
        var colorFloats = [[Float]]()
        for color in colors {
            colorFloats.append(colorToRGBAComponentFloatArray(color))
        }
        
        
        // Color uniforms
        for (index, color) in colorFloats.enumerate() {
            
            let vector4 = GLKVector4Make(color[0], color[1], color[2], color[3])
            let colorUniform = SKUniform(name: "u_color\(index)", floatVector4: vector4)
            u_colors.append(colorUniform)
            uniforms.append(colorUniform)
        }
        
        
        // keepTextureShape
        self.keepTextureShape = keepTextureShape
        uniforms.append(u_keepTextureShape)
        
        
        // Locations
        var locationArray = [Float]()
        if locations != nil && locations!.count == colors.count - 2 {
            
            var lastValue : Float = 0.000001
            var newValue : Float = 0.0
            for location in locations! {
                
                newValue = min(max(location, lastValue), 1.0)
                locationArray.append(newValue)
                lastValue = newValue + 0.000001
            }
            
        } else {
            
            for var i = 0; i < colors.count - 2; i++ {
                
                let location = (Float(i) + 1.0) / (Float(colors.count) - 1.0)
                locationArray.append(location)
            }
        }
        self.locations = locationArray
        
        
        // Start and end points
        var start = CGPoint(x: 0.5, y: 0.0)
        var end = CGPoint(x: 0.5, y: 1.0)
        if startPoint != nil && endPoint != nil {
            
            start = CGPoint(x: min(max(startPoint!.x, 0.0), 1.0), y: min(max(startPoint!.y, 0.0), 1.0))
            end = CGPoint(x: min(max(endPoint!.x, 0.0), 1.0), y: min(max(endPoint!.y, 0.0), 1.0))
        }
        self.startPoint = start
        uniforms.append(u_startPoint)
        self.endPoint = end
        uniforms.append(u_endPoint)
        
        
        // Location uniforms
        let vector = CGPoint(x: self.endPoint.x - self.startPoint.x, y: self.endPoint.y - self.startPoint.y)
        for (index, location) in locationArray.enumerate() {
            
            let vector2 = GLKVector2Make(Float(self.startPoint.x) + location * Float(vector.x), Float(self.startPoint.y) + location * Float(vector.y))
            let locationUniform = SKUniform(name: "u_stop\(index + 1)", floatVector2: vector2)
            u_locations.append(locationUniform)
            uniforms.append(locationUniform)
        }
        
        
        // Shader Creation
        
        
        var linearGradientShader = "highp float; vec4 color; void main (void) { vec2 coord = v_tex_coord; if (u_keepTextureShape == 1.0) { vec4 textureColor = texture2D(u_texture, coord); if (textureColor.w == 0.0) { discard; } } if (u_blending == 0.0) { gl_FragColor = texture2D(u_texture, v_tex_coord); return; } vec2 vector = vec2(u_endPoint.x - u_startPoint.x, u_endPoint.y - u_startPoint.y); if (u_blending < 1.0) { color = mix(color, texture2D(u_texture, v_tex_coord), 1.0 - u_blending); } gl_FragColor = color; }"
        
        var stringRange : NSRange
        var string = ""
        
        
        // Add the gradients
        stringRange = (linearGradientShader as NSString).rangeOfString("vec2 vector = vec2(u_endPoint.x - u_startPoint.x, u_endPoint.y - u_startPoint.y); ")
        if colors.count == 2 {
            
            string = "color = mix(u_color0, u_color1, smoothstep(dot(u_startPoint, vector), dot(u_endPoint, vector), dot(coord, vector))); "
            linearGradientShader = linearGradientShader.insert(string: string, atIndex: stringRange.location + stringRange.length)
            
        } else {
            
            for var i = colors.count - 1; i > 0 ; i-- {
                
                if i == 1 {
                    
                 string = "color = mix(u_color0, u_color1, smoothstep(dot(u_startPoint, vector), dot(u_stop\(i), vector), dot(coord, vector))); "
                    
                } else if i == colors.count - 1 {
                    
                    string = "color = mix(color, u_color\(i), smoothstep(dot(u_stop\(i - 1), vector), dot(u_endPoint, vector), dot(coord, vector))); "
                    
                } else {
                    
                    string = "color = mix(color, u_color\(i), smoothstep(dot(u_stop\(i - 1), vector), dot(u_stop\(i), vector), dot(coord, vector))); "
                }
                
                linearGradientShader = linearGradientShader.insert(string: string, atIndex: stringRange.location + stringRange.length)
            }
        }
        

        return SKShader(source: linearGradientShader)
    }
    
   
    
    // MARK: Radial Gradient
    
    
    /**
    
    An SKShader for a radial gradient between two specified circles. At least one circle must have a radius specified.
    
    - parameter colors: An array of two or more colors.
    
    - parameter locations: An array of monotonically increasing color locations, where 0.0 is the start and 1.0 is the end; neither 0.0 nor 1.0 should be included in this array. The first color in colors is automatically at 0.0; the last is automatically at 1.0; the rest are at the locations in this array. For that reason: locations must contain  colors.count - 2  Floats. If the array is nil or the number of locations is different than required: colors will be spread out evenly.
    
    - parameter firstCenter: The center of the first circle in the coordinate system of (0.0, 0.0) to (1.0, 1.0), where (0.0, 0.0) is the bottom left corner of the texture and (1.0, 1.0) is the top right. Default is (0.5, 0.5).
    
    - parameter firstRadius: The radius of the first circle in the coordinate system of (0.0, 0.0) to (1.0, 1.0), where (0.0, 0.0) is the bottom left corner of the texture and (1.0, 1.0) is the top right. Default is 0.1.
    
    - parameter secondCenter: The center of the second circle in the coordinate system of (0.0, 0.0) to (1.0, 1.0), where (0.0, 0.0) is the bottom left corner of the sprite and (1.0, 1.0) is the top right. Default is (0.5, 0.5).
    
    - parameter secondRadius: The radius of the second circle in the coordinate system of (0.0, 0.0) to (1.0, 1.0), where (0.0, 0.0) is the bottom left corner of the sprite and (1.0, 1.0) is the top right. Default is 0.5.
    
    - parameter blending: A number between 0.0 and 1.0. If blending == 0.0, the shader adds no color to the texture; if blending == 1.0, the passed colors are solid; otherwise, the passed colors are blended with those of the texture using the given blending weight. Default is 0.5.
    
    - parameter discardOutsideGradient: If true, the non-gradient areas will not be drawn. In particular: outside the radius of the gamut, sweep, or outer radial circle, and inside the inner radial circle; if false, the texture colors will be visible.
    
    - parameter keepTextureShape: If true, the resulting node will have the shape of the given texture by only drawing where the texture alpha channel is non-zero; if false it will fill the given size. Note that this value will be ignored if blending is true.
    
    - returns: An SKShader that produced a radial gradient with colors begining at the first circle and ending at the second.
    
    */
    private func radialGradientShader (colors colors: [UIColor], locations: [Float]?, firstCenter: CGPoint?, firstRadius: Float?, secondCenter: CGPoint?, secondRadius: Float?, blending: Float, discardOutsideGradient: Bool, keepTextureShape: Bool) -> SKShader {
        
        
        // Sanitizaton
        
        // If there aren't at least two colors: return an empty shader.
        if colors.count < 2 { return SKShader() }
        
        
        // blending
        self.blending = min(max(blending, 0.0), 1.0)
        uniforms.append(u_blending)
        
        
        // discardOutsideGradient
        self.discardOutsideGradient = discardOutsideGradient
        uniforms.append(u_discardOutsideGradient)
        
        
        // keepTextureShape
        self.keepTextureShape = keepTextureShape
        uniforms.append(u_keepTextureShape)
        
        
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
        self.firstCenter = center0
        uniforms.append(u_firstCenter)
        self.secondCenter = center1
        uniforms.append(u_secondCenter)
        
        
        // Colors in CGFloat-array form
        var colorFloats = [[Float]]()
        for color in colors {
            colorFloats.insert(colorToRGBAComponentFloatArray(color), atIndex: 0)
        }
        
        
        // Color uniforms
        for (index, color) in colorFloats.enumerate() {
            
            let vector4 = GLKVector4Make(color[0], color[1], color[2], color[3])
            let colorUniform = SKUniform(name: "u_color\(index)", floatVector4: vector4)
            u_colors.append(colorUniform)
            uniforms.append(colorUniform)
        }
        
        
        // Locations
        // colors.count - 2 is the expected number of locations. If the number is different: spread out evenly.
        var locationArray = [Float]()
        if locations != nil && locations!.count == colors.count - 2 {
            
            var lastValue : Float = 0.000001
            var newValue : Float = 0.0
            for location in locations! {
                
                newValue = min(max(location, lastValue), 1.0)
                locationArray.append(newValue)
                lastValue = newValue + 0.000001
            }
            
        } else {
            
            for var i = 1; i < colors.count - 1; i++ {
                
                let location = Float(i) / Float(colors.count - 1)
                locationArray.append(location)
            }
        }
        self.locations = locationArray
        
        
        // Location uniforms
        for (index, location) in locationArray.enumerate() {
            
            let locationUniform = SKUniform(name: "u_location\(index + 1)", float: location)
            u_locations.append(locationUniform)
            uniforms.append(locationUniform)
        }
        
       
        // Radii
        if firstRadius != nil { self.firstRadius = min(max(firstRadius!, 0.0), 1.0) }
        uniforms.append(u_firstRadius)
        if secondRadius != nil { self.secondRadius = min(max(secondRadius!, 0.0), 1.0) }
        uniforms.append(u_secondRadius)
        
        
        // Shader Creation
        
        var radialGradientShader = "highp float; vec4 color; float center0X = u_firstCenter.x; float center0Y = u_firstCenter.y; float center1X = u_secondCenter.x; float center1Y = u_secondCenter.y; float location0 = 0.0; void main() { if (u_keepTextureShape == 1.0) { vec4 textureColor = texture2D(u_texture, v_tex_coord); if (textureColor.w == 0.0) { discard; } } float coordX = v_tex_coord.x; float coordY = v_tex_coord.y; float root = sqrt(u_secondRadius * u_secondRadius * ((center0X - coordX) * (center0X - coordX) + (center0Y - coordY) * (center0Y - coordY)) - 2.0 * u_firstRadius * u_secondRadius * ((center0X - coordX) * (center1X - coordX) + (center0Y - coordY) * (center1Y - coordY)) + u_firstRadius * u_firstRadius * ((center1X - coordX) * (center1X - coordX) + (center1Y - coordY) * (center1Y - coordY)) - ((center1X * center0Y - coordX * center0Y - center0X * center1Y + coordX * center1Y + center0X * coordY - center1X * coordY) * (center1X * center0Y - coordX * center0Y - center0X * center1Y + coordX * center1Y + center0X * coordY - center1X * coordY))); float t; if(distance(v_tex_coord.xy, vec2(center1X, center1Y)) > u_secondRadius) { t = (-u_secondRadius * (u_firstRadius - u_secondRadius) + (center0X - center1X) * (center1X - coordX) + (center0Y - center1Y) * (center1Y - coordY) + root) / ((u_firstRadius - u_secondRadius) * (u_firstRadius - u_secondRadius) - (center0X - center1X) * (center0X - center1X) - (center0Y - center1Y) * (center0Y - center1Y)); } else { t = (-u_secondRadius * (u_firstRadius - u_secondRadius) + (center0X - center1X) * (center1X - coordX) + (center0Y - center1Y) * (center1Y - coordY) - root) / ((u_firstRadius - u_secondRadius) * (u_firstRadius - u_secondRadius) - (center0X - center1X) * (center0X - center1X) - (center0Y - center1Y) * (center0Y - center1Y)); } if (t > 0.0 && t <= 1.0) { if (u_blending == 0.0) { gl_FragColor = texture2D(u_texture, v_tex_coord); return; } if (u_blending < 1.0) { color = mix(color, texture2D(u_texture, v_tex_coord), 1.0 - u_blending); } gl_FragColor = color; } else { if (u_discardOutsideGradient == 1.0) { discard; } else { gl_FragColor = texture2D(u_texture, v_tex_coord); return; } } }"
        
        
        var stringRange : NSRange
        var string = ""
        
        
        // Add the gradients
        if colors.count == 2 {
            
            stringRange = (radialGradientShader as NSString).rangeOfString("if (u_blending == 0.0) { gl_FragColor = texture2D(u_texture, v_tex_coord); return; } ")
            string = "color = mix(u_color0, u_color1, smoothstep(location0, location1, t)); "
            radialGradientShader = radialGradientShader.insert(string: string, atIndex: stringRange.location + stringRange.length)
            
        } else {
            
            stringRange = (radialGradientShader as NSString).rangeOfString("if (u_blending == 0.0) { gl_FragColor = texture2D(u_texture, v_tex_coord); return; } ")
            
            for var i = colors.count - 1; i > 1 ; i-- {
                
                if i == colors.count - 1 {
                    
                    string = "color = mix(color, u_color\(i), smoothstep(u_location\(i - 1), location\(i), t)); "
                    radialGradientShader = radialGradientShader.insert(string: string, atIndex: stringRange.location + stringRange.length)
                    
                } else {
                
                    string = "color = mix(color, u_color\(i), smoothstep(u_location\(i - 1), u_location\(i), t)); "
                    radialGradientShader = radialGradientShader.insert(string: string, atIndex: stringRange.location + stringRange.length)
                }
            }
            
            string = "vec4 color = mix(u_color0, u_color1, smoothstep(location0, u_location1, t)); "
            radialGradientShader = radialGradientShader.insert(string: string, atIndex: stringRange.location + stringRange.length)
        }
        
        
        // Add the final locations
        stringRange = (radialGradientShader as NSString).rangeOfString("float location0 = 0.0; ")
        string = "float location\(colors.count - 1) = 1.0; "
        radialGradientShader = radialGradientShader.insert(string: string, atIndex: stringRange.location + stringRange.length)
        
        return SKShader(source: radialGradientShader)
    }
    
    
    
    // MARK: Sweep Gradient
    
    
    /**
    
    Returns an SKShader that creates a sweep gradient, starting from the left along the x axis and moving counter-clockwise, of the colors given in the texture of the node.
    
    - parameter colors: An array of two or more colors.
    
    - parameter locations: An array of monotonically increasing color locations, where 0.0 is the start and 1.0 is the end; 0.0 = 1.0; neither 0.0 nor 1.0 should be included in this array. The first color in colors is automatically at startAngle; the rest are at these locations. For that reason: locations must contain  colors.count - 1  Floats. If the array is nil or the number of locations is different than required: colors will be spread out evenly.
    
    - parameter center: The center of the sweeping gradient in the coordinate system of (0.0, 0.0) to (1.0, 1.0), where (0.0, 0.0) is the bottom left corner of the texture and (1.0, 1.0) is the top right. Default is (0.5, 0.5).
    
    - parameter radius: The radius of the gradient circle in the coordinate system of (0.0, 0.0) to (1.0, 1.0), where (0.0, 0.0) is the bottom left corner of the sprite and (1.0, 1.0) is the top right. Default is 0.5.
    
    - parameter startAngle: The angle at which the first color of the gradient will start in radians between 0 and 2Pi, where 0 is to the right along the x axis and the colors proceed counter-clockwise. Default is 0.
    
    - parameter blending: A number between 0.0 and 1.0. If blending == 0.0, the shader adds no color to the texture; if blending == 1.0, the passed colors are solid; otherwise, the passed colors are blended with those of the texture using the given blending weight. Default is 0.5.
    
    - parameter discardOutsideGradient: If true, the non-gradient areas will not be drawn. In particular: outside the radius of the gamut, sweep, or outer radial circle, and inside the inner radial circle; if false, the texture colors will be visible.
    
    - parameter keepTextureShape: If true, the resulting node will have the shape of the given texture by only drawing where the texture alpha channel is non-zero; if false it will fill the given size. Note that this value will be ignored if blending is true.
    
    - returns: An SKShader that will produce a sweep gradient. Note: the current implementation simply uses the GLSL mix function, which is a linear interpolation. For colors near to each other on the spectrum the results are fine; for very different colors the results can be pretty ugly. If you need a gradient between very different colors then you can simply add more clors in between to narrow the relative distances.
    
    */
    private func sweepGradientShader(colors colors: [UIColor], locations: [Float]?, center: CGPoint?, radius: Float?, startAngle: Float?, blending: Float, discardOutsideGradient: Bool, keepTextureShape: Bool) -> SKShader {
        
        
        // Sanitization
        
        // If there aren't at least two colors: return an empty shader.
        if colors.count < 2 { return SKShader() }
        
        
        // blending
        self.blending = min(max(blending, 0.0), 1.0)
        uniforms.append(u_blending)
        
        
        // discardOutsideGradient
        self.discardOutsideGradient = discardOutsideGradient
        uniforms.append(u_discardOutsideGradient)
        
        
        // center
        if center != nil {
            self.center = CGPoint(x: min(max(center!.x, 0.0), 1.0), y: min(max(center!.y, 0.0), 1.0))
        }
        uniforms.append(u_center)
        
        
        // Colors in Float-array form
        var colorFloats = [[Float]]()
        for color in colors {
            colorFloats.append(colorToRGBAComponentFloatArray(color))
        }
        
        
        // Color uniforms
        for (index, color) in colorFloats.enumerate() {
            
            let vector4 = GLKVector4Make(color[0], color[1], color[2], color[3])
            let colorUniform = SKUniform(name: "u_color\(index)", floatVector4: vector4)
            u_colors.append(colorUniform)
            uniforms.append(colorUniform)
        }
        
        
        self.keepTextureShape = keepTextureShape
        uniforms.append(u_keepTextureShape)
        
        
        // Locations
        // colors.count - 1 is the expected number of locations. If the number is different: spread out evenly.
        var locationArray = [Float]()
        if locations != nil && locations!.count == colors.count - 1 {
            
            var lastValue : Float = 0.000001
            var newValue : Float = 0.0
            for location in locations! {
                
                newValue = min(max(location, lastValue), 1.0)
                locationArray.append(newValue)
                lastValue = newValue + 0.000001
            }
        } else {
            
            for var i = 1; i < colors.count; i++ {
                
                let location = Float(i) / Float(colors.count)
                locationArray.append(location)
            }
        }
        self.locations = locationArray
        
        
        // Location uniforms
        for (index, location) in locationArray.enumerate() {
            
            let locationUniform = SKUniform(name: "u_location\(index + 1)", float: location)
            u_locations.append(locationUniform)
            uniforms.append(locationUniform)
        }
        
        
        // radius
        if radius != nil {
            self.radius = min(max(radius!, 0.0), 1.0)
        }
        uniforms.append(u_radius)
        
        
        // startAngle
        if startAngle != nil {
            self.startAngle = startAngle!
        }
        uniforms.append(u_startAngle)
        
        
        // Shader Construction
        
        var sweepGradientShader = "highp float; float M_PI = 3.1415926535897932384626433832795; float location0 = 0.0; void main() { vec2 coord = v_tex_coord.xy - u_center; if (distance(coord, vec2(0.0, 0.0)) > u_radius) { if (u_discardOutsideGradient == 1.0) { discard; } else { gl_FragColor = texture2D(u_texture, v_tex_coord); return; } }  if (u_keepTextureShape == 1.0) { vec4 textureColor = texture2D(u_texture, v_tex_coord); if (textureColor.w == 0.0) { discard; } } if (u_blending == 0.0) { gl_FragColor = texture2D(u_texture, v_tex_coord); return; } float angle = atan(coord.y, coord.x); angle = mod(angle / (2.0 * M_PI) - u_startAngle, 1.0); vec4 color = mix(u_color0, u_color1, smoothstep(location0, u_location1, angle)); if (u_blending < 1.0) { color = mix(color, texture2D(u_texture, v_tex_coord), 1.0 - u_blending); } gl_FragColor = color; }"
        
        
        var stringRange : NSRange
        var string = ""
        
        
        // Add the last gradient
        string = "color = mix(color, u_color0, smoothstep(u_location\(colors.count - 1), location0 + 1.0, angle)); "
        stringRange = (sweepGradientShader as NSString).rangeOfString("vec4 color = mix(u_color0, u_color1, smoothstep(location0, u_location1, angle)); ")
        sweepGradientShader = sweepGradientShader.insert(string: string, atIndex: stringRange.location + stringRange.length)
        
        
        // Add the gradients
        stringRange = (sweepGradientShader as NSString).rangeOfString("vec4 color = mix(u_color0, u_color1, smoothstep(location0, u_location1, angle)); ")
        for var i = colors.count - 1; i > 1; i-- {
            
            string = "color = mix(color, u_color\(i), smoothstep(u_location\(i - 1), u_location\(i), angle)); "
            sweepGradientShader = sweepGradientShader.insert(string: string, atIndex: stringRange.location + stringRange.length)
        }
        

        return SKShader(source: sweepGradientShader)
    }
    


    // MARK: - Helpers

    
    /**

    Translates a UIColor into an array of its RGBA components.

    - parameter color: A color.

    - returns: An array of the RGBA components, with values from 0.0 to 1.0, of the given color.

    */
    private func colorToRGBAComponentFloatArray (color: UIColor) -> [Float] {
        
        var red = CGFloat(0.0), green = CGFloat(0.0), blue = CGFloat(0.0), alpha = CGFloat(0.0)
        
        let components = color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return [Float(red), Float(green), Float(blue), Float(alpha)]
    }
    
    
    /**
    
    Sets up self.locations with default locations.
    
    */
    private func defaultLocations () {
        
        var locationArray = [Float]()
        
        if gradientType == "linear" || gradientType == "radial" {
            for var i = 0; i < colors.count - 2; i++ {
                
                let location = (Float(i) + 1.0) / (Float(colors.count) - 1.0)
                locationArray.append(location)
            }
            
        } else if gradientType == "sweep" {
            
            for var i = 0; i < colors.count - 1; i++ {
                
                let location = (Float(i) + 1.0) / (Float(colors.count) - 1.0)
                locationArray.append(location)
            }
        }
    
        if locationArray.count != 0 { locations = locationArray }
    }
    
    
    /**
    
    Updates the uniforms in u_colors with the values in self.colors.
    
    */
    private func updateColors () {
        
        if !u_colors.isEmpty && u_colors.count == colors.count {
            if gradientType != "gamut" {
                for var i = 0; i < colors.count; i++ {
                    let colorArray = colorToRGBAComponentFloatArray(colors[i])
                    let vector4 = GLKVector4Make(colorArray[0], colorArray[1], colorArray[2], colorArray[3])
                    u_colors[i].floatVector4Value = vector4
                }
            }
        }
    }
    
    
    /**
    
    Updates the uniforms in u_locations with the values in self.locations.

    */
    private func updateLocations () {

        // Sanitization
        
        if locations != nil {

            if gradientType == "linear" || gradientType == "radial" { if locations!.count != colors.count - 2 { defaultLocations(); return } }
            else if gradientType == "sweep" { if locations!.count != colors.count - 1 { defaultLocations(); return } }
            else {
                for location in locations! {
                    if location <= 0 || location >= 1 { defaultLocations(); return }
                }
            }
            
        } else {
            defaultLocations()
        }
        
        
        // Update uniforms
        
        if !u_locations.isEmpty {
            if gradientType == "linear" {
                
                let vector = CGPoint(x: endPoint.x - startPoint.x, y: endPoint.y - startPoint.y)
                for var i = 0; i < u_locations.count; i++ {
                    let vector2 = GLKVector2Make(Float(startPoint.x) + locations![i] * Float(vector.x), Float(startPoint.y) + locations![i] * Float(vector.y))
                    u_locations[i].floatVector2Value = vector2
                }
                
            } else if gradientType == "radial" || gradientType == "sweep" {
                for var i = 0; i < u_locations.count; i++ {
                    u_locations[i].floatValue = locations![i]
                }
            }
        }
    }
}



// MARK: - Extensions


extension String {
    
    /**
    
    Creates a new String by inserting a String at the given index into the messaged String. Note that I don't believe that this method is unicode-safe.
    
    - parameter string: The string to insert.
    
    - parameter atIndex: The index at which the string should be inserted.
    
    - returns: The original string with the new string inserted at the given index.
    
    */
    func insert(string string: String, atIndex index: Int) -> String {
        
        return  String(self.characters.prefix(index)) + string + String(self.characters.suffix(self.characters.count - index))
    }
}