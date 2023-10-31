//
//  NewStorageViewModel.swift
//  EasyVel
//
//  Created by 이성민 on 10/5/23.
//

import Foundation

import RxSwift
import RxCocoa
import RxRelay

final class NewStorageViewModel: BaseViewModel {
    
    // MARK: - Properties
    
    let realm = RealmService()
    var folderName: String?
    
    // MARK: - Input & Output
    
    struct Input {
        let fetchPostTrigger: Driver<String?>
        
        init(_ fetchPostTrigger: Driver<String?>) {
            self.fetchPostTrigger = fetchPostTrigger
        }
    }
    
    struct Output {
        let storagePosts: Driver<[StoragePost]>
        
        init(_ storagePosts: Driver<[StoragePost]>) {
            self.storagePosts = storagePosts
        }
    }
    
    // MARK: - Initialize
    
    
    
    // MARK: - Transform
    
    func transform(_ input: Input) -> Output {
        let storagePosts = input.fetchPostTrigger
            .map { [weak self] folderName -> [StoragePost] in
                guard let self = self else { return [] }
                return self.getRealmStoragePosts(from: folderName ?? "모든 게시글")
            }
            .asDriver()
        
        return Output(storagePosts)
    }
}

// MARK: - Realm Functions

extension NewStorageViewModel {
    
    private func getRealmStoragePosts(from name: String) -> [StoragePost] {
        let realmPosts = self.realm.getFolderPosts(folderName: name)
        let storagePosts = self.realm.convertToStoragePost(input: realmPosts)
        return storagePosts
    }
    
    func deleteRealmStoragePost(of url: String) {
        self.realm.deletePost(url: url)
    }
    
    private func isFolderNameUnique(_ newName: String) -> Bool {
        return self.realm.checkUniqueFolderName(newFolderName: newName)
    }
}
