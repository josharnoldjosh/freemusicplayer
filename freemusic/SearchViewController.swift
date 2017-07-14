//
//  SearchViewController.swift
//  freemusic
//
//  Created by Josh Arnold on 18/05/17.
//  Copyright © 2017 Josh Arnold. All rights reserved.
//

import UIKit
import SwipeCellKit
import SDWebImage

class SearchViewController: ViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, SwipeTableViewCellDelegate {
    
    var searchBar:SearchBar!
    
    var promptLabel:UILabel!
    
    var tableView:SearchResultTableView!
    var suggestionTableView:UITableView!
    
    var results:[[String:NSObject]]! = []
    
    let imageCache:SDImageCache = SDImageCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.applyGradient(colours: [UIColor(red:0.36, green:0.53, blue:0.90, alpha:1.0), UIColor(red:0.21, green:0.82, blue:0.86, alpha:1.0)], locations: [0, 1])
        
        // Search bar
        searchBar = SearchBar()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        promptLabel = UILabel(frame: view.bounds.insetBy(dx: 64, dy: 64))
        promptLabel.text = "Discover music, videos, podcasts and more."
        promptLabel.numberOfLines = 0
        promptLabel.font = UIFont(name: "Avenir Next", size: 21)
        promptLabel.textAlignment = .center
        promptLabel.textColor = .white
        promptLabel.center.x = view.center.x
        promptLabel.center.y = view.center.y - 100
        view.addSubview(promptLabel)
        
        let tableFrame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height-112-ad_offset_constant)
        tableView = SearchResultTableView(frame: tableFrame, style: .plain)
        tableView.register(ResultTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.alpha = 0
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        suggestionTableView = SearchResultTableView(frame: tableFrame, style: .plain)
        suggestionTableView.alpha = 0
        suggestionTableView.delegate = self
        suggestionTableView.dataSource = self
        suggestionTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell2")
        suggestionTableView.tag = 3
        view.addSubview(suggestionTableView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.expandTableView), name: NSNotification.Name(rawValue: "showMusicPlayer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.hideTableView), name: NSNotification.Name(rawValue: "minimiseMusicPlayer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.resetTableViewFrame), name: NSNotification.Name(rawValue: "hide_ads"), object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func dismissKeyboard() {
        searchBar.endEditing(true)
//        
//        if self.tableView.alpha == 1 {
//            
//            UIView.animate(withDuration: 0.5, animations: {
//                self.suggestionTableView.alpha = 0
//            }, completion: nil)
//            
//        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dismissKeyboard()
    }
    
    func showPrompt() {
        UIView.animate(withDuration: 1) {
            self.promptLabel.alpha = 1
            self.tableView.alpha = 0
        }
    }
    func hidePrompt() {
        UIView.animate(withDuration: 1) {
            self.promptLabel.alpha = 0
            self.tableView.alpha = 1
        }
    }
    
    func expandTableView() {
        UIView.animate(withDuration: 0.15) {
            self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height+112)
            self.suggestionTableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height+112)
        }
    }
    func hideTableView() {
        UIView.animate(withDuration: 0.15) {
            self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height-ad_offset_constant-49)
            self.suggestionTableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height-ad_offset_constant-49)
        }
    }
    
    func resetTableViewFrame() {
        UIView.animate(withDuration: 0.15) {
            self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            self.suggestionTableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.dismissKeyboard()
        
        // secret code to disable ads 😉
        if searchBar.text == "watermelon don krieg" {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hide_ads"), object: nil)
        }else{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "show_ads"), object: nil)
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            self.suggestionTableView.alpha = 0
        }, completion: nil)
        
        // set the content offset
        tableView.setContentOffset(.zero, animated: true)
        
        YouTubeAPI.search(searchBar.text!.trimmingCharacters(in: .whitespacesAndNewlines)) { (result) in
            self.results = result.0
            DispatchQueue.main.async {
                // Update UI
                self.tableView.reloadData()
                self.hidePrompt()
            }
        }
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tableView.setContentOffset(.zero, animated: true)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.suggestionTableView.alpha = 1
        }, completion: nil)
        
    }
    var suggestedSearches:[String]! = []
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        UIView.animate(withDuration: 0.5, animations: {
            self.suggestionTableView.alpha = 1
        }, completion: nil)
        
        YouTubeAPI.suggested(text: searchText) { (result) in
            DispatchQueue.main.async {
                self.suggestedSearches = result
                self.suggestionTableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 3 {
            return suggestedSearches.count
        }
        return results.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 3 {
            return 60
        }
        return 100
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.tag == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath)
            cell.backgroundColor = .primary
            cell.backgroundView?.backgroundColor = .primary
            cell.contentView.backgroundColor = .primary
            cell.textLabel?.textColor = UIColor.lightGray
            cell.textLabel?.font = UIFont(name: "Avenir Next", size: 15)
            
            let view = UIView()
            view.backgroundColor = .secondary
            cell.selectedBackgroundView = view
            
            let search = suggestedSearches[indexPath.row]
            cell.textLabel?.text = search
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ResultTableViewCell
            cell.delegate = self
            
            let dict = results[indexPath.row]["snippet"] as? [String:NSObject]
            
            cell.title.text = dict?["title"] as! String?
            cell.subtitle.text = dict?["channelTitle"] as! String?
            
            if let urlString = (((dict?["thumbnails"] as? [String:AnyObject])?["high"]) as? [String:AnyObject])?["url"] as? String {
                
                let url = URL(string: urlString)!
                
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
            }
            
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView.tag == 3 {
            let searchText = suggestedSearches[indexPath.row]
            searchBar.text = searchText
            self.searchBarSearchButtonClicked(searchBar)
        }else{
            if (tabBarController != nil) {
                let vc = tabBarController as! TabBarController
                vc.minimiseMusicPlayer()
                vc.musicPlayerView.isPlayingPlaylist = false
                vc.musicPlayerView.startPlayingSong(results[indexPath.row])
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right || orientation == .left else { return nil }
        guard tableView.tag != 3 else { return nil }
        let save = SwipeAction(style: .default, title: "Add to playlist") { action, indexPath in
            let vc = PlaylistViewController()
            vc.isAddingSong = true
            vc.selectedSong = self.results[indexPath.row]
            let nav = NavigationViewController(rootViewController: vc)
            self.present(nav, animated: true, completion: nil)
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

extension UIView {
    func applyGradient(colours: [UIColor]) -> Void {
        self.applyGradient(colours: colours, locations: nil)
    }
    
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
    }
}
