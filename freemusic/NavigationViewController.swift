//
//  NavigationViewController.swift
//  freemusic
//
//  Created by Josh Arnold on 18/05/17.
//  Copyright © 2017 Josh Arnold. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController, UINavigationControllerDelegate {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Navigation bar
        self.navigationBar.isTranslucent = false
        self.navigationBar.isOpaque = true
        self.navigationBar.barTintColor = .secondary
        self.navigationBar.tintColor = .highlight
        
        self.delegate = self
                
        // Dismiss Keyboard
        let gesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        gesture.cancelsTouchesInView = false
        view.addGestureRecognizer(gesture)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    /** Dismiss the keyboard */
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = item
    }
}
