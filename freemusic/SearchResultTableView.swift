//
//  SearchResultTableView.swift
//  freemusic
//
//  Created by Josh Arnold on 20/05/17.
//  Copyright © 2017 Josh Arnold. All rights reserved.
//

import UIKit

class SearchResultTableView: UITableView {
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        
        backgroundColor = .primary
        backgroundView?.backgroundColor = .primary
        separatorColor = .secondary
            
        // Delay content touches
        delaysContentTouches = false
//        for view in subviews {
//            if view.isKind(of: UIScrollView.self) {
//                (view as! UIScrollView).delaysContentTouches = false
//            }
//        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
}
