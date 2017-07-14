//
//  Song.swift
//  freemusic
//
//  Created by Josh Arnold on 24/05/17.
//  Copyright © 2017 Josh Arnold. All rights reserved.
//

import Foundation
import MediaPlayer

class Song:NSObject, NSCoding {
    
    var id:String!
    var title:String! = ""
    var artist:String! = ""
    var artworkUrl:URL!
    var artworkSize:CGSize!
    var videoInfo:[String:NSObject]!
    
    init(id:String, title:String, artist:String, artworkURL:URL, artworkSize:CGSize) {
        self.id = id
        self.title = title
        self.artist = artist
        self.artworkUrl = artworkURL
        self.artworkSize = artworkSize
    }
    
    required init(coder aDecoder: NSCoder) {
        
        id = aDecoder.decodeObject(forKey: "songID") as? String
        title = aDecoder.decodeObject(forKey: "songTitle") as? String
        artist = aDecoder.decodeObject(forKey: "songArtist") as? String
        artworkUrl = aDecoder.decodeObject(forKey: "songArtworkURL") as? URL
        artworkSize = aDecoder.decodeObject(forKey: "songArtworkSize") as? CGSize
        videoInfo = aDecoder.decodeObject(forKey: "songVideoInfo") as? [String:NSObject]
    }
        
    public func encode(with aCoder: NSCoder) {
        
        aCoder.encode(id, forKey: "songID")
        aCoder.encode(title, forKey: "songTitle")
        aCoder.encode(artist, forKey: "songArtist")
        aCoder.encode(artworkUrl, forKey: "songArtworkURL")
        aCoder.encode(artworkSize, forKey: "songArtworkSize")
        aCoder.encode(videoInfo, forKey: "songVideoInfo")
    }
}
