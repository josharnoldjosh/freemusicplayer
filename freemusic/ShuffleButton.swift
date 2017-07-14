//
//  ShuffleButton.swift
//  freemusic
//
//  Created by Josh Arnold on 22/05/17.
//  Copyright © 2017 Josh Arnold. All rights reserved.
//

import UIKit
import pop

class ShuffleButton: UIButton {

    var isActive:Bool! = false
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let image = UIImage(named: "shuffle")?.withRenderingMode(.alwaysTemplate)
        setImage(image, for: .normal)
        
        tintColor = .highlight
        imageView?.tintColor = .highlight
        imageView?.contentMode = .scaleAspectFit
                
        self.addTarget(self, action: #selector(PlayButton.highlightButton), for: .touchDown)
        self.addTarget(self, action: #selector(PlayButton.unhighlightButton), for: .touchUpInside)
        self.addTarget(self, action: #selector(PlayButton.unhighlightButton), for: .touchUpOutside)
        
        disable()
        unhighlightButton()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func highlightButton() {
        
        let scaleAnimation = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
        scaleAnimation?.duration = 0.1
        scaleAnimation?.toValue = NSValue(cgPoint: CGPoint(x: 1, y: 1))
        self.pop_add(scaleAnimation, forKey: "scalingUp")
    }
    
    func unhighlightButton() {

        let sprintAnimation = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
        sprintAnimation?.toValue = NSValue(cgPoint: CGPoint(x: 0.9, y: 0.9))
        sprintAnimation?.velocity = NSValue(cgPoint: CGPoint(x: 2, y: 2))
        sprintAnimation?.springBounciness = 20
        self.pop_add(sprintAnimation, forKey: "sprintAnimation")
    }

    func disable() {
        imageView?.tintColor = tintColor.withAlphaComponent(0.35)
        isActive = false
    }
    
    func enable() {
        imageView?.tintColor = tintColor
        isActive = true
    }
}
