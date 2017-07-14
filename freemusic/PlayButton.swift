//
//  PlayButton.swift
//  freemusic
//
//  Created by Josh Arnold on 21/05/17.
//  Copyright © 2017 Josh Arnold. All rights reserved.
//

import UIKit

class PlayButton: UIButton {
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setStateToPlay()
        
        tintColor = .secondary
        imageView?.tintColor = tintColor
        imageView?.contentMode = .scaleAspectFit
        imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)

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
    
    func setStateToPaused() {
        let image = UIImage(named: "play")?.withRenderingMode(.alwaysTemplate)
        setImage(image, for: .normal)
    }
    func setStateToPlay() {
        let image = UIImage(named: "pause")?.withRenderingMode(.alwaysTemplate)
        setImage(image, for: .normal)
    }

    func addBorder() {
        layer.cornerRadius = frame.width/2
        layer.borderColor = tintColor.cgColor
        layer.borderWidth = 2
    }

}
