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
        let fetchPostTrigger: Driver<String>
        let renameFolderTrigger: PublishRelay<([StoragePost], String)>
        let deleteFolderTrigger: PublishRelay<Void>
        let deletePostTrigger: PublishRelay<String>
        
        init(_ fetchPostTrigger: Driver<String>,
             _ renameFolderTrigger: PublishRelay<([StoragePost], String)>,
             _ deleteFolderTrigger: PublishRelay<Void>,
             _ deletePostTrigger: PublishRelay<String>) {
            self.fetchPostTrigger = fetchPostTrigger
            self.renameFolderTrigger = renameFolderTrigger
            self.deleteFolderTrigger = deleteFolderTrigger
            self.deletePostTrigger = deletePostTrigger
        }
    }
    
    struct Output {
        let storagePosts: Driver<[StoragePost]>
        let isStorageEmpty: Driver<Bool>
        let changedFolderName: Driver<String?>
        
        init(_ storagePosts: Driver<[StoragePost]>,
             _ isStorageEmpty: Driver<Bool>,
             _ changedFolderName: Driver<String?>) {
            self.storagePosts = storagePosts
            self.isStorageEmpty = isStorageEmpty
            self.changedFolderName = changedFolderName
        }
    }
    
    // MARK: - Initialize
    
    
    
    // MARK: - Transform
    
    func transform(_ input: Input) -> Output {
        
        
        let storagePosts = input.fetchPostTrigger
            
        
//            .subscribe(with: self) { (owner, name) -> [StoragePost] in
//                owner.folderName = name
//                return owner.getRealmStoragePosts(from: name)
//            }.disposed(by: disposeBag)
        
        
//            .map { [weak self] name -> [StoragePost] in
//                self?.folderName = name
//                return self?.getRealmStoragePosts(from: name) ?? []
//            }
//            .asDriver(onErrorJustReturn: [])
        
        let isStorageEmpty = storagePosts
            .map { $0.isEmpty }
            .asDriver(onErrorJustReturn: true)
        
        let changedFolderName = input.renameFolderTrigger
            .map { [weak self] (storagePosts, newName) -> String? in
                guard newName != "", let prevName = self?.folderName else { return nil }
                guard let isUnique = self?.isFolderNameUnique(newName) else { return nil }
                if isUnique {
                    self?.realm.changeFolderNameInStorage(
                        input: storagePosts,
                        oldFolderName: prevName,
                        newFolderName: newName
                    )
                    return newName
                } else {
                    return nil
                }
            }
            .asDriver(onErrorJustReturn: self.folderName)
        
        return Output(storagePosts, isStorageEmpty, changedFolderName)
    }
    
}

// MARK: - Functions

extension NewStorageViewModel {
    
    private func getRealmStoragePosts(from name: String) -> [StoragePost] {
        let realmPosts = self.realm.getFolderPosts(folderName: name)
        let storagePosts = self.realm.convertToStoragePost(input: realmPosts)
        return storagePosts
    }
    
    private func isFolderNameUnique(_ newName: String) -> Bool {
        return self.realm.checkUniqueFolderName(newFolderName: newName)
    }
}
