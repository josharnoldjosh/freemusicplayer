//
//  PlaylistViewController.swift
//  freemusic
//
//  Created by Josh Arnold on 18/05/17.
//  Copyright © 2017 Josh Arnold. All rights reserved.
//

import UIKit
import SwipeCellKit
import MediaPlayer
import SDWebImage
import PKHUD

class PlaylistViewController: ViewController, UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
    
    var createButton:UIBarButtonItem!
    
    var tableView:PlaylistTableView!
    
    var isAddingSong:Bool! = false
    var selectedSong:[String:NSObject]!
    
    let imageCache:SDImageCache = SDImageCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributes = [NSForegroundColorAttributeName: UIColor.highlight, NSFontAttributeName: UIFont(name: "Avenir Next", size: 19)!]
        let attributesSmall = [NSForegroundColorAttributeName: UIColor.highlight, NSFontAttributeName: UIFont(name: "Avenir Next", size: 15)!]
        
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        self.title = "Playlists"
        
        createButton = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(PlaylistViewController.createPlaylist))
        createButton.setTitleTextAttributes(attributesSmall, for: .normal)
        navigationItem.rightBarButtonItem = createButton
    
        tableView = PlaylistTableView(frame: view.frame, style: .plain)
        tableView.frame.size.height -= 16
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PlaylistTableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(PlaylistViewController.updateTableViewFrame), name: NSNotification.Name(rawValue: "showMusicPlayer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PlaylistViewController.updateTableViewFrame), name: NSNotification.Name(rawValue: "minimiseMusicPlayer"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        
        let items = self.tabBarController?.tabBar.items
        items?[0].title = ""
        items?[1].title = ""
        
        if isAddingSong == true {
            let cancel = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(PlaylistViewController.cancel))
            cancel.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.highlight, NSFontAttributeName: UIFont(name: "Avenir Next", size: 15)!], for: .normal)
            navigationItem.leftBarButtonItem = cancel
            title = "Add to playlist"
        }else{
            //            title = "Playlists"
        }
        
        updateTableViewFrame()
    }
    
    func updateTableViewFrame() {
        
        guard tabBarController != nil else {
            return
        }
        
        var tableFrame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height-ad_offset_constant)
        
        let mp = (tabBarController as! TabBarController).musicPlayerView
        if mp?.state == mpState.minimised {
            tableFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height-49-ad_offset_constant)
        }else if mp?.state == mpState.open {
            tableFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        }
        
        tableView.frame = tableFrame
    }
    
    func cancel() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didDismissPlaylistVC"), object: nil)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func createPlaylist() {
        let alert = UIAlertController(title: "Create new playlist", message: "Enter a name for this new playlist", preferredStyle: .alert)
        alert.view.tintColor = .highlight
        
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Playlist name"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { (action) in
            let textfield = alert.textFields![0]
            
            var title = textfield.text?.trimmingCharacters(in: .whitespaces)
            if title == nil || title == "" {
                title = "My playlist"
            }
            
            let newPlaylist:Playlist = Playlist(title: title!)
            
            var playlists = ArchiveUtil.loadPlaylist()
            
            if playlists != nil {
                playlists!.append(newPlaylist)
            }else{
                playlists = [newPlaylist]
            }
            
            ArchiveUtil.savePlaylist(playlist: playlists)
            
            self.tableView.reloadData()
            
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    var playlists:[Playlist]! = []
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.playlists = ArchiveUtil.loadPlaylist()
        if self.playlists != nil {
            return self.playlists!.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PlaylistTableViewCell
        
        // Clear this shit always
//        cell.mainImageView.alpha = 0
        cell.mainImageView.image = nil
        
        cell.delegate = self
        
        let playlist = playlists[indexPath.row]
        cell.title.text = playlist.title
        
        let songs = playlist.songs
        
        if songs != nil {
            if songs!.count > 0 {
                let song = songs![0]
                
                let url = song.artworkUrl
                
                if !imageCache.diskImageExists(withKey: url!.absoluteString) {
                    cell.mainImageView.alpha = 0
                }
                
                cell.mainImageView.sd_setImage(with: url, completed: { (image, error, cacheType, url) in
                    UIView.animate(withDuration: 0.75, animations: {
                        cell.mainImageView.alpha = 1
                    })
                    
                })
                
            }
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if isAddingSong == true {
            
            let dict = selectedSong["snippet"] as? [String:NSObject]
            
            let title = dict?["title"] as! String
            let artist = dict?["channelTitle"] as! String
            let id = (selectedSong["id"] as! [String:NSObject])["videoId"] as! String
            
            let thumbnails = dict?["thumbnails"] as! [String:NSObject]
            let high = thumbnails["high"] as! [String:NSObject]
            let url = high["url"] as! String
            let height = high["height"] as! Int
            let width = high["width"] as! Int
            let size = CGSize(width: width, height: height)
            
            let finalURL = URL(string: url)!
            
            let song = Song(id: id, title: title, artist: artist, artworkURL: finalURL, artworkSize: size)
            song.videoInfo = selectedSong
            
            let songs = playlists?[indexPath.row].songs
            if songs == nil {
                let newSongs = [song]
                playlists?[indexPath.row].songs = newSongs
            }else{
                guard playlists![indexPath.row].songs.contains(song) == false else {return}
                playlists?[indexPath.row].songs.append(song)
            }
            
            ArchiveUtil.savePlaylist(playlist: playlists)
            
            self.cancel()
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "songAddedToPlaylist"), object: nil)
            
            PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = true
            HUD.flash(.success, delay: 0.75)
            
        }else{
            
            let vc = SinglePlaylistViewController()
            vc.playlist = playlists?[indexPath.row]
            vc.playlistIndex = indexPath.row
            navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right || orientation == .left else { return nil }
        
        let save = SwipeAction(style: .default, title: "Shuffle") { action, indexPath in
            if (self.tabBarController != nil) {
                let vc = self.tabBarController as! TabBarController
                vc.minimiseMusicPlayer()
                
                let playlist = self.playlists[indexPath.row]
                
                guard playlist.songs != nil else {return}
                
                guard playlist.songs.count > 0 else {return}
                
                var shuffledSongs = playlist.songs
                shuffledSongs?.shuffle()
                
                let videoInfo = shuffledSongs?[0].videoInfo!
                vc.musicPlayerView.isPlayingPlaylist = true
                vc.musicPlayerView.selectedPlaylist = playlist
                vc.musicPlayerView.selectedPlaylistIndex = indexPath.row
                vc.musicPlayerView.currentPlaylistSong = shuffledSongs?[0]
                vc.musicPlayerView.shuffleSongs = shuffledSongs
                vc.musicPlayerView.shuffle.enable()
                vc.musicPlayerView.shouldShuffle = true
                vc.musicPlayerView.repeatMode = .playlist
                
                DispatchQueue.global(qos: .background).async {
                    vc.musicPlayerView.startPlayingSong(videoInfo!)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    let tableFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height-49-ad_offset_constant)
                    self.tableView.frame = tableFrame
                }
            }
        }
        
        // customize the action appearance
        save.image = UIImage(named: "playlist")
        save.backgroundColor = .highlight
        save.textColor = .white
        save.font = UIFont(name: "Avenir Next", size: 12)
        return [save]
    }
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .selection
        options.transitionStyle = .border
        options.backgroundColor = .primary
        return options
    }
    
}
