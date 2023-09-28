//
//  PostsViewModel.swift
//  EasyVel
//
//  Created by 이성민 on 2023/08/26.
//

import Foundation

import RxSwift
import RxCocoa
import RxRelay

final class PostsViewModel: BaseViewModel {
    
    // MARK: - Properties
    
    let realm = RealmService()
    let service = DefaultPostService.shared
    
    private var viewType: ViewType
    private var tag: String
    
    // MARK: - Input
    
    struct Input {
        let fetchTrigger: Observable<Void>
        let reloadTrigger: Observable<[PostDTO]>
        
        init(_ fetchTrigger: Observable<Void>,
             _ reloadTrigger: Observable<[PostDTO]>) {
            self.fetchTrigger = fetchTrigger
            self.reloadTrigger = reloadTrigger
        }
    }
    
    struct Output {
        let postList: Driver<[PostModel]>
        let isPostListEmpty: Driver<Bool>
        let reloadedPostList: Driver<[PostModel]>
        
        init(_ postList: Driver<[PostModel]>,
             _ isPostListEmpty: Driver<Bool>,
             _ reload: Driver<[PostModel]>) {
            self.postList = postList
            self.isPostListEmpty = isPostListEmpty
            self.reloadedPostList = reload
        }
    }
    
    // MARK: - Initialize
    
    init(
        viewType: ViewType,
        tag: String = ""
    ) {
        self.viewType = viewType
        self.tag = tag
        super.init()
    }
    
    // MARK: - Custom Functions
    
    func transform(input: Input) -> Output {
        let postList = input.fetchTrigger
            .startWith(LoadingView.showLoading())
            .flatMapLatest { _ -> Observable<[PostDTO]?> in
                self.getPosts()
            }
            .map { postDTOs -> [PostDTO] in
                return postDTOs ?? []
            }
            .map { posts -> [PostModel] in
                LoadingView.hideLoading()
                return posts.map { self.convertPostDtoToPostModel(post: $0) }
            }
            .asDriver(onErrorJustReturn: [])
        
        let isPostListEmpty = postList
            .map { $0.isEmpty }
            .asDriver(onErrorJustReturn: true)
        
        let reloadedPostList = input.reloadTrigger
            .map { posts -> [PostModel] in
                return posts.map { self.convertPostDtoToPostModel(post: $0) }
            }
            .asDriver(onErrorJustReturn: [])
        
        return Output(postList, isPostListEmpty, reloadedPostList)
    }
    
}

// MARK: - func

extension PostsViewModel {
    
    private func convertPostDtoToStoragePost(
        input: PostDTO
    ) -> StoragePost {
        return StoragePost(
            img: input.img ?? "",
            name: input.name ?? "",
            summary: input.summary ?? "",
            title: input.title ?? "",
            url: input.url ?? ""
        )
    }
    
    private func convertPostDtoToPostModel(
        post: PostDTO
    ) -> PostModel {
        let storagePost = self.convertPostDtoToStoragePost(input: post)
        let isScrapped = self.isPostScrapped(post: storagePost)
        return PostModel(post: post, isScrapped: isScrapped)
    }
    
    func scrapPost(
        _ model: PostModel
    ) {
        let storagePost = convertPostDtoToStoragePost(input: model.post)
        if isPostScrapped(post: storagePost) {
            guard let url = storagePost.url else { return }
            self.realm.deletePost(url: url)
        } else {
            self.realm.addPost(item: storagePost, folderName: TextLiterals.allPostsScrapFolderText)
        }
    }
    
    private func isPostScrapped(
        post: StoragePost
    ) -> Bool {
        return realm.containsPost(input: post)
    }
    
    private func getPosts() -> Observable<[PostDTO]?> {
        switch viewType {
        case .trend:
            return self.getTrendPosts()
        case .follow:
            return self.getSubscriberPosts()
        case .keyword:
            return self.getOneTagPosts(tag: self.tag)
        }
    }
    
}

// MARK: - api

extension PostsViewModel {
    
    func getOneTagPosts(tag: String) -> Observable<[PostDTO]?> {
        return Observable.create { observer in
            self.service.getOneTagPosts(tag: tag) { [weak self] result in
                switch result {
                case .success(let response):
                    guard let posts = response as? [PostDTO] else {
                        self?.serverFailOutput.accept(true)
                        observer.onError(NSError(domain: "ParsingError", code: 0, userInfo: nil))
                        return
                    }
                    observer.onNext(posts)
                    observer.onCompleted()
                case .requestErr(_):
                    self?.serverFailOutput.accept(true)
                    observer.onError(NSError(domain: "requestErr", code: 0, userInfo: nil))
                default:
                    self?.serverFailOutput.accept(true)
                    observer.onError(NSError(domain: "UnknownError", code: 0, userInfo: nil))
                }
            }
            return Disposables.create()
        }
    }
    
    func getTrendPosts() -> Observable<[PostDTO]?> {
        return Observable.create { observer in
            self.service.getTrendPosts() { [weak self] result in
                switch result {
                case .success(let response):
                    guard let posts = response as? TrendPostResponse else {
                        self?.serverFailOutput.accept(true)
                        observer.onError(NSError(domain: "ParsingError", code: 0, userInfo: nil))
                        return
                    }
                    observer.onNext(posts.trendPostDtos)
                    observer.onCompleted()
                case .requestErr(_):
                    self?.serverFailOutput.accept(true)
                    observer.onError(NSError(domain: "requestErr", code: 0, userInfo: nil))
                default:
                    self?.serverFailOutput.accept(true)
                    observer.onError(NSError(domain: "UnknownError", code: 0, userInfo: nil))
                }
            }
            return Disposables.create()
        }
    }
    
    func getSubscriberPosts() -> Observable<[PostDTO]?> {
        return Observable.create { observer in
            self.service.getSubscriberPosts() { [weak self] result in
                switch result {
                case .success(let response):
                    guard let posts = response as? GetSubscriberPostResponse else {
                        self?.serverFailOutput.accept(true)
                        observer.onError(NSError(domain: "ParsingError", code: 0, userInfo: nil))
                        return
                    }
                    observer.onNext(posts.subscribePostDtoList)
                    observer.onCompleted()
                case .requestErr(_):
                    self?.serverFailOutput.accept(true)
                    observer.onError(NSError(domain: "requestErr", code: 0, userInfo: nil))
                default:
                    self?.serverFailOutput.accept(true)
                    observer.onError(NSError(domain: "UnknownError", code: 0, userInfo: nil))
                }
            }
            return Disposables.create()
        }
    }
    
}
