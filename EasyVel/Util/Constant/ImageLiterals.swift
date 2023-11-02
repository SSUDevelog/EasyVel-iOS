//
//  ImageLiterals.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/04/29.
//

import UIKit

enum ImageLiterals {
    
    // MARK: - sign in
    
    static var signInViewImage: UIImage { .load(name: "signInIcon") }
    
    // MARK: - tabBar
    
    static var home: UIImage { .load(name: "home") }
    static var homeFill: UIImage { .load(name: "home.fill") }
    static var list: UIImage { .load(name: "list") }
    static var listFill: UIImage { .load(name: "list.fill") }
    static var bookMark: UIImage { .load(name: "bookmark") }
    static var bookMarkFill: UIImage { .load(name: "bookmark.fill") }
    static var my: UIImage { .load(name: "my") }
    static var myFill: UIImage { .load(name: "my.fill") }
    
    // MARK: - icon
    
    static var searchIcon: UIImage { .load(name: "search") }
    static var searchGray: UIImage { .load(name: "search.gray") }
    static var plusFolder: UIImage { .load(name: "plusFolder") }
    static var activePlusFolder: UIImage { .load(name: "activePlusFolder") }
    static var scrapFolderIcon: UIImage { .load(name: "scrapFolderIcon") }
    static var plusIcon: UIImage { .load(name: "plus") }
    static var subscriberAddIcon: UIImage { .load(name: "addIcon" ) }
    static var subscriberImage: UIImage { .load(name: "subscriberImage") }
    static var defaultProfileImage: UIImage { .load(name: "subscriberImage").resizeImage(to: .init(width: 20, height: 20))! }
    static var tagPlusIcon: UIImage { .load(name: "tagPlusIcon") }
    static var xMarkIcon: UIImage { .load(name: "xmark") }
    static var viewPopButtonIcon: UIImage { .load(name: "viewPopButtonIcon") }
    static var alertIcon: UIImage { .load(name: "alert") }
    
    // MARK: - Exception
    
    static var emptyAlarm: UIImage { .load(name: "empty_alarm") }
    static var emptyPosts: UIImage { .load(name: "empty_posts") }
    static var emptyKeywords: UIImage { .load(name: "empty_keywords") }
    static var emptyFoundUser: UIImage { .load(name: "empty_founduser") }
    static var emptyFollower: UIImage { .load(name: "empty_follower") }
    
    static var failServer: UIImage { .load(name: "fail_server") }
    static var failWeb: UIImage { .load(name: "fail_web") }
    static var failNetwork: UIImage { .load(name: "fail_network") }
}

extension UIImage {
    static func load(name: String) -> UIImage {
        guard let image = UIImage(named: name, in: nil, compatibleWith: nil) else {
            return UIImage()
        }
        image.accessibilityIdentifier = name
        return image
    }
    
    static func load(systemName: String) -> UIImage {
        guard let image = UIImage(systemName: systemName, compatibleWith: nil) else {
            return UIImage()
        }
        image.accessibilityIdentifier = systemName
        return image
    }
}
