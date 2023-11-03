//
//  PostsViewModel.swift
//  EasyVel
//
//  Created by 이성민 on 2023/08/26.
//

import Foundation

import RxSwift
import RxCocoa

final class PostsViewModel: ViewModelType {
    
    // MARK: - Properties
    
    private let repository: PostRepository
    private var viewType: PostsViewType
    private var tag: String
    
    
    // MARK: - Input
    
    struct Input {
        let viewDidLoadEvent: Observable<Void>
        let refreshEvent: Observable<Void>
        let scrapButtonDidTap: Observable<PostModel>
    }
    
    struct Output {
        let postList = PublishRelay<[PostModel]>()
        let isPostListEmpty = PublishRelay<Bool>()
        let successScrap = PublishRelay<StoragePost>()
    }
    
    // MARK: - Initialize
    
    init(
        repository: PostRepository,
        viewType: PostsViewType,
        tag: String = ""
    ) {
        self.repository = repository
        self.viewType = viewType
        self.tag = tag
    }
    
    // MARK: - Custom Functions
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        
        let output = Output()
        
        Observable<Void>.merge(input.viewDidLoadEvent,
                               input.refreshEvent)
            .startWith(LoadingView.showLoading())
            .flatMapLatest { [weak self] _ -> Observable<[PostDTO]> in
                guard let self else { return .just([])}
                switch self.viewType {
                case .trend:
                    return self.repository.getTrendPosts()
                case .follow:
                    return self.repository.getSubscriberPosts()
                case .keyword:
                    return self.repository.getOneTagPosts(tag: tag)
                }
            }
            .subscribe(with: self, onNext: { owner, postDTOs in
                guard !postDTOs.isEmpty else {
                    output.isPostListEmpty.accept(true)
                    return
                }
                
                let postModels = postDTOs.map { $0.toPostModel(isScrapped: owner.repository.isScrappedPost($0)) }
                output.postList.accept(postModels)
            },onError: { owner, error in
                output.isPostListEmpty.accept(true)
            })
            .disposed(by: disposeBag)
            
        
        input.scrapButtonDidTap
            .subscribe(with: self, onNext: { owner, postModel in
                if postModel.isScrapped {
                    owner.repository.scrapPost(postModel)
                    output.successScrap.accept(postModel.post.toStoragePost())
                } else {
                    owner.repository.unscrapPost(postModel)
                }
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
}
