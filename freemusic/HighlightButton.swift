//
//  HighlightButton.swift
//  freemusic
//
//  Created by Josh Arnold on 22/05/17.
//  Copyright © 2017 Josh Arnold. All rights reserved.
//

import UIKit

class HighlightButton: UIButton {

    init(frame: CGRect, image:UIImage) {
        super.init(frame: frame)
        
        setImage(image, for: .normal)
        
        tintColor = .highlight
        imageView?.tintColor = .highlight
        imageView?.contentMode = .scaleAspectFit
        
        imageEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        
        self.addTarget(self, action: #selector(PlayButton.highlightButton), for: .touchDown)
        self.addTarget(self, action: #selector(PlayButton.unhighlightButton), for: .touchUpInside)
        self.addTarget(self, action: #selector(PlayButton.unhighlightButton), for: .touchUpOutside)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func highlightButton() {
        imageView?.tintColor = tintColor.withAlphaComponent(0.35)
    }
    
    func unhighlightButton() {
        imageView?.tintColor = tintColor
    }
}
