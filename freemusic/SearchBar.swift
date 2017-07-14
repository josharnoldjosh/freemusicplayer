//
//  SearchBar.swift
//  freemusic
//
//  Created by Josh Arnold on 18/05/17.
//  Copyright © 2017 Josh Arnold. All rights reserved.
//

import UIKit

class SearchBar: UISearchBar {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        tintColor = .highlight
        barTintColor = .secondary
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = .primaryLight
        
        placeholder = "Search"                
        
        //SearchBar Text
        let insideTextfield = self.value(forKey: "searchField") as? UITextField
        insideTextfield?.textColor = .highlight
        
        //SearchBar Placeholder
        let textFieldInsideUISearchBarLabel = insideTextfield!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideUISearchBarLabel?.textColor = .gray
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
