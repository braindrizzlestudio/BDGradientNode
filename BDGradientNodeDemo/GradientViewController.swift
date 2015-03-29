//
//  GradientViewController.swift
//  BDGradientNodeDemo
//
//  Created by Braindrizzle Studio.
//  http://braindrizzlestudio.com
//  Copyright (c) 2015 Braindrizzle Studio. All rights reserved.
//


import UIKit
import SpriteKit


class GradientViewController : UIViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()

        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        
        let scene = GradientScene()
        scene.size = self.view.bounds.size
        scene.scaleMode = .AspectFill
        
        skView.presentScene(scene)
    }

    override func prefersStatusBarHidden() -> Bool {
        
        return true
    }
}
