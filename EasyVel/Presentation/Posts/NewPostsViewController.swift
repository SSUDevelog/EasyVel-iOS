//
//  NewPostsViewController.swift
//  EasyVel
//
//  Created by 이성민 on 2023/08/25.
//

import UIKit

import RxSwift
import RxRelay
import RxCocoa

final class NewPostsViewController: RxBaseViewController<NewPostsViewModel> {
    
    // MARK: - Property
    
    private var posts: [PostDTO]?
    private var isScrapPostsList: [Bool]?
    private var isNavigationBarHidden: Bool?
    
    // MARK: - UI Property
    
    private let postsView = PostsView()
    
    // MARK: - Life Cycle
    
    override init(
        viewModel: NewPostsViewModel
    ) {
        super.init(viewModel: viewModel)
        self.view = postsView
    }
    
    init(
        viewModel: NewPostsViewModel,
        isNavigationBarHidden: Bool,
        posts: [PostDTO]
    ) {
        super.init(viewModel: viewModel)
        self.isNavigationBarHidden = isNavigationBarHidden
        self.posts = posts
        self.view = postsView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarIsHidden(isNavigationBarHidden ?? true)
    }
    
    // MARK: - Setting
    
    override func bind(viewModel: NewPostsViewModel) {
        let reload = postsView.postsCollectionView.refreshControl!.rx
            .controlEvent(.valueChanged)
            .asObservable()
        let viewWillAppear = viewModel.viewWillAppear
            .asObservable()
        
        let postTrigger = Observable.merge(reload, viewWillAppear)
        
        let input = NewPostsViewModel.Input(
            postTrigger: postTrigger,
//            scrapButtonTapped: scrapButtonTapped
        )
        
        let output = viewModel.transform(input: input)
        
        output.postList
            .map { $0.map { $0.0 } }

        
    }
    
    // MARK: - Action Helper
    
    
    
    // MARK: - Custom Method
    
}

// MARK: - DatatSource

extension NewPostsViewController {
    
}
