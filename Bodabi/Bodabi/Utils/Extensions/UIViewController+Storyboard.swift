//
//  UIViewController+Storyboard.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 1. 25..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    enum StoryboardType: String {
        case main = "Main"
        case home = "Home"
        case friends = "Friends"
        case noti = "Notification"
        case setting = "Setting"
        case friendHistory = "FriendHistory"
    }
    
    func storyboard(_ type: StoryboardType) -> UIStoryboard {
        return UIStoryboard(name: type.rawValue, bundle: nil)
    }
}
