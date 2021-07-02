//
//  GameViewController.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-05-01.
//

import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds

class GameViewController: UIViewController {

    var bannerView: GADBannerView!
    
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
        
        bannerView = GADBannerView(adSize: Const.Ads.bannerSize)
        bannerView.adUnitID = Const.Ads.adUnitIdBannerTest
        bannerView.rootViewController = self
        addBannerViewToView(bannerView)
        bannerView.load(GADRequest())
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.backgroundColor = UIColor.clear
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        
        view.addConstraints([
            NSLayoutConstraint(
                item: bannerView,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: view.safeAreaLayoutGuide,
                attribute: .bottom,
                multiplier: 1,
                constant: 0),
             NSLayoutConstraint(
                item: bannerView,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: view,
                attribute: .centerX,
                multiplier: 1,
                constant: 0)
          ])
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
