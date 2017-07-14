//
//  ResultTableViewCell.swift
//  freemusic
//
//  Created by Josh Arnold on 20/05/17.
//  Copyright © 2017 Josh Arnold. All rights reserved.
//

import UIKit
import SwipeCellKit

class ResultTableViewCell: SwipeTableViewCell {
    
    var webImage:UIImageView!
    var title:UILabel!
    var subtitle:UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "cell")
        
        backgroundColor = .primary
        backgroundView?.backgroundColor = .primary
        contentView.backgroundColor = .primary

        let view = UIView()
        view.backgroundColor = .secondary
        selectedBackgroundView = view
        
        webImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 100))
        webImage.backgroundColor = .primaryLight
        webImage.alpha = 0
        contentView.addSubview(webImage)
        
        title = UILabel(frame: CGRect(x: 158, y: 8, width: frame.width-162, height: 60))
        title.textColor = .white
        title.font = UIFont(name: "Avenir Next", size: 15)
        title.numberOfLines = 0
        contentView.addSubview(title)
        
        subtitle = UILabel(frame: CGRect(x: 158, y: 68, width: frame.width-162, height: 16))
        subtitle.textColor = .lightGray
        subtitle.font = UIFont(name: "Avenir Next", size: 13)
        subtitle.numberOfLines = 0
        contentView.addSubview(subtitle)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
