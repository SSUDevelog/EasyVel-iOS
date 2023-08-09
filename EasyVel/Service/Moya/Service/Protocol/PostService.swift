//
//  PostsRepository.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/05/02.
//

import Foundation

protocol PostService {
    func getSubscriberPosts(completion: @escaping (NetworkResult<Any>) -> Void)
    func getTagPosts(completion: @escaping (NetworkResult<Any>) -> Void)
    func getPopularPosts(completion: @escaping (NetworkResult<Any>) -> Void)
    func getOneTagPosts(tag: String,
                        completion: @escaping (NetworkResult<Any>) -> Void)
    func getTrendPosts(completion: @escaping (NetworkResult<Any>) -> Void)
}
