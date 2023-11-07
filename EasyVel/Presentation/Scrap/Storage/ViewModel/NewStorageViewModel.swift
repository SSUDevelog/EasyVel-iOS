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
    
    private var folderName: String
    private var unScrappedPostURLs: [String] = []
    
    // MARK: - Input & Output
    
    struct Input {
        let fetchPostTrigger: Driver<Void>
        let deleteFolderTrigger: Driver<Void>
        
        init(_ fetchPostTrigger: Driver<Void>,
             _ deleteFolderTrigger: Driver<Void>) {
            self.fetchPostTrigger = fetchPostTrigger
            self.deleteFolderTrigger = deleteFolderTrigger
        }
    }
    
    struct Output {
        let storagePosts: Driver<[StoragePost]>
        let folderDeleted: Driver<Void>
        
        init(_ storagePosts: Driver<[StoragePost]>,
             _ folderDeleted: Driver<Void>) {
            self.storagePosts = storagePosts
            self.folderDeleted = folderDeleted
        }
    }
    
    struct CellInput {
        let editPostStatusTrigger: Driver<String>
        
        init(_ editPostStatusTrigger: Driver<String>) {
            self.editPostStatusTrigger = editPostStatusTrigger
        }
    }
    
    struct CellOutput {
        let newPosts: Driver<[StoragePost]>
        
        init(_ newPosts: Driver<[StoragePost]>) {
            self.newPosts = newPosts
        }
    }
    
    struct HeaderInput {
        let changeNameTrigger: Driver<Void>
        
        init(_ changeNameTrigger: Driver<Void>) {
            self.changeNameTrigger = changeNameTrigger
        }
    }
    
    struct HeaderOutput {
        let showChangeNameAlert: Driver<String>
        
        init(_ showChangeNameAlert: Driver<String>) {
            self.showChangeNameAlert = showChangeNameAlert
        }
    }
    
    // MARK: - Initialize
    
    init(folderName: String) {
        self.folderName = folderName
    }
    
    // MARK: - Transform
    
    func transform(_ input: Input) -> Output {
        let storagePosts = input.fetchPostTrigger
            .map { [weak self] _ -> [StoragePost] in
                guard let self = self else { return [] }
                return self.getRealmStoragePosts(from: self.folderName)
            }
        
        let folderDeleted = input.deleteFolderTrigger
            .map { [weak self] in
                guard let self = self else { return }
                self.deleteStorageFolder(of: self.folderName)
            }
        
        return Output(storagePosts, folderDeleted)
    }
    
    func transformCell(_ input: CellInput) -> CellOutput {
        let newStoragePosts = input.editPostStatusTrigger
            .map { [weak self] url -> [StoragePost] in
                guard let self = self else { return [] }
                self.realm.deletePost(url: url)
                return self.getRealmStoragePosts(from: self.folderName)
            }
        
        return CellOutput(newStoragePosts)
    }
    
    func transformHeader(_ input: HeaderInput) -> HeaderOutput {
        let showChangeNameAlert = input.changeNameTrigger
            .map { [weak self] in
                guard let self = self else { return String() }
                return self.folderName
            }
        
        return HeaderOutput(showChangeNameAlert)
    }
}

// MARK: - Realm Functions

extension NewStorageViewModel {
    
    private func getRealmStoragePosts(from name: String) -> [StoragePost] {
        let realmPosts = self.realm.getFolderPosts(folderName: name)
        let storagePosts = self.realm.convertToStoragePost(input: realmPosts)
        return storagePosts.reversed()
    }
    
    private func isFolderNameUnique(_ newName: String) -> Bool {
        return self.realm.checkUniqueFolderName(newFolderName: newName)
    }
    
    private func deleteStorageFolder(of name: String) {
        return self.realm.deleteFolder(folderName: name)
    }
}
