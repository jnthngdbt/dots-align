//
//  GameViewController.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-05-01.
//

import UIKit
import SpriteKit
import GameKit
import GameplayKit
import GoogleMobileAds

class GameViewController: UIViewController, GADFullScreenContentDelegate {

    var scene: GameScene?
    var bannerView: GADBannerView?
    var interstitial: GADInterstitialAd?
    var interstitialAdCompletionHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            self.scene = GameScene(size: CGSize(width: self.view.bounds.width, height: self.view.bounds.height))
            self.scene!.adsDelegate = self
            
            self.scene!.scaleMode = .aspectFit
            
            view.presentScene(self.scene!)
            view.ignoresSiblingOrder = true
            
            if Const.Debug.showStats {
                view.showsFPS = true
                view.showsNodeCount = true
            }
        }
        
        if Const.mustShowAds() {
            bannerView = GADBannerView(adSize: Const.Ads.bannerSize)
            bannerView!.adUnitID = (Const.buildMode == .publish) ? Const.Ads.adUnitIdBannerProd : Const.Ads.adUnitIdBannerTest
            bannerView!.rootViewController = self
            addBannerViewToView(bannerView!)
            bannerView!.load(GADRequest())
            
            self.loadInterstitialAd()
        }
        
        self.AuthenticateGameCenterLocalPlayer()
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
            withAdUnitID: (Const.buildMode == .publish) ? Const.Ads.adUnitIdInterstitialProd : Const.Ads.adUnitIdInterstitialTest,
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
            self.interstitialAdCompletionHandler = nil
            completionHandler?()
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
    
    func AuthenticateGameCenterLocalPlayer() {
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            // This handler may be called multiple times. E.g. first while not
            // logged in, with a view controller to show. After, with a nil view
            // controller meaning the user is logged in.
            
            if let viewController = viewController {
                self.present(viewController, animated: true)
            }
            
            self.scene?.updateGameCenterAccessPoint()
            
            if error != nil {
                // Player could not be authenticated.
                // Disable Game Center in the game.
                return
            }
            
            // Player was successfully authenticated (GKLocalPlayer.local.isAuthenticated).
            // Check if there are any player restrictions before starting the game.
                    
            if GKLocalPlayer.local.isUnderage {
                // Hide explicit game content.
            }

            if GKLocalPlayer.local.isMultiplayerGamingRestricted {
                // Disable multiplayer game features.
            }

            if #available(iOS 14.0, *) {
                if GKLocalPlayer.local.isPersonalizedCommunicationRestricted {
                    // Disable in game communication UI.
                }
            }
            
            // Perform any other configurations as needed (for example, access point).
        }
    }
}
