//
//  UserRepository.swift
//  VelogOnMobile
//
//  Created by 장석우 on 2023/07/07.
//

import Foundation

import RxSwift

//MARK: - Data Layer

protocol UserRepository {
    func fetchAccessToken() -> String
    func saveAccessToken(_ token: String)
    func refreshAccessToken(_ token: String) -> Observable<String>
    func requestAppleLogin(_ identityToken: String) -> Observable<String>
}

final class DefaultUserRepository: UserRepository {
    
    //MARK: - Properties
    
    private let realmService: RealmService
    private let authService: AuthService
    
    //MARK: - Life Cycle

    init(realmService: RealmService,
         authService: AuthService) {
        self.realmService = realmService
        self.authService = authService
    }
    
    //MARK: - Realm
    
    func fetchAccessToken() -> String {
        realmService.getAccessToken()
    }
    
    func saveAccessToken(_ token: String) {
        realmService.setAccessToken(accessToken: token)
    }
    
    //MARK: - Network
    
    func refreshAccessToken(_ token: String) -> Observable<String> {
        return Observable<String>.create { observer in
            self.authService.refreshToken(token: token) { result in
                switch result {
                case .success(let data):
                    guard let refreshToken = data as? String else { return
                        observer.onError(AuthError.decodedError)
                    }
                    observer.onNext(refreshToken)
                    observer.onCompleted()
                case .decodedErr:
                    observer.onError(AuthError.decodedError)
                default:
                    observer.onError(AuthError.refreshError)
                }
            }
            return Disposables.create()
        }
    }
    
    func requestAppleLogin(_ identityToken: String) -> Observable<String> {
        
        return Observable<String>.create { observer in
            self.authService.appleSignIn(identityToken: identityToken) { result in
                switch result {
                case .success(let data):
                    guard let response = data as? SignInResponse else { return
                        observer.onError(AuthError.decodedError)
                    }
                    guard let token = response.token else {
                        return observer.onError(AuthError.decodedError)
                    }
                    observer.onNext(token)
                    observer.onCompleted()
                case .decodedErr:
                    observer.onError(AuthError.decodedError)
                default:
                    observer.onError(AuthError.refreshError)
                }
            }
            return Disposables.create()
        }
    }
    
    
}
