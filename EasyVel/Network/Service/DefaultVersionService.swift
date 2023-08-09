//
//  DefaultCheckVersionRepository.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/07/01.
//

import Foundation

import Moya

final class DefaultVersionService: BaseNetworkService, VersionService {
    
    static let shared = DefaultVersionService()
    private override init() {}
    
    let provider = MoyaProvider<VersionTargetType>(plugins: [MoyaLoggerPlugin()])
    
    func getVersion(
        completion: @escaping (NetworkResult<Any>) -> Void
    ) {
        provider.request(.versionCheck) { result in
            self.disposeNetwork(result,
                                dataModel: VersionCheckDTO.self,
                                completion: completion)
        }
    }
}
