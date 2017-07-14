//
//  ArchieveUtil.swift
//  freemusic
//
//  Created by Josh Arnold on 24/05/17.
//  Copyright © 2017 Josh Arnold. All rights reserved.
//
import Foundation

class ArchiveUtil {
    
    private static let primaryKey = "musicPlaylist"
    
    private static func archivePlaylist(people : [Playlist]) -> NSData {
        
        return NSKeyedArchiver.archivedData(withRootObject: people as NSArray) as NSData
    }
    
    static func loadPlaylist() -> [Playlist]? {
        
        if let unarchivedObject = UserDefaults.standard.object(forKey: primaryKey) as? Data {
            
            return NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject as Data) as? [Playlist]
        }
        
        return nil
    }
    
    static func savePlaylist(playlist : [Playlist]?) {
        
        let archivedObject = archivePlaylist(people: playlist!)
        UserDefaults.standard.set(archivedObject, forKey: primaryKey)
        UserDefaults.standard.synchronize()
    }
    
    static func saveSinglePlaylist(playlist: Playlist, index:Int) {
        
        var plists = ArchiveUtil.loadPlaylist()
        plists?[index] = playlist
        ArchiveUtil.savePlaylist(playlist: plists)        
    }
    
}
