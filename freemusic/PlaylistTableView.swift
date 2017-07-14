//
//  PlaylistTableView.swift
//  freemusic
//
//  Created by Josh Arnold on 24/05/17.
//  Copyright © 2017 Josh Arnold. All rights reserved.
//

import UIKit

class PlaylistTableView: UITableView {

    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        
        backgroundColor = .primary
        backgroundView?.backgroundColor = .primary
        separatorColor = .secondary
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
