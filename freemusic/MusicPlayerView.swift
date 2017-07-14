//
//  MusicPlayerView.swift
//  freemusic
//
//  Created by Josh Arnold on 20/05/17.
//  Copyright © 2017 Josh Arnold. All rights reserved.
//

import UIKit
import NAKPlaybackIndicatorView
import MarqueeLabel
import XCDYouTubeKit
import pop
import TWRDownloadManager
import AudioPlayer

/** States of the music player. */
enum mpState {
    case hidden
    case minimised
    case open
}

class MusicPlayerView: UIView, AVAudioPlayerDelegate {
    
    /* Minimised bar */
    var playButton:PlayButton!
    var animationIcon:NAKPlaybackIndicatorView!
    var titleLabel:MarqueeLabel!
    
    /* Player controller */
    var playerContainer:UIView!
    var playerController:YouTubePlayerController! = YouTubePlayerController()
    
    /* Open view controls */
    var shuffle:ShuffleButton!
    var repeatBtn:RepeatButton!
    var largePlayButton:PlayButton!
    var skipRightButton:HighlightButton!
    var skipLeftButton:HighlightButton!
    var addSongToPlaylist:UIButton!
    
    var audioImageView:UIImageView!
    
    var userPaused:Bool! = false
    
    /* Init methods */
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.highlight.withAlphaComponent(0.93)
        
        let pan = UIPanGestureRecognizer(target: self, action:(#selector(MusicPlayerView.handlePanGesture(panGesture:))))
        addGestureRecognizer(pan)
        let tap = UITapGestureRecognizer(target: self, action: #selector(MusicPlayerView.handleTap))
        addGestureRecognizer(tap)
        
        animationIcon = NAKPlaybackIndicatorView(frame: .zero)
        animationIcon.tintColor = .secondary
        addSubview(animationIcon)
        animationIcon.sizeToFit()
        animationIcon.state = .playing
        animationIcon.frame.origin.y += ad_offset_constant
        
        titleLabel = MarqueeLabel(frame: CGRect(x: 72, y: ad_offset_constant, width: frame.width-116, height: 49), duration: 8.0, fadeLength: 10.0)
        titleLabel.font = UIFont(name: "Avenir Next", size: 15)
        titleLabel.textColor = .secondary
        addSubview(titleLabel)
        
        playButton = PlayButton(frame: CGRect(x: frame.width-49+5, y: 5+ad_offset_constant, width: 39, height: 39))
        playButton.addTarget(self, action: #selector(MusicPlayerView.playButtonClicked), for: .touchUpInside)
        addSubview(playButton)
        
        playerContainer = UIView(frame: CGRect(x: 0, y: 49+ad_offset_constant, width: frame.width, height: frame.width))
        //        playerContainer.backgroundColor = .secondary
        addSubview(playerContainer)
        
        audioImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: playerContainer.frame.width, height: playerContainer.frame.height))
        audioImageView.contentMode = .scaleAspectFit
        audioImageView.tag = 140
        playerContainer.addSubview(audioImageView)
        
        largePlayButton = PlayButton(frame: CGRect(x: 0, y: playerContainer.frame.maxY-24, width: 70, height: 70))
        largePlayButton.tintColor = .highlight
        largePlayButton.imageView?.tintColor = .highlight
        largePlayButton.center.x = center.x
        largePlayButton.addTarget(self, action: #selector(MusicPlayerView.playButtonClicked), for: .touchUpInside)
        addSubview(largePlayButton)
        
        skipRightButton = HighlightButton(frame: CGRect(x: largePlayButton.frame.maxX+16, y: playerContainer.frame.maxY+20, width: 30, height: 30), image: UIImage(named: "skipRight")!.withRenderingMode(.alwaysTemplate))
        addSubview(skipRightButton)
        skipRightButton.center.y = largePlayButton.center.y
        skipRightButton.addTarget(self, action: #selector(MusicPlayerView.skipToNextSong), for: .touchUpInside)
        
        skipLeftButton = HighlightButton(frame: CGRect(x: largePlayButton.frame.origin.x-56, y: playerContainer.frame.maxY+20, width: 30, height: 30), image: UIImage(named: "skipLeft")!.withRenderingMode(.alwaysTemplate))
        addSubview(skipLeftButton)
        skipLeftButton.center.y = largePlayButton.center.y
        skipLeftButton.addTarget(self, action: #selector(MusicPlayerView.skipToBegining), for: .touchUpInside)
        
        shuffle = ShuffleButton(frame: CGRect(x: 16, y: playerContainer.frame.maxY+7, width: 35, height: 35))
        shuffle.addTarget(self, action: #selector(MusicPlayerView.shuffleButtonTapped), for: .touchUpInside)
        addSubview(shuffle)
        shuffle.center.y = largePlayButton.center.y
        
        repeatBtn = RepeatButton(frame: CGRect(x: frame.width-56, y: playerContainer.frame.maxY+7, width: 35, height: 35))
        addSubview(repeatBtn)
        repeatBtn.center.y = largePlayButton.center.y
        repeatBtn.addTarget(self, action: #selector(MusicPlayerView.repeatButtonTapped), for: .touchUpInside)
        
        addSongToPlaylist = UIButton(frame: CGRect(x: 0, y: 0, width: 320-16, height: 48))
        addSongToPlaylist.setTitle("Add 2 playlist", for: .normal)
        addSongToPlaylist.setTitleColor(.white, for: .normal)
        //        addSongToPlaylist.setTitleColor(.lightGray, for: .highlighted)
        addSongToPlaylist.titleLabel?.font = UIFont(name: "Avenir Next", size: 18)
        addSongToPlaylist.center.x = center.x
        addSongToPlaylist.frame.origin.y = largePlayButton.frame.maxY+24
        addSongToPlaylist.backgroundColor = .highlight
        addSongToPlaylist.layer.cornerRadius = 24
        addSongToPlaylist.clipsToBounds = true
        addSongToPlaylist.addTarget(self, action: #selector(MusicPlayerView.highlightAddToPlaylistButton), for: .touchDown)
        addSongToPlaylist.addTarget(self, action: #selector(MusicPlayerView.unhighlightAddToPlaylistButton), for: .touchUpInside)
        addSubview(addSongToPlaylist)
        unhighlightAddToPlaylistButton()
        
        //I know this is deprecated... I'm just wayyyy to lazy to fix it rn lol 😝
        NotificationCenter.default.addObserver(self, selector: #selector(MusicPlayerView.playerStateChanged), name: NSNotification.Name.MPMoviePlayerPlaybackStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MusicPlayerView.updatePlaylist), name: NSNotification.Name(rawValue: "didDismissPlaylistVC"), object: nil)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func highlightAddToPlaylistButton() {
        
        let scaleAnimation = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
        scaleAnimation?.duration = 0.1
        scaleAnimation?.toValue = NSValue(cgPoint: CGPoint(x: 1, y: 1))
        addSongToPlaylist.pop_add(scaleAnimation, forKey: "scalingUp")
    }
    
    func unhighlightAddToPlaylistButton() {
        
        let sprintAnimation = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
        sprintAnimation?.toValue = NSValue(cgPoint: CGPoint(x: 0.9, y: 0.9))
        sprintAnimation?.velocity = NSValue(cgPoint: CGPoint(x: 2, y: 2))
        sprintAnimation?.springBounciness = 20
        addSongToPlaylist.pop_add(sprintAnimation, forKey: "sprintAnimation")
        
        guard currentVideoMedia != nil else {return}
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
            let vc = PlaylistViewController()
            vc.isAddingSong = true
            vc.selectedSong = self.currentVideoMedia
            let nav = NavigationViewController(rootViewController: vc)
            UIApplication.shared.keyWindow?.rootViewController?.present(nav, animated: true, completion: nil)
        }
    }
    
    /* Pan gesture for moving this view */
    func handleTap() {
        guard state != .hidden else { return }
        
        if state == .minimised {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showMusicPlayer"), object: nil)
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    func handlePanGesture(panGesture: UIPanGestureRecognizer) {
        
        guard state != .hidden else { return }
        
        let translation = panGesture.translation(in: self.superview)
        center.y += translation.y
        panGesture.setTranslation(.zero, in: self)
        
        if panGesture.state == UIGestureRecognizerState.ended {
            if panGesture.velocity(in: superview).y > 0 {
                // Hide it
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "minimiseMusicPlayer"), object: nil)
                self.state = .minimised
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }else{
                // Show it
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showMusicPlayer"), object: nil)
                self.state = .open
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
        }
    }
    
    // Mmmm
    let mpic = MPNowPlayingInfoCenter.default()
    var videoTitle:String! = ""
    var videoArtist:String! = ""
    var videoArtwork:MPMediaItemArtwork?
    
    var currentVideoMedia:[String:NSObject]?
    
    var audioPlayer:AVAudioPlayer! = AVAudioPlayer()
    
    /* Controlling playback of songs */
    var isPlayingDownloadedFile:Bool! = false
    func startPlayingSong(_ video:[String:NSObject]) {
        if self.state != .open {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "minimiseMusicPlayer"), object: nil)
        }
        
        currentVideoMedia = video
        
        let dict = video["snippet"] as? [String:NSObject]
        let title = dict?["title"] as! String
        self.videoTitle = "(Loading song) "+title
        let artist = dict?["channelTitle"] as! String
        self.videoArtist = artist
        
        self.videoArtwork = nil
        let thumbnails = dict?["thumbnails"] as! [String:NSObject]
        let high = thumbnails["high"] as! [String:NSObject]
        let url = high["url"] as! String
        let height = high["height"] as! Int
        let width = high["width"] as! Int
        let size = CGSize(width: width, height: height)
        
        do {
            let data = try Data(contentsOf: URL(string:url)!)
            let image = UIImage(data: data)
            
            self.audioImageView.image = image
            
            let art = MPMediaItemArtwork(boundsSize: size, requestHandler: { (size) -> UIImage in
                return image!
            })
            self.videoArtwork = art
            self.setNowPlayingInfo()
        } catch _ {
            print("error fetching data")
        }
        
        setNowPlayingInfo()
        
        DispatchQueue.main.async {
            
            UIApplication.shared.beginReceivingRemoteControlEvents()
            self.becomeFirstResponder()
            
            for view in self.playerContainer.subviews {
                if view.tag != 140 {
                    view.removeFromSuperview()
                }
            }
            
            self.titleLabel.text = title
            
            let id = (video["id"] as! [String:NSObject])["videoId"] as! String
            
            if TWRDownloadManager.shared().fileExists(withName: id) {
                print(title, "exists, playing audio instead...")
                
                self.isPlayingDownloadedFile = true
                
                let localPath = TWRDownloadManager.shared().localPath(forFile: id)
                guard localPath != nil else { return }
                
                let url = URL(fileURLWithPath: localPath!)
                
                do {
                    self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                    self.audioPlayer.delegate = self
                    self.audioPlayer.play()
                } catch let error as NSError {
                    print(error.description)
                } catch {
                    print("AVAudioPlayer init failed")
                }
                
                self.videoTitle = title
                self.isPaused = false
                
                self.setNowPlayingInfo()
            }else{
                
                self.isPlayingDownloadedFile = false
                self.playerController = YouTubePlayerController(videoIdentifier: id)
                self.playerController.present(in: self.playerContainer)
                self.playerController.moviePlayer.prepareToPlay()
                
                self.isPaused = false
            }
        }
    }
    
    
    
    func playButtonClicked() {
        if isPaused == true {
            isPaused = false
            userPaused = false
            if isPlayingDownloadedFile == true {
                self.audioPlayer.play()
            }else{
                playerController.moviePlayer.play()
            }
        }else{
            isPaused = true
            userPaused = true
            if isPlayingDownloadedFile == true {
                self.audioPlayer.pause()
            }else{
                playerController.moviePlayer.pause()
            }
        }
    }
    
    /** Called when the player state has changed */
    func playerStateChanged() {
        if playerController.moviePlayer.playbackState == .paused || playerController.moviePlayer.playbackState == .interrupted {
            isPaused = true
            
            if userPaused == false {
                if isPlayingPlaylist == true && repeatMode == .playlist && playerController.moviePlayer.currentPlaybackTime >= playerController.moviePlayer.duration-5  {
                    self.skipToNextSong()
                }else if repeatMode == .noRepeat && playerController.moviePlayer.currentPlaybackTime >= playerController.moviePlayer.duration-5 {
                    // do nothing!
                }else{
                    playerController.moviePlayer.play()
                    self.videoTitle = self.videoTitle.replacingOccurrences(of: "(Loading song) ", with: "")
                    setNowPlayingInfo()
                }
            }
        }
        
        if playerController.moviePlayer.playbackState == .stopped {
            isPaused = true
        }
        
        if playerController.moviePlayer.playbackState == .playing {
            isPaused = false
            self.videoTitle = self.videoTitle.replacingOccurrences(of: "(Loading song) ", with: "")
            setNowPlayingInfo()
        }
    }
    
    func setNowPlayingInfo() {
        var dict = [MPMediaItemPropertyTitle: videoTitle, MPMediaItemPropertyArtist: videoArtist] as! [String:NSObject]
        
        if videoArtwork != nil {
            dict[MPMediaItemPropertyArtwork] = videoArtwork
        }
        
        if isPlayingDownloadedFile == true {
            
            dict[MPMediaItemPropertyPlaybackDuration] = self.audioPlayer.duration as NSObject
            
            dict[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.audioPlayer.currentTime as NSObject
            
        }else{
            
            dict[MPMediaItemPropertyPlaybackDuration] = playerController.moviePlayer.duration as NSObject
            
            dict[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playerController.moviePlayer.currentPlaybackTime as NSObject
            
        }
        
        mpic.nowPlayingInfo = dict
        
    }
    
    func shuffleButtonTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        if shouldShuffle == false {
            shouldShuffle = true
        }else{
            shouldShuffle = false
        }
    }
    
    func repeatButtonTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        if repeatMode == .noRepeat {
            repeatMode = .playlist
        }else if repeatMode == .playlist {
            repeatMode = .loopSong
        }else if repeatMode == .loopSong {
            repeatMode = .noRepeat
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        let rc = event?.subtype
        
        if rc == UIEventSubtype.remoteControlPause || rc == .remoteControlPlay {
            playButtonClicked()
        }
        
        if rc == UIEventSubtype.remoteControlPreviousTrack {
            //            print("previous track")
            skipToBegining()
        }
        
        if rc == UIEventSubtype.remoteControlNextTrack {
            self.skipToNextSong()
        }
    }
    
    func skipToBegining() {
        if isPlayingDownloadedFile == true {
            self.audioPlayer.currentTime = 0
        }else{
            playerController.moviePlayer.currentPlaybackTime = 0
        }
        setNowPlayingInfo()
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    func skipToNextSong() {
        
        if isPlayingPlaylist == true  {
            
            if shouldShuffle == true {
                let currentSongIndex = shuffleSongs?.index(of: self.currentPlaylistSong!)
                
                guard shuffleSongs != nil else {
                    return
                }
                
                guard currentSongIndex != nil else {
                    return
                }
                
                if shuffleSongs!.count-1 > currentSongIndex! {
                    let nextSong = shuffleSongs![(currentSongIndex!+1)].videoInfo
                    self.currentPlaylistSong = shuffleSongs![(currentSongIndex!+1)]
                    setNowPlayingInfo()
                    self.startPlayingSong(nextSong!)
                }else{
                    let newSong = shuffleSongs![0].videoInfo
                    self.currentPlaylistSong = shuffleSongs![0]
                    setNowPlayingInfo()
                    self.startPlayingSong(newSong!)
                }
                
            }else{
                
                let currentSongIndex = self.selectedPlaylist!.songs.index(of: self.currentPlaylistSong!)
                
                if self.selectedPlaylist!.songs.count >= currentSongIndex!+2 {
                    let nextSong = self.selectedPlaylist!.songs[(currentSongIndex!+1)].videoInfo
                    self.currentPlaylistSong = self.selectedPlaylist!.songs[(currentSongIndex!+1)]
                    setNowPlayingInfo()
                    self.startPlayingSong(nextSong!)
                }else{
                    let newSong = self.selectedPlaylist!.songs![0].videoInfo
                    self.currentPlaylistSong = self.selectedPlaylist!.songs![0]
                    setNowPlayingInfo()
                    self.startPlayingSong(newSong!)
                }
            }
        }
    }
    
    func updatePlaylist() {
        // Guard
        guard isPlayingPlaylist == true else {return}
        
        // Load updated playlist
        let newPlaylist = ArchiveUtil.loadPlaylist()?[self.selectedPlaylistIndex]
        
        if shuffle.isActive == true {
            for song in (newPlaylist?.songs)! {
                var canAdd:Bool! = true
                for other_song in self.shuffleSongs! {
                    if other_song.id == song.id {
                        canAdd = false
                    }
                }
                if canAdd == true {
                    self.shuffleSongs?.append(song)
                }
            }
            self.selectedPlaylist = newPlaylist
        }else{
            self.selectedPlaylist = newPlaylist
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print(error as Any)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if isPlayingPlaylist == true && repeatMode == .playlist {
            self.skipToNextSong()
        }else if repeatMode == .noRepeat {
            
        }else{
            audioPlayer.play()
            self.videoTitle = self.videoTitle.replacingOccurrences(of: "(Loading song) ", with: "")
            setNowPlayingInfo()
        }
    }
    
    
    /* ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————— */
    
    /** Phat properties */
    var state:mpState! = .hidden {
        didSet {
            if state == .open {
                UIView.animate(withDuration: 0.3, animations: {
                    self.animationIcon.alpha = 0
                    self.titleLabel.alpha = 0
                    self.playButton.alpha = 0
                    self.playerContainer.frame.origin.y = ad_offset_constant
                    
                    self.hideStatusBar(boolean: true)
                    
                    self.backgroundColor = UIColor.primary.withAlphaComponent(0.925)
                    
                })
            }else if state == .minimised {
                UIView.animate(withDuration: 0.3, animations: {
                    self.animationIcon.alpha = 1
                    self.titleLabel.alpha = 1
                    self.playButton.alpha = 1
                    self.playerContainer.frame.origin.y = 49+ad_offset_constant
                    self.hideStatusBar(boolean: false)
                    
                    self.backgroundColor = UIColor.highlight.withAlphaComponent(0.925)
                    
                })
            }
        }
    }
    func hideStatusBar(boolean:Bool) {
        (((window!.rootViewController as! TabBarController).viewControllers?[0] as! NavigationViewController).viewControllers[0] as! ViewController).hideStatusBar(bool: boolean)
        (((window!.rootViewController as! TabBarController).viewControllers?[1] as? NavigationViewController)?.viewControllers[0] as? ViewController)?.hideStatusBar(bool: boolean)
        
        if ((window!.rootViewController as! TabBarController).viewControllers![1] as! NavigationViewController).viewControllers.count > 1 {
            (((window!.rootViewController as! TabBarController).viewControllers?[1] as? NavigationViewController)?.viewControllers[1] as? ViewController)?.hideStatusBar(bool: boolean)
        }
    }
    
    /* For playing playlists >:) */
    var isPlayingPlaylist:Bool! = false {
        didSet {
            if isPlayingPlaylist == false {
                selectedPlaylist = nil
                selectedPlaylistIndex = nil
                currentPlaylistSong = nil
            }
        }
    }
    var selectedPlaylist:Playlist? = nil
    var selectedPlaylistIndex:Int! = 0
    var currentPlaylistSong:Song? = nil
    var shuffleSongs:[Song]? = nil
    
    var isPaused:Bool! = false {
        didSet {
            if isPaused == true {
                animationIcon.state = .paused
                playButton.setStateToPaused()
                largePlayButton.setStateToPaused()
            }else{
                animationIcon.state = .playing
                playButton.setStateToPlay()
                largePlayButton.setStateToPlay()
            }
        }
    }
    
    var shouldShuffle:Bool! = false {
        didSet {
            if shouldShuffle == false {
                shuffle.disable()
                shuffleSongs = nil
            }else{
                shuffle.enable()
                
                guard shuffleSongs == nil else {
                    return
                }
                
                if let songs = self.selectedPlaylist?.songs {
                    //                    if songs.count > 1 {
                    self.shuffleSongs = songs
                    self.shuffleSongs?.shuffle()
                    //                    }
                }
                
            }
        }
    }
    
    enum RepeatMode {
        case noRepeat
        case playlist
        case loopSong
    }
    var repeatMode:RepeatMode! = .noRepeat {
        didSet {
            if repeatMode == .noRepeat {
                repeatBtn.disable()
                let image = UIImage(named: "repeat")!.withRenderingMode(.alwaysTemplate)
                repeatBtn.setImage(image, for: .normal)
                
                playerController.loopSong = false
            }else if repeatMode == .playlist {
                repeatBtn.enable()
                let image = UIImage(named: "repeat")!.withRenderingMode(.alwaysTemplate)
                repeatBtn.setImage(image, for: .normal)
                
                playerController.loopSong = true
                
            }else if repeatMode == .loopSong {
                repeatBtn.enable()
                let image = UIImage(named: "loop")!.withRenderingMode(.alwaysTemplate)
                repeatBtn.setImage(image, for: .normal)
                
                playerController.loopSong = true
            }
        }
    }
}

extension MutableCollection where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffle() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in startIndex ..< endIndex - 1 {
            let j = Int(arc4random_uniform(UInt32(endIndex - i))) + i
            if i != j {
                swap(&self[i], &self[j])
            }
        }
    }
}
