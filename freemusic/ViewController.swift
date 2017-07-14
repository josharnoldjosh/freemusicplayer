//
//  ViewController.swift
//  freemusic
//
//  Created by Josh Arnold on 18/05/17.
//  Copyright © 2017 Josh Arnold. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var isHidden:Bool = false
    func hideStatusBar(bool:Bool) {
        isHidden = bool
        UIView.animate(withDuration: 0.5) { () -> Void in
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    override var prefersStatusBarHidden: Bool {
        return isHidden
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Background color
        self.view.backgroundColor = .primary
        
        // Hide titles on tab bar
        let items = self.tabBarController?.tabBar.items
        items?[0].title = ""
        items?[1].title = ""
        
        let attributes = [NSForegroundColorAttributeName: UIColor.highlight, NSFontAttributeName: UIFont(name: "Avenir Next", size: 17)!]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide titles on tab bar
        let items = self.tabBarController?.tabBar.items
        items?[0].title = ""
        items?[1].title = ""
        
    }
    
    /** Dismiss the keyboard */
    func dismissKeyboard() {
        view.endEditing(true)
    }

}
