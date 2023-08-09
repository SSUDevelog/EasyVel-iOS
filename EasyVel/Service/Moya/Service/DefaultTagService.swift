//
//  TagAPI.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/05/02.
//

import Foundation

import Moya

final class DefaultTagService: BaseNetworkService, TagService {
    
    static let shared = DefaultTagService()
    private override init() {}

    let provider = MoyaProvider<TagTargetType>(plugins: [MoyaLoggerPlugin()])
    
    func addTag(
        tag: String,
        completion: @escaping (NetworkResult<Any>) -> Void
    ) {
        provider.request(.addTag(tag: tag)) { result in
            self.disposeNetwork(result,
                                dataModel: VoidDTO.self,
                                completion: completion)
        }
    }
    
    func deleteTag(
        tag: String,
        completion: @escaping (NetworkResult<Any>) -> Void
    ) {
        provider.request(.deleteTag(tag: tag)) { result in
            self.disposeNetwork(result,
                                dataModel: VoidDTO.self,
                                completion: completion)
        }
    }
    
    func getTag(
        completion: @escaping (NetworkResult<Any>) -> Void
    ) {
        provider.request(.getTag) { result in
            self.disposeNetwork(result,
                                 dataModel: [String].self,
                                 completion: completion)
        }
    }
}
