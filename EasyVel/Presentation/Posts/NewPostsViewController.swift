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
        let viewWillAppear = viewModel.viewWillAppear.asObservable()
        let viewDidScroll = postsView.postsCollectionView.rx.contentOffset
            .filter { contentOffset in
                return contentOffset.y < -30
            }
            .map { _ in () }
            .asObservable()
        
        let input = NewPostsViewModel.Input(postTrigger: Observable.merge(viewWillAppear, viewDidScroll))
        
        let output = viewModel.transform(input: input)
        
        output.postList
            .drive(onNext: { [weak self] posts in
                let postModels = posts.map { (post, isScrapped) in
                    return PostModel(id: UUID(), post: post, isScrapped: isScrapped)
                }
                self?.postsView.dataSource.loadPosts(postModels)
            })
            .disposed(by: disposeBag)
            
    }
    
    // MARK: - Action Helper
    
    
    
    // MARK: - Custom Method
    
}


