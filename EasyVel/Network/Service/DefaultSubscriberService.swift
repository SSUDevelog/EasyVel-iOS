//
//  SubscriberAPI.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/05/02.
//

import Foundation

import Moya

final class DefaultSubscriberService: BaseNetworkService, SubscriberService {
    
    static let shared = DefaultSubscriberService()
    private override init() {}
    
    let provider = MoyaProvider<SubscriberTargetType>(plugins: [MoyaLoggerPlugin()])
    
    func addSubscriber(
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
    
    func getSubscriber(
        completion: @escaping (NetworkResult<Any>) -> Void
    ) {
        provider.request(.getSubscriber) { result in
            self.disposeNetwork(result,
                                dataModel: [SubscriberListResponse].self, completion: completion)
        }
    }
    
    func searchSubscriber(
        name: String,
        completion: @escaping (NetworkResult<Any>) -> Void
    ) {
        provider.request(.searchSubscriber(name: name)) { result in
            self.disposeNetwork(result,
                                dataModel: SearchSubscriberResponse.self, completion: completion)
        }
    }
    
    func deleteSubscriber(
        targetName: String,
        completion: @escaping (NetworkResult<Any>) -> Void
    ) {
        provider.request(.deleteSubscriber(targetName: targetName)) { result in
            self.disposeNetwork(result,
                                dataModel: UnSubscribeResponse.self, completion: completion)
        }
    }
    
    func getSubscriberUserMain(
        name: String,
        completion: @escaping (NetworkResult<Any>) -> Void
    ) {
        provider.request(.getSubscriberUserMain(name: name)) { result in
            self.disposeNetwork(result,
                                dataModel: SubscriberUserMainResponse.self, completion: completion)
        }
    }
}
