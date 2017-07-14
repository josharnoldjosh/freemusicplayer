//
//  TabBarController.swift
//  freemusic
//
//  Created by Josh Arnold on 18/05/17.
//  Copyright © 2017 Josh Arnold. All rights reserved.
//

import UIKit
import GoogleMobileAds

class TabBarController: UITabBarController {
    
    var musicPlayerView:MusicPlayerView!
    var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .primary
        
        self.tabBar.tintColor = .highlight
        self.tabBar.barTintColor = .secondary
        self.tabBar.isOpaque = true
        self.tabBar.isTranslucent = false
        
        musicPlayerView = MusicPlayerView(frame: CGRect(x: 0, y: tabBar.frame.origin.y, width: view.frame.width, height: view.frame.height*10))
        view.insertSubview(musicPlayerView, at: 1)
        
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.frame.origin = CGPoint(x: 0, y: 0)
        bannerView.backgroundColor = UIColor.primary
        bannerView.adUnitID = ""
        bannerView.rootViewController = self
        
//        let request = GADRequest()
//        bannerView.load(request)
//        musicPlayerView.addSubview(bannerView)
        
        hideMusicPlayer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(TabBarController.showMusicPlayer), name: NSNotification.Name(rawValue: "showMusicPlayer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TabBarController.minimiseMusicPlayer), name: NSNotification.Name(rawValue: "minimiseMusicPlayer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TabBarController.updatePlaylists), name: NSNotification.Name(rawValue: "didDismissPlaylistVC"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TabBarController.hideAds), name: NSNotification.Name(rawValue: "hide_ads"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func hideAds() {
        bannerView.removeFromSuperview()
        ad_offset_constant = 0
        
        musicPlayerView.removeFromSuperview()
        musicPlayerView = MusicPlayerView(frame: CGRect(x: 0, y: tabBar.frame.origin.y, width: view.frame.width, height: view.frame.height*10))
        view.insertSubview(musicPlayerView, at: 1)
        
        self.hideMusicPlayer()
    }
    
    func showMusicPlayer() {
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 3, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
            if ad_offset_constant == 0 {
                self.musicPlayerView.frame.origin.y = 0
            }else{
                self.musicPlayerView.frame.origin.y = 0
            }
            self.tabBar.frame.origin.y = self.view.frame.size.height
        }, completion: { (done) in
            self.musicPlayerView.state = .open
        })
    }
    
    func minimiseMusicPlayer() {
        
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 3, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
            self.tabBar.frame.origin.y = self.view.frame.size.height - self.tabBar.frame.height
            self.musicPlayerView.frame.origin.y = (self.tabBar.frame.origin.y - self.tabBar.frame.height-ad_offset_constant)
        }, completion: { (done) in
            self.musicPlayerView.state = .minimised
        })
    }
    
    func hideMusicPlayer() {
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 3, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
            self.tabBar.frame.origin.y = self.view.frame.size.height - self.tabBar.frame.height
            self.musicPlayerView.frame.origin.y = (self.tabBar.frame.origin.y - self.tabBar.frame.height)
            
            if ad_offset_constant == 0 {
                self.musicPlayerView.frame.origin.y = self.tabBar.frame.origin.y
            }
        }, completion: { (done) in
            self.musicPlayerView.state = .hidden
        })
    }
    
    func updatePlaylists() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.musicPlayerView.animationIcon.state = .playing
            UIApplication.shared.beginReceivingRemoteControlEvents()
            self.musicPlayerView.becomeFirstResponder()
        }
        print("OI")
    }
}
