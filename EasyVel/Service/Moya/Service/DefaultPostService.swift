//
//  PostsAPI.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/05/02.
//

import Foundation

import Moya

final class DefaultPostService: BaseNetworkService, PostService {
    
    let provider = MoyaProvider<PostTargetType>(plugins: [MoyaLoggerPlugin()])
    
    func getSubscriberPosts(
        completion: @escaping (NetworkResult<Any>) -> Void
    ) {
        provider.request(.getSubscriberPosts) { result in
            self.disposeNetwork(result,
                                dataModel: GetSubscriberPostResponse.self,
                                completion: completion)
        }
    }
    
    func getTagPosts(
        completion: @escaping (NetworkResult<Any>) -> Void
    ) {
        provider.request(.getTagPosts) { result in
            self.disposeNetwork(result,
                                dataModel: GetTagPostResponse.self,
                                completion: completion)
        }
    }
    
    func getOneTagPosts(
        tag: String,
        completion: @escaping (NetworkResult<Any>) -> Void
    ) {
        provider.request(.getOneTagPosts(tag: tag)) { result in
            self.disposeNetwork(result,
                                dataModel: [PostDTO].self,
                                completion: completion)
        }
    }
    
    
    func getPopularPosts(
        completion: @escaping (NetworkResult<Any>) -> Void
    ) {
        provider.request(.getPopularPosts) { result in
            self.disposeNetwork(result,
                                dataModel: [String].self,
                                completion: completion)
        }
    }
    
    func getTrendPosts(
        completion: @escaping (NetworkResult<Any>) -> Void
    ) {
        provider.request(.trendsPosts) { result in
            self.disposeNetwork(result,
                                dataModel: TrendPostResponse.self.self,
                                completion: completion)
        }
    }
}
