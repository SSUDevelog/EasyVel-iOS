//
//  SubscriberAPI.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/05/02.
//

import Foundation

import Moya

final class DefaultFollowService: BaseNetworkService, FollowService {
    
    static let shared = DefaultFollowService()
    private override init() {}
    
    let provider = MoyaProvider<SubscriberTargetType>(plugins: [MoyaLoggerPlugin()])
    
    func addFollow(
        fcmToken: String,
        name: String,
        completion: @escaping (NetworkResult<Any>) -> Void
    ) {
        provider.request(.addSubscriber(fcmToken: fcmToken, name: name)) { result in
            self.disposeNetwork(result,
                                dataModel: VoidDTO.self,
                                completion: completion)
            

        }
    }
    
    func getFollowList(
        completion: @escaping (NetworkResult<Any>) -> Void
    ) {
        provider.request(.getFollowList) { result in
            self.disposeNetwork(result,
                                dataModel: [FollowListResponse].self, completion: completion)
        }
    }
    
    func searchUser(
        name: String,
        completion: @escaping (NetworkResult<Any>) -> Void
    ) {
        provider.request(.searchUser(name: name)) { result in
            self.disposeNetwork(result,
                                dataModel: SearchUserResponse.self, completion: completion)
        }
    }
    
    func deleteFollow(
        targetName: String,
        completion: @escaping (NetworkResult<Any>) -> Void
    ) {
        provider.request(.deleteFollow(targetName: targetName)) { result in
            self.disposeNetwork(result,
                                dataModel: UnFollowResponse.self, completion: completion)
        }
    }
    
    func getFollowUserMain(
        name: String,
        completion: @escaping (NetworkResult<Any>) -> Void
    ) {
        provider.request(.getSubscriberUserMain(name: name)) { result in
            self.disposeNetwork(result,
                                dataModel: FollowUserMainResponse.self, completion: completion)
        }
    }
}
