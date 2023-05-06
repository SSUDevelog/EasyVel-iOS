//
//  SubscriberPostsViewModel.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/05/03.
//

import UIKit

import RealmSwift

protocol SubscriberPostsViewModelInput {
    func viewWillAppear()
    // MARK: - fix me
    func cellDidTap(input: StoragePost)
}

protocol SubscriberPostsViewModelOutput {
    var subscriberPostsListOutput: ((GetSubscriberPostResponse) -> Void)? { get set }
    var toastPresent: ((Bool) -> Void)? { get set }
}

protocol SubscriberPostsViewModelInputOutput: SubscriberPostsViewModelInput, SubscriberPostsViewModelOutput {}

final class SubscriberPostsViewModel: SubscriberPostsViewModelInputOutput {
    
    let realm = RealmService()
    
    var subscribePosts: GetSubscriberPostResponse? {
        didSet {
            if let subscribePosts = subscribePosts,
               let subscriberPostsListOutput = subscriberPostsListOutput {
                subscriberPostsListOutput(subscribePosts)
            }
        }
    }
    
    // MARK: - Input
    
    func viewWillAppear() {
        getSubscriberPostsForserver()
    }
    
    func cellDidTap(input: StoragePost) {
        if checkIsUniquePost(post: input) {
            addPostRealm(post: input)
        } else {
            toastPresentOutPut()
        }
    }
    
    // MARK: - Output
    
    var subscriberPostsListOutput: ((GetSubscriberPostResponse) -> Void)?
    var toastPresent: ((Bool) -> Void)?
    
    private func addPostRealm(post: StoragePost) {
        realm.addPost(item: post)
    }
    
    private func checkIsUniquePost(post: StoragePost) -> Bool {
        return realm.checkUniquePost(input: post)
    }
    
    private func toastPresentOutPut() {
        if let toastPresent = toastPresent {
            toastPresent(true)
        }
    }
}

// MARK: - API

private extension SubscriberPostsViewModel {
    func getSubscriberPostsForserver() {
        getSubscriberPosts() { [weak self] result in
            self?.subscribePosts = result
        }
    }
    
    func getSubscriberPosts(completion: @escaping (GetSubscriberPostResponse) -> Void) {
        NetworkService.shared.postsRepository.getSubscriberPosts() { result in
            switch result {
            case .success(let response):
                guard let posts = response as? GetSubscriberPostResponse else { return }
                completion(posts)
            case .requestErr(let errResponse):
                dump(errResponse)
            default:
                print("error")
            }
        }
    }
}