//
//  PostRepository.swift
//  EasyVel
//
//  Created by 장석우 on 11/2/23.
//

import Foundation

import RxSwift

enum PostRepositoryError: Error {
    case serverError
    case unknown
}

//MARK: - Domain Layer

protocol PostRepository {
    
    // local
    func scrapPost(_ postModel: PostModel)
    func unscrapPost(_ postModel: PostModel)
    func isScrappedPost(_ postDTO: PostDTO) -> Bool
    
    
    // remote
    func getOneTagPosts(tag: String) -> Observable<[PostDTO]>
    func getTrendPosts() -> Observable<[PostDTO]>
    func getSubscriberPosts() -> Observable<[PostDTO]>
    
}

//MARK: - Data Layer

final class DefaultPostRepository: PostRepository {
    
    //MARK: - Properties
    
    private let postService: PostService
    private let realmService: RealmService
    
    //MARK: - Life Cycle
    
    init(postService: PostService, realmService: RealmService) {
        self.postService = postService
        self.realmService = realmService
    }
    
    //MARK: - Realm
    
    func scrapPost(_ postModel: PostModel) {
        let storagePost = postModel.post.toStoragePost()
        self.realmService.addPost(item: storagePost, folderName: TextLiterals.allPostsScrapFolderText)
    }
    
    func unscrapPost(_ postModel: PostModel) {
        let storagePost = postModel.post.toStoragePost()
        guard let url = storagePost.url else { return }
        self.realmService.deletePost(url: url)   
    }
    
    func isScrappedPost(_ postDTO: PostDTO) -> Bool {
        let storagePost = postDTO.toStoragePost()
        return realmService.containsPost(input: storagePost)
    }
    
    //MARK: - PostService
    
    func getOneTagPosts(tag: String) -> Observable<[PostDTO]> {
        return Observable.create { observer in
            self.postService.getOneTagPosts(tag: tag) {result in
                switch result {
                case .success(let response):
                    guard let posts = response as? [PostDTO] else {
                        observer.onError(PostRepositoryError.serverError)
                        return
                    }
                    observer.onNext(posts)
                    observer.onCompleted()
                default:
                    observer.onError(PostRepositoryError.serverError)
                }
            }
            return Disposables.create()
        }
    }
    
    func getTrendPosts() -> Observable<[PostDTO]> {
        return Observable.create { observer in
            self.postService.getTrendPosts() { result in
                switch result {
                case .success(let response):
                    guard let posts = response as? TrendPostResponse else {
                        observer.onError(PostRepositoryError.serverError)
                        return
                    }
                    observer.onNext(posts.trendPostDtos)
                    observer.onCompleted()
                default:
                    observer.onError(PostRepositoryError.serverError)
                }
            }
            return Disposables.create()
        }
    }
    
    func getSubscriberPosts() -> Observable<[PostDTO]> {
        return Observable.create { observer in
            self.postService.getSubscriberPosts() { result in
                switch result {
                case .success(let response):
                    guard let posts = response as? GetSubscriberPostResponse else {
                        observer.onError(PostRepositoryError.serverError)
                        return
                    }
                    observer.onNext(posts.subscribePostDtoList)
                    observer.onCompleted()
                default:
                    observer.onError(PostRepositoryError.serverError)
                }
            }
            return Disposables.create()
        }
    }
    
    
}
