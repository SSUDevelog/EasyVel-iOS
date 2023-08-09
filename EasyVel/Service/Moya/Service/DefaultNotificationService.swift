//
//  NotificationAPI.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/05/02.
//

import Foundation

import Moya

final class DefaultNotificationService: BaseNetworkService, NotificationService {

    static let shared = DefaultNotificationService()
    private override init() {}
    
    let provider = MoyaProvider<NotificationTargetType>(plugins: [MoyaLoggerPlugin()])
    
    func broadCast(
        body: BroadcastRequest,
        completion: @escaping (NetworkResult<Any>) -> Void
    ) {
        provider.request(.broadCast(body: body)) { result in
            self.disposeNetwork(result,
                                dataModel: BroadcastResponse.self, completion: completion)
        }
    }

    func joinGroup(
        body: JoinGroupRequest,
        completion: @escaping (NetworkResult<Any>) -> Void
    ) {
        provider.request(.joingroup(body: body)) { result in
            self.disposeNetwork(result,
                                dataModel: VoidDTO.self, completion: completion)
        }
    }
}
