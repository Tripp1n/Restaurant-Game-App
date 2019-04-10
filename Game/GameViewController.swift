//
//  GameViewController.swift
//  Game
//
//  Created by Torben Nordtorp on 2018-03-06.
//  Copyright © 2018 Torben Nordtorp. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

var gameScene: RestaurantScene!
var shopScene: ShopScene!
var testScene: TestScene!

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameScene = RestaurantScene(size: view.frame.size)
        //shopScene = ShopScene(size: view.frame.size)
        //testScene = TestScene(size: view.frame.size)
        
        if let view = self.view as! SKView? {
            view.presentScene(gameScene)
            view.ignoresSiblingOrder = true
            view.showsPhysics = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
