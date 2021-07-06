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

class GameViewController: UIViewController, GADFullScreenContentDelegate {

    var bannerView: GADBannerView!
    var interstitial: GADInterstitialAd?
    var interstitialAdCompletionHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            let scene = GameScene(size: CGSize(width: self.view.bounds.width, height: self.view.bounds.height))
            scene.adsDelegate = self
            
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
        
        self.loadInterstitialAd()
    }
    
    private func addBannerViewToView(_ bannerView: GADBannerView) {
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

    private func loadInterstitialAd() {
        let request = GADRequest()
        GADInterstitialAd.load(
            withAdUnitID: Const.Ads.adUnitIdInterstitialTest,
            request: request,
            completionHandler: { [self] ad, error in
                if let error = error {
                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                    return
                }
                interstitial = ad
                interstitial?.fullScreenContentDelegate = self
            }
        )
    }
    
    func showInterstitialAd(_ completionHandler: (() -> Void)? = nil) {
        if interstitial != nil {
            self.interstitialAdCompletionHandler = completionHandler
            interstitial?.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
      print("Ad did fail to present full screen content.")
    }

    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
      print("Ad did present full screen content.")
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        // From https://developers.google.com/admob/ios/interstitial#swift
        // GADInterstitialAd is a one-time-use object. This means that once an interstitial ad is shown, it cannot be shown again. A best practice is to load another interstitial ad in the adDidDismissFullScreenContent: method on GADFullScreenContentDelegate so that the next interstitial ad starts loading as soon as the previous one is dismissed.
        self.loadInterstitialAd()
        self.interstitialAdCompletionHandler?()
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
