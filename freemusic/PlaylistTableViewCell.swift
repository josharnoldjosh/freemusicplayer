//
//  PlaylistTableViewCell.swift
//  freemusic
//
//  Created by Josh Arnold on 24/05/17.
//  Copyright © 2017 Josh Arnold. All rights reserved.
//

import UIKit
import SwipeCellKit

class PlaylistTableViewCell: SwipeTableViewCell {
    
    var mainImageView:UIImageView!
    var title:UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "cell")
        
        backgroundColor = .primary
        backgroundView?.backgroundColor = .primary
        contentView.backgroundColor = .primary
        
        let view = UIView()
        view.backgroundColor = .secondary
        selectedBackgroundView = view
        
        let height = 70
        let inset = 8
        
        mainImageView = UIImageView(frame: CGRect(x: inset, y: inset, width: height - (inset*2), height: height - (inset*2)))
        mainImageView.backgroundColor = .primaryLight
        mainImageView.alpha = 1
        mainImageView.contentMode = .scaleAspectFill
        mainImageView.layer.cornerRadius = 6
        mainImageView.clipsToBounds = true
        contentView.addSubview(mainImageView)
        
        title = UILabel(frame: CGRect(x: height+(2*inset), y: 0, width: Int(frame.width - CGFloat(height + (inset*2))), height: height))
        title.textColor = .white
        title.font = UIFont(name: "Avenir Next", size: 16)
        title.numberOfLines = 1
        contentView.addSubview(title)
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
