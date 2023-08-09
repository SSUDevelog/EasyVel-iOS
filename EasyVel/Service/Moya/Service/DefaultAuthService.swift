//
//  SignAPI.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/05/02.
//

import Foundation

import Moya

final class DefaultAuthService: BaseNetworkService, AuthService {
  
    static let shared = DefaultAuthService()
    private override init() {}
    
    let provider = MoyaProvider<SignTargetType>(plugins: [MoyaLoggerPlugin()])
    
    func signIn(
        body: SignInRequest,
        completion: @escaping (NetworkResult<Any>) -> Void
    ) {
        provider.request(.signIn(body: body)) { result in
            self.disposeNetwork(result,
                                dataModel: SignInResponse.self,
                                completion: completion)
        }
    }
    
    func signOut(
        completion: @escaping (NetworkResult<Any>) -> Void
    ) {
        provider.request(.signOut) { result in
            self.disposeNetwork(result,
                                dataModel: SignOutResponse.self.self,
                                completion: completion)
        }
    }
    
    func signUp(
        body: SignUpRequest,
        completion: @escaping (NetworkResult<Any>) -> Void
    ) {
        provider.request(.signUp(body: body)) { result in
            self.disposeNetwork(result,
                                dataModel: SignUpResponse.self,
                                completion: completion)
        }
    }
    
    func refreshToken(
        token: String,
        completion: @escaping (NetworkResult<Any>) -> Void
    ) {
        provider.request(.refreshToken(token: token)) { result in
            self.disposeNetwork(result,
                                     dataModel: String.self,
                                     completion: completion)
        }
    }
    
    func appleSignIn(
        identityToken: String,
        completion: @escaping (NetworkResult<Any>) -> Void
    ) {
        provider.request(.appleSignIn(identityToken: identityToken)) { result in
            switch result {
            case.success(let response):
                let statusCode = response.statusCode
                let data = response.data
                
                let decoder = JSONDecoder()
                
                switch statusCode {
                case 200..<300:
                    guard let decodedData = try? decoder.decode(SignInResponse.self, from: data) else {
                        completion(.decodedErr)
                        return
                    }
                    completion(.success(decodedData))
                    
                case 400..<500:
                    self.provider.request(.appleSignIn(identityToken: identityToken)) { result in
                        switch result {
                        case .success(let response):
                            let statusCode = response.statusCode
                            let data = response.data
                            switch statusCode {
                            case 200..<300:
                                guard let decodedData = try? decoder.decode(SignInResponse.self, from: data) else {
                                    completion(.decodedErr)
                                    return
                                }
                                completion(.success(decodedData))
                                
                            case 400..<500:
                                completion(.pathErr)
                            case 500:
                                completion(.serverErr)
                            default:
                                completion(.networkFail)
                                //MARK: - retry
                            }
                            
                        case .failure:
                            completion(.networkFail)
                        }
                       
                        return
                    }
                        
                case 500:
                    completion(.serverErr)
                default:
                    completion(.networkFail)
                }
                
            case .failure(let err):
                print(err)
            }
        }
    }
    
}
