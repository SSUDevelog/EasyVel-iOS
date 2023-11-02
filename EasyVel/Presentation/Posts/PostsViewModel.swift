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
    
    var disposeBag = DisposeBag()
    
    //MARK: - Life Cycle
    
    // MARK: - Input
    
    struct Input {
        let viewDidLoadEvent: Observable<Void>
        let refreshEvent: Observable<Void>
        let scrapButtonDidTap: Observable<PostModel>
    }
    
    struct Output {
        let postList: Driver<[PostModel]>
        let isPostListEmpty: Driver<Bool>
        let successScrap: Driver<Void>
        
        init(_ postList: Driver<[PostModel]>,
             _ isPostListEmpty: Driver<Bool>,
             _ successScrap: Driver<Void>) {
            self.postList = postList
            self.isPostListEmpty = isPostListEmpty
            self.successScrap = successScrap
        }
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
    
    func transform(input: Input) -> Output {
        let postList = Observable<Void>.merge(input.viewDidLoadEvent,
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
            .map { posts -> [PostModel] in
                return posts.map {
                    let isScrappedPost = self.repository.isScrappedPost($0)
                    return $0.toPostModel(isScrapped: isScrappedPost)
                }
            }
            .asDriver(onErrorJustReturn: [])
        
        let isPostListEmpty = postList
            .map { $0.isEmpty }
            .asDriver(onErrorJustReturn: true)
        
        input.scrapButtonDidTap
            .bind(with: self) { owner, postModel in
                owner.repository.scrapPost(postModel)
            }
            .disposed(by: disposeBag)
            
        
        let successScrap = input.scrapButtonDidTap
            .flatMapLatest { post -> Observable<Void> in
                self.repository.scrapPost(post)
                return Observable<Void>.just(Void())
            }
            .asDriver(onErrorJustReturn: Void())
        
        return Output(postList, isPostListEmpty, successScrap)
    }
    
}
