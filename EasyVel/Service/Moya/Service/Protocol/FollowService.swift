//
//  SubscriberRepository.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/05/02.
//

import Foundation

protocol FollowService {
    func addFollow(fcmToken: String, name: String, completion: @escaping (NetworkResult<Any>) -> Void)
    func getFollowList(completion: @escaping (NetworkResult<Any>) -> Void)
    func searchUser(name: String, completion: @escaping (NetworkResult<Any>) -> Void)
    func deleteFollow(targetName: String, completion: @escaping (NetworkResult<Any>) -> Void)
    func getFollowUserMain(name: String, completion: @escaping (NetworkResult<Any>) -> Void)
}
