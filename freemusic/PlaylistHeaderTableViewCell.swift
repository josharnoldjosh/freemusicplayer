//
//  PlaylistHeaderTableViewCell.swift
//  freemusic
//
//  Created by Josh Arnold on 12/06/17.
//  Copyright © 2017 Josh Arnold. All rights reserved.
//

import UIKit
import pop

class PlaylistHeaderTableViewCell: UITableViewCell {
    
    var addSongToPlaylist:UIButton!
    var downloadLabel:UILabel!
    var downloadSwitch:UISwitch!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .secondary
        
        addSongToPlaylist = UIButton(frame: CGRect(x: 0, y: 0, width: 320-16, height: 48))
        addSongToPlaylist.setTitle("Shuffle", for: .normal)
        addSongToPlaylist.setTitleColor(.white, for: .normal)
        addSongToPlaylist.titleLabel?.font = UIFont(name: "Avenir Next", size: 18)
        addSongToPlaylist.center.x = (UIApplication.shared.keyWindow?.rootViewController?.view.center.x)!
        addSongToPlaylist.frame.origin.y = 24
        addSongToPlaylist.backgroundColor = .highlight
        addSongToPlaylist.layer.cornerRadius = 24
        addSongToPlaylist.clipsToBounds = true
        addSongToPlaylist.addTarget(self, action: #selector(PlaylistHeaderTableViewCell.highlightAddToPlaylistButton), for: .touchDown)
        addSongToPlaylist.addTarget(self, action: #selector(PlaylistHeaderTableViewCell.shufflePlaylist), for: .touchUpInside)
        addSongToPlaylist.addTarget(self, action: #selector(PlaylistHeaderTableViewCell.unhighlightAddToPlaylistButton), for: .touchUpOutside)
        contentView.addSubview(addSongToPlaylist)
        
        let sprintAnimation = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
        sprintAnimation?.toValue = NSValue(cgPoint: CGPoint(x: 0.9, y: 0.9))
        sprintAnimation?.velocity = NSValue(cgPoint: CGPoint(x: 1, y: 1))
        sprintAnimation?.springBounciness = 10
        addSongToPlaylist.pop_add(sprintAnimation, forKey: "sprintAnimation")
        
        downloadLabel = UILabel()
        downloadLabel.text = "Download"
        downloadLabel.font = UIFont(name: "Avenir Next", size: 17)
        downloadLabel.textColor = .highlight
        downloadLabel.sizeToFit()
        downloadLabel.frame.origin = CGPoint(x: 16, y: addSongToPlaylist.frame.maxY+32)
        contentView.addSubview(downloadLabel)
        
        downloadSwitch = UISwitch()
        downloadSwitch.tintColor = .highlight
        downloadSwitch.backgroundColor = .clear
        downloadSwitch.onTintColor = .highlight
        downloadSwitch.center = downloadLabel.center
        downloadSwitch.frame.origin.x = (UIApplication.shared.keyWindow?.rootViewController?.view.frame.width)! - downloadSwitch.frame.width - 16
        downloadSwitch.isOn = false
        downloadSwitch.addTarget(self, action: #selector(PlaylistHeaderTableViewCell.downloadPlaylist), for: .valueChanged)
        contentView.addSubview(downloadSwitch)
        
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
    }
    
    func shufflePlaylist() {
        unhighlightAddToPlaylistButton()
        
        // call to shuffle playlist
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "shuffleCurrentPlaylistSingleVC"), object: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func downloadPlaylist() {
        if downloadSwitch.isOn == true {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "downloadCurrentPlaylist"), object: nil)
        }else{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "deleteDownloadedCurrentPlaylist"), object: nil)
        }
    }
}
