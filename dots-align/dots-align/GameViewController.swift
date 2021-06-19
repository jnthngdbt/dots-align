//
//  GameViewController.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-05-01.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            let scene = GameScene(size: CGSize(width: self.view.bounds.width, height: self.view.bounds.height))
            
            scene.scaleMode = .aspectFit
            
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            
            if Const.Debug.showStats {
                view.showsFPS = true
                view.showsNodeCount = true
            }
        }
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .portrait
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
