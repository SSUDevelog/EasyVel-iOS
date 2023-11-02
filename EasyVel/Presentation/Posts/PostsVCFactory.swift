//
//  KeywordPostsVCFactory.swift
//  VelogOnMobile
//
//  Created by 장석우 on 2023/06/21.
//

import Foundation

final class PostsVCFactory {
    
    func createTrend() -> PostsViewController {
        let repository = DefaultPostRepository(postService: DefaultPostService(),
                                               realmService: RealmService())
        let vc = PostsViewController(
            viewModel: PostsViewModel(repository: DefaultPostRepository(postService: DefaultPostService(),
                                                                        realmService: RealmService()),
                                      viewType: .trend),
            isNavigationBarHidden: true)
        
        return vc
    }
    
    func createFollow() -> PostsViewController {
        let repository = DefaultPostRepository(postService: DefaultPostService(),
                                               realmService: RealmService())
        let vc = PostsViewController(
            viewModel: PostsViewModel(repository: DefaultPostRepository(postService: DefaultPostService(),
                                                                        realmService: RealmService()),
                                      viewType: .follow),
            isNavigationBarHidden: true)
        
        return vc
    }
    
    // MARK: - home에서 ViewController 만들 때 사용
    
    func create(
        tag: String
    ) -> PostsViewController {
        let repository = DefaultPostRepository(postService: DefaultPostService(),
                                               realmService: RealmService())
        let vc = PostsViewController(
            viewModel: PostsViewModel(
                repository: repository,
                viewType: .keyword,
                tag: tag)
        )
        return vc
    }
    
    func create(
        tag: String,
        isNavigationBarHidden: Bool
    ) -> PostsViewController {
        let repository = DefaultPostRepository(postService: DefaultPostService(),
                                               realmService: RealmService())
        let vc = PostsViewController(
            viewModel: PostsViewModel(
                repository: repository,
                viewType: .keyword,
                tag: tag),
            isNavigationBarHidden: isNavigationBarHidden
        )
        return vc
    }
    
    
    
    // MARK: - search tagPost에서 ViewController 만들 때 사용
    
    func create(
        tag: String,
        isNavigationBarHidden: Bool,
        postDTOList: [PostDTO]
    ) -> PostsViewController {
        let repository = DefaultPostRepository(postService: DefaultPostService(),
                                               realmService: RealmService())
        let vc = PostsViewController(
            viewModel: PostsViewModel(
                repository: repository,
                viewType: .keyword,
                tag: tag),
            posts: postDTOList, isNavigationBarHidden: isNavigationBarHidden
        )
        return vc
    }
}
