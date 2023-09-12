//
//  KeywordPostsVCFactory.swift
//  VelogOnMobile
//
//  Created by 장석우 on 2023/06/21.
//

import Foundation

final class KeywordPostsVCFactory {
    
    // MARK: - home에서 ViewController 만들 때 사용
    
    func create(tag: String,
                isNavigationBarHidden: Bool = true) -> PostsViewController {
        let vc = PostsViewController(viewModel: PostsViewModel(viewType: .keyword,
                                                               tag: tag,
                                                               service: DefaultPostService.shared),
                                     isNavigationBarHidden: isNavigationBarHidden)
        vc.title = tag
        return vc
    }
    
    
    
    // MARK: - search tagPost에서 ViewController 만들 때 사용
    
    func create(
        tag: String,
        isNavigationBarHidden: Bool,
        postDTOList: [PostDTO]
    ) -> PostsViewController {
        let vc = PostsViewController(
            viewModel: PostsViewModel(viewType: .keyword, tag: tag,service: DefaultPostService.shared),
            isNavigationBarHidden: isNavigationBarHidden,
            posts: postDTOList
        )
        return vc
    }
}
