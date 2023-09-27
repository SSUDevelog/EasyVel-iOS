//
//  PostsViewController.swift
//  EasyVel
//
//  Created by 이성민 on 2023/08/25.
//

import UIKit

import RxSwift
import RxRelay
import RxCocoa

enum ViewType {
    case trend
    case follow
    case keyword
}

final class PostsViewController: RxBaseViewController<PostsViewModel> {
    
    // MARK: - Property
    
    private var posts: [PostDTO]?
    private var isNavigationBarHidden: Bool?
    
    // MARK: - UI Property
    
    private let postsViewModel: PostsViewModel
    private let postsView = PostsView()
    
    // MARK: - Life Cycle
    
    override init(
        viewModel: PostsViewModel
    ) {
        self.postsViewModel = viewModel
        super.init(viewModel: viewModel)
        self.view = postsView
    }
    
    init(viewModel: PostsViewModel,
         isNavigationBarHidden: Bool) {
        self.postsViewModel = viewModel
        super.init(viewModel: viewModel)
        self.isNavigationBarHidden = isNavigationBarHidden
    }
    
    init(
        viewModel: PostsViewModel,
        posts: [PostDTO],
        isNavigationBarHidden: Bool
    ) {
        self.postsViewModel = viewModel
        super.init(viewModel: viewModel)
        self.posts = posts
        self.isNavigationBarHidden = isNavigationBarHidden
        self.view = postsView
    }
    
    // MARK: - Setting
    
    override func bind(viewModel: PostsViewModel) {
        let reload = postsView.refreshControl.rx
            .controlEvent(.valueChanged)
            .asObservable()
        let viewWillAppear = viewModel.viewWillAppear
            .asObservable()
        let postTrigger = Observable.merge(reload, viewWillAppear)
        
        let input = PostsViewModel.Input(postTrigger)
        let output = viewModel.transform(input: input)
        
        output.postList
            .drive(self.postsView.collectionView.rx.items) { collectionView, item, post in
                let cell: PostsCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: .init(item: item, section: 0))
                cell.loadPost(post)
                self.bind(cell: cell)
                self.postsView.collectionView.refreshControl?.endRefreshing()
                return cell
            }.disposed(by: disposeBag)
        
        output.isPostListEmpty
            .drive(onNext: { [weak self] isEmpty in
                self?.showEmptyView(when: isEmpty)
            }).disposed(by: disposeBag)
    }
    
    // MARK: - Action Helper
    
    
    
    // MARK: - Custom Method
    
    private func showEmptyView(when isPostEmpty: Bool) {
        self.postsView.keywordsPostsViewExceptionView.isHidden = !isPostEmpty
    }
    
    private func bind(cell: PostsCollectionViewCell) {
        cell.scrapButtonObservable
            .drive(onNext: { [weak self] post in
                guard let post = post else { return }
                self?.postsViewModel.scrapPost(post)
            }).disposed(by: cell.disposeBag)
    }
}
