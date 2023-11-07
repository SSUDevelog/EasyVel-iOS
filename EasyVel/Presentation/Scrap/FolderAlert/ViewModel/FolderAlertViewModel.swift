//
//  FolderAlertViewModel.swift
//  EasyVel
//
//  Created by JEONGEUN KIM on 11/7/23.
//

import RxSwift
import RxCocoa
import RealmSwift
import Foundation

enum ErrorResult: String {
    case success = ""
    case failure = "이미 존재하는 폴더명입니다."
    
    var isEnabled: Bool {
        switch self {
        case .failure: return false
        case .success: return true
        }
    }
}

final class FolderAlertViewModel: BaseViewModel {
    
    private let viewType: FolderType
    private let folderName: String
    private let realm = RealmService()

    struct Input {
        let addFolderInput: Observable<String>
        let yesDidTap: ControlEvent<Void>
    }
    
    struct Output {
        let errorMessage: Driver<ErrorResult>
        let folderName: Observable<String>
    }
    
    init(viewType: FolderType, folderName: String) {
        self.viewType = viewType
        self.folderName = folderName
    }
    
    func transform(input: Input) -> Output {
        
        let errorMessage =  input.addFolderInput
            .map { folderName -> ErrorResult in
                let storageDTO: StorageDTO = StorageDTO(
                    articleID: UUID(),
                    folderName: folderName,
                    count: 0
                )
                return self.realm.checkUniqueFolder(input: storageDTO) ? .success : .failure
            }
        
        
        let folderName = {
            switch self.viewType {
            case .create:
                
                let newFolderName =  input.yesDidTap
                    .withLatestFrom(input.addFolderInput)
                    .map ({ folderName in
                        let storageDTO: StorageDTO = StorageDTO(
                            articleID: UUID(),
                            folderName: folderName,
                            count: 0
                        )
                        self.realm.addFolder(item: storageDTO)
                        return folderName
                    })
                    .asDriver(onErrorJustReturn: "")
                
                return newFolderName
                
            case .change:
                
                let changeFolderName  =  input.yesDidTap
                    .withLatestFrom(input.addFolderInput)
                    .filter { !$0.isEmpty }
                    .map({ changeFolderName -> String in
                        let oldFolderName = self.folderName
                        let realmData = self.getFolderPostInRealm(
                            folderName: oldFolderName
                        )
                        self.realm.changeFolderNameInStorage(
                            input: realmData,
                            oldFolderName: oldFolderName,
                            newFolderName: changeFolderName
                        )
                        return changeFolderName
                    })
                    .asDriver(onErrorJustReturn: "")
                return changeFolderName
            }
        }()
        
        return Output(errorMessage: errorMessage.asDriver(onErrorJustReturn: .failure) , folderName: folderName.asObservable())
    }
    
    private func getFolderPostInRealm(
        folderName: String
    ) -> [StoragePost] {
        let realmPostData = realm.getFolderPosts(folderName: folderName)
        let posts: [StoragePost] = realm.convertToStoragePost(input: realmPostData)
        let reversePosts = realm.reversePosts(input: posts)
        return reversePosts
    }
}
