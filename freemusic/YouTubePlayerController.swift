//
//  YouTubePlayerController.swift
//  freemusic
//
//  Created by Josh Arnold on 22/05/17.
//  Copyright © 2017 Josh Arnold. All rights reserved.
//

import UIKit
import XCDYouTubeKit

class YouTubePlayerController: XCDYouTubeVideoPlayerViewController {
    
    var loopSong:Bool! = false {
        didSet {
            if loopSong == true {
//                moviePlayer.repeatMode = .one
            }else{
//                moviePlayer.repeatMode = .none
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .secondary
        moviePlayer.shouldAutoplay = true
        moviePlayer.controlStyle = .none

    }
}
