//
//  SettingViewCell.swift
//  Bodabi
//
//  Created by jaehyeon lee on 27/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class SettingViewCell: UITableViewCell {
    
    // MARK: - Property
    
    public var setting: SettingOptions? {
        didSet {
            guard let setting = setting else {
                textLabel?.text = ""
                detailTextLabel?.text = ""
                return
            }
            
            switch setting {
            case .fontSize:
                let fontSize = UserDefaults.standard.integer(forKey: "UserFontSize")
                detailTextLabel?.isHidden = false
                detailTextLabel?.text = String(fontSize)
            default:
                detailTextLabel?.isHidden = true
            }
            
            textLabel?.text = setting.description()
        }
    }
    
    // MARK: - Life Cycle

    override func prepareForReuse() {
        super.prepareForReuse()
        self.setting = nil
    }
}
