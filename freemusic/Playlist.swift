//
//  Playlist.swift
//  freemusic
//
//  Created by Josh Arnold on 24/05/17.
//  Copyright © 2017 Josh Arnold. All rights reserved.
//

import Foundation

class Playlist:NSObject, NSCoding {
    
    var title:String!
    
    var songs:[Song]! = []
    
    var downloadButtonOn:Bool? = false
    var downloaded:Bool? = false
    var downloadPercent:Float? = 0
    
    init(title:String) {
        self.title = title
    }

    required init(coder aDecoder: NSCoder) {
        
        title = aDecoder.decodeObject(forKey: "title") as? String
        songs = aDecoder.decodeObject(forKey: "playlistSongs") as? [Song]
        downloadButtonOn = aDecoder.decodeObject(forKey: "playlistDownloadButtonOn") as? Bool
        downloaded = aDecoder.decodeObject(forKey: "playlistDownloaded") as? Bool
        downloadPercent = aDecoder.decodeObject(forKey: "playlistDownloaded") as? Float
    }
    
    
    public func encode(with aCoder: NSCoder) {
        
        aCoder.encode(title, forKey: "title")
        aCoder.encode(songs, forKey: "playlistSongs")
        aCoder.encode(downloadButtonOn, forKey: "playlistDownloadButtonOn")
        aCoder.encode(downloaded, forKey: "playlistDownloaded")
        aCoder.encode(downloadPercent, forKey: "playlistDownloadPercent")
        
    }
}
