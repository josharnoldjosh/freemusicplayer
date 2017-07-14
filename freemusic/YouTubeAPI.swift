//
//  YoutubeAPI.swift
//  freemusic
//
//  Created by Josh Arnold on 18/05/17.
//  Copyright © 2017 Josh Arnold. All rights reserved.
//

import Foundation
import XCDYouTubeKit
import TWRDownloadManager


class YouTubeAPI {
    
    /** Search for YouTube videos, returns snippets. */
    class func search(_ text:String, completion:@escaping (_ items:[[String:NSObject]]?, _ error:Error?) -> Void) {
        
        let apiKey:String! = "" // REPLACE ME WITH YOUR OWN YOUTUBE API KEY
        
        let searchText:String! = "&q=" + text.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let maxResults:String! = "&maxResults=50"
        
        let type:String! = "&type=video"
        
        let exclusion:String! = "&videoEmbeddable=true&videoSyndicated=true"
        
        let urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&key=" + apiKey + searchText + maxResults + type + exclusion
        
        let url:URL = URL(string: urlString)!
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            
            do {
                let json:[String:AnyObject] = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String:AnyObject]
                if let items = json["items"] as? [[String:NSObject]] {
                    completion(items, nil)
                }
            } catch let error {
                completion(nil, error)
            }
            
        }
        
        task.resume()
    }
    
    /** Returns an array of suggested searches if there is no error. Warning, this function is not garunteed to return a value. */
    class func suggested(text:String, completion: @escaping ([String]) -> Void) {
        
        let searchText:String! =  text.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let urlString =  "http://suggestqueries.google.com/complete/search?hl=en&ds=yt&client=youtube&hjson=t&cp=1&format=5&alt=json" + "&q=" + searchText
        
        let url:URL = URL(string: urlString)!
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [AnyObject]
                
                var outputArray:[String]! = []
                
                for obj in json {
                    if obj is [NSObject] {
                        for result in (obj as! [NSObject]) {
                            let output = (result as! [NSObject])[0]
                            outputArray.append(output as! String)
                        }
                    }
                }
                completion(outputArray)
            } catch let error {
                print(error)
            }
        }
        task.resume()
    }
    
}

class Downloader {
    
    static let shared:Downloader = Downloader()
    
    /** Downloads a playlist */
    func download(playlist:Playlist, playlistIndex:Int, completion: @escaping () -> Void) {
        
        let client = XCDYouTubeClient()
        
        for song in playlist.songs {
            let videoId = song.id
            
            guard videoId != nil else {return}
            
            if TWRDownloadManager.shared().fileExists(withName: videoId!)  {
                print("file exists!", videoId!)
                self.checkPlaylistDownloaded(playlist: playlist, index: playlistIndex)
            }else{
                
                client.getVideoWithIdentifier(videoId, completionHandler: { (video, error) in
                    guard error == nil && video?.streamURLs != nil else { return }
                    
                    let mp3Url = self.getMp3Link(streamUrls: video!.streamURLs)
                    
                    guard mp3Url != nil else { return }
                    
                    print("Downloading song...")
                    
                    TWRDownloadManager.shared().downloadFile(forURL: mp3Url!.absoluteString, withName: videoId!, inDirectoryNamed: nil, progressBlock: { (progress) in
                        
                    }, completionBlock: { (done) in
                        print(done, "completed", videoId!)
                        self.checkPlaylistDownloaded(playlist: playlist, index: playlistIndex)
                    }, enableBackgroundMode: true)
                })
            }
        }
    }
    
    func delete(playlist:Playlist, playlistIndex:Int, completion: () -> Void) {
        for song in playlist.songs {
            TWRDownloadManager.shared().deleteFile(withName: song.id)
            print("Deleted song", song.title)
            self.checkPlaylistDownloaded(playlist: playlist, index: playlistIndex)
        }
    }
    
    func checkPlaylistDownloaded(playlist:Playlist, index:Int) {
        var notFinished:Bool = false
        
        for song in playlist.songs {
            if !TWRDownloadManager.shared().fileExists(withName: song.id) {
                notFinished = true
                if playlist.downloaded == true {
                    playlist.downloaded = false
                    ArchiveUtil.saveSinglePlaylist(playlist: playlist, index: index)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PlaylistDownloaded"), object: nil)
                }
            }
        }
        
        if notFinished == false {
            playlist.downloaded = true
            ArchiveUtil.saveSinglePlaylist(playlist: playlist, index: index)
            print("Playlist downloaded!", playlist.title)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PlaylistDownloaded"), object: nil)
        }
    }
    
    /** Returns the tag */
    func getMp3Link(streamUrls:[AnyHashable:URL]) -> URL? {
        
        for (itag, streamURL) in streamUrls {
            
            let num = itag as? Int
            guard num != nil else {
                return nil
            }
            
//            print(num)
            
            // 140, 22
            if num! == 22 {
                return streamURL
            }
        }
        return nil
    }
}









