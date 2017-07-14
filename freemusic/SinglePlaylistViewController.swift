//
//  SinglePlaylistViewController.swift
//  freemusic
//
//  Created by Josh Arnold on 25/05/17.
//  Copyright © 2017 Josh Arnold. All rights reserved.
//

import UIKit
import SDWebImage
import SwipeCellKit
import TWRDownloadManager

class SinglePlaylistViewController: ViewController, UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
    
    var playlist:Playlist!
    var playlistIndex:Int!
    
    var tableView:PlaylistTableView!
    var edit:UIBarButtonItem!
    
    let imageCache:SDImageCache = SDImageCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = playlist.title
        
        var tableFrame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height-112-ad_offset_constant)
        
        let mp = (tabBarController as! TabBarController).musicPlayerView
        if mp?.state == mpState.minimised {
            tableFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height-112-49-ad_offset_constant)
        }else if mp?.state == mpState.open {
            tableFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        }
        
        tableView = PlaylistTableView(frame: tableFrame, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ResultTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(PlaylistHeaderTableViewCell.self, forCellReuseIdentifier: "header")
        view.addSubview(tableView)
        
        edit = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(SinglePlaylistViewController.editPlaylist))
        let attributesSmall = [NSForegroundColorAttributeName: UIColor.highlight, NSFontAttributeName: UIFont(name: "Avenir Next", size: 15)!]
        edit.setTitleTextAttributes(attributesSmall, for: .normal)
        navigationItem.rightBarButtonItem = edit
        
        NotificationCenter.default.addObserver(self, selector: #selector(SinglePlaylistViewController.refreshTableView), name: NSNotification.Name(rawValue: "songAddedToPlaylist"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SinglePlaylistViewController.expandTableView), name: NSNotification.Name(rawValue: "showMusicPlayer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SinglePlaylistViewController.constrainTableView), name: NSNotification.Name(rawValue: "minimiseMusicPlayer"), object:nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SinglePlaylistViewController.shuffleCurrentPlist), name: NSNotification.Name(rawValue: "shuffleCurrentPlaylistSingleVC"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SinglePlaylistViewController.downloadPlaylist), name: NSNotification.Name(rawValue: "downloadCurrentPlaylist"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SinglePlaylistViewController.deleteDownloadedPlaylist), name: NSNotification.Name(rawValue: "deleteDownloadedCurrentPlaylist"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SinglePlaylistViewController.playlistJustDownloaded), name: NSNotification.Name(rawValue: "PlaylistDownloaded"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Downloader.shared.checkPlaylistDownloaded(playlist: self.playlist, index: playlistIndex)
    }
    
    func shuffleCurrentPlist() {
        
        guard playlist.songs.count > 0 else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if (self.tabBarController != nil) {
                let vc = self.tabBarController as! TabBarController
                vc.minimiseMusicPlayer()
                
                vc.musicPlayerView.shuffleSongs = nil
                
                vc.musicPlayerView.isPlayingPlaylist = true
                vc.musicPlayerView.selectedPlaylist = self.playlist
                vc.musicPlayerView.selectedPlaylistIndex = self.playlistIndex
                vc.musicPlayerView.shouldShuffle = true
                vc.musicPlayerView.repeatMode = .playlist
                
                let song = vc.musicPlayerView.shuffleSongs![0]
                
                vc.musicPlayerView.currentVideoMedia = song.videoInfo
                vc.musicPlayerView.currentPlaylistSong = song
                vc.musicPlayerView.startPlayingSong(song.videoInfo!)
                
                UIView.animate(withDuration: 0.25) {
                    self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height-49-ad_offset_constant)
                }
            }
        }
    }
    
    func editPlaylist() {
        let alert = UIAlertController(title: "Edit playlist", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Rename", style: .default, handler: { (UIAlertAction) in
            self.renamePlaylist()
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (UIAlertAction) in
            self.deletePlaylist()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func renamePlaylist() {
        let alert = UIAlertController(title: "Rename playlist", message: "Enter a new name for this new playlist", preferredStyle: .alert)
        alert.view.tintColor = .highlight
        
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Playlist name"
            textField.text = self.title
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Rename", style: .default, handler: { (action) in
            let textfield = alert.textFields![0]
            
            var title = textfield.text?.trimmingCharacters(in: .whitespaces)
            if title == nil || title == "" {
                title = "My playlist"
            }
            
            self.playlist.title = title
            ArchiveUtil.saveSinglePlaylist(playlist: self.playlist, index: self.playlistIndex)
            self.title = title
        }))
        
        present(alert, animated: true, completion: nil)
        
    }
    func deletePlaylist() {
        let alert = UIAlertController(title: "Delete playlist?", message: "This cannot be undone.", preferredStyle: .alert)
        alert.view.tintColor = .highlight
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            self.deleteDownloadedPlaylist()
            
            var plists = ArchiveUtil.loadPlaylist()
            plists?.remove(at: self.playlistIndex)
            ArchiveUtil.savePlaylist(playlist: plists)
            self.navigationController?.popViewController(animated: true)
        }))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func constrainTableView() {
        print("Constraining Table View, yas")
        UIView.animate(withDuration: 0.25) {
            self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height-49-20-ad_offset_constant)
        }
    }
    func expandTableView() {
        //        print("Expanding Table view")
        UIView.animate(withDuration: 0.25) {
            self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height+49+16)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard section == 1 else {
            return 1
        }
        
        playlist = ArchiveUtil.loadPlaylist()?[playlistIndex]
        
        let songs = playlist.songs
        
        if songs == nil {
            return 0
        }else{
            return songs!.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section == 1 else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "header", for: indexPath) as! PlaylistHeaderTableViewCell
            cell.selectionStyle = .none
            
            if playlist.downloaded == true{
                if playlist.downloadButtonOn == false {
                    playlist.downloadButtonOn = true
                    ArchiveUtil.saveSinglePlaylist(playlist: playlist, index: playlistIndex)
                }
            }
            
            if playlist.downloadButtonOn == true {
                cell.downloadSwitch.isOn = true
                if self.playlist.downloaded == false {
                    
                    if TWRDownloadManager.shared().currentDownloads().count > 0 {
                        
                    }else{
                        self.downloadPlaylist()
                    }
                    
                    cell.downloadLabel.text = "Downloading"
                    cell.downloadLabel.sizeToFit()
                }else{
                    cell.downloadLabel.text = "Downloaded"
                    cell.downloadLabel.sizeToFit()
                }
            }else{
                cell.downloadSwitch.isOn = false
                cell.downloadLabel.text = "Download"
                cell.downloadLabel.sizeToFit()
            }
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ResultTableViewCell
        cell.delegate = self
        
        let song = playlist.songs[indexPath.row]
        
        cell.title.text = song.title
        cell.subtitle.text = song.artist
        
        let url = song.artworkUrl
        let urlString = song.artworkUrl.absoluteString
        
        if !imageCache.diskImageExists(withKey: urlString) {
            cell.webImage.alpha = 0
            cell.title.alpha = 0
            cell.subtitle.alpha = 0
        }
        
        cell.webImage.sd_setImage(with: url, completed: { (image, error, cacheType, url) in
            UIView.animate(withDuration: 0.75, animations: {
                cell.webImage.alpha = 1
                cell.title.alpha = 1
                cell.subtitle.alpha = 1
            })
            
        })
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.section == 1 else {
            return (48*3)
        }
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        guard indexPath.section == 1 else {return}
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (tabBarController != nil) {
            let vc = tabBarController as! TabBarController
            vc.minimiseMusicPlayer()
            
            let videoInfo = playlist.songs[indexPath.row].videoInfo!
            vc.musicPlayerView.startPlayingSong(videoInfo)
            
            var shuffle_songs = playlist.songs
            shuffle_songs?.shuffle()
            
            vc.musicPlayerView.shuffleSongs = shuffle_songs
            vc.musicPlayerView.isPlayingPlaylist = true
            vc.musicPlayerView.selectedPlaylist = self.playlist
            vc.musicPlayerView.selectedPlaylistIndex = self.playlistIndex
            vc.musicPlayerView.currentPlaylistSong = self.playlist.songs[indexPath.row]
            
            
            
            UIView.animate(withDuration: 0.25) {
                self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height-49-ad_offset_constant)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let delete = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            
            let song = self.playlist.songs[indexPath.row]
            TWRDownloadManager.shared().deleteFile(withName: song.id)
            
            self.playlist.songs.remove(at: indexPath.row)
            var playlists = ArchiveUtil.loadPlaylist()
            playlists?[self.playlistIndex] = self.playlist
            ArchiveUtil.savePlaylist(playlist: playlists)
            
            // Coordinate table view update animations
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            action.fulfill(with: .delete)
            self.tableView.endUpdates()
        }
        
        // customize the action appearance
        delete.image = UIImage(named: "trash")
        delete.backgroundColor = UIColor(red:0.96, green:0.00, blue:0.28, alpha:1.0)
        delete.textColor = .white
        delete.font = UIFont(name: "Avenir Next", size: 12)
        return [delete]
    }
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = SwipeExpansionStyle.destructive
        options.transitionStyle = .border
        options.backgroundColor = .primary
        return options
    }
    
    func refreshTableView() {
        tableView.reloadData()
    }
    
    func downloadPlaylist() {
        playlist.downloadButtonOn = true
        //        playlist.downloaded = false
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PlaylistHeaderTableViewCell
        if cell != nil {
            cell?.downloadLabel.text = "Downloading"
            cell?.downloadLabel.sizeToFit()
        }
        
        ArchiveUtil.saveSinglePlaylist(playlist: playlist, index: playlistIndex)
        //        self.tableView.reloadData()
        Downloader.shared.download(playlist: self.playlist, playlistIndex: self.playlistIndex) {
            
        }
    }
    
    func deleteDownloadedPlaylist() {
        playlist.downloadButtonOn = false
        ArchiveUtil.saveSinglePlaylist(playlist: playlist, index: playlistIndex)
        Downloader.shared.delete(playlist: self.playlist, playlistIndex: self.playlistIndex) {
            
        }
    }
    
    func playlistJustDownloaded() {
        self.tableView.reloadData()
    }
}
