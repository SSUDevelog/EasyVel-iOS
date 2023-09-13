//
//  SubscriberRouter.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/05/02.
//

import Foundation

import Moya

enum SubscriberTargetType {
    case addSubscriber(fcmToken: String, name: String)
    case getFollowList
    case searchUser(name: String)
    case deleteFollow(targetName: String)
    case getSubscriberUserMain(name: String)
}

extension SubscriberTargetType: BaseTargetType {
    var path: String {
        switch self {
        case .addSubscriber:
            return URLConstants.subscriber + "/addsubscriber"
        case .getFollowList:
            return URLConstants.subscriber + "/getsubscriber"
        case .searchUser(let name):
            return URLConstants.subscriber + "/inputname/" + name
        case .deleteFollow(let targetName):
            return URLConstants.subscriber + "/unsubscribe/" + targetName
        case .getSubscriberUserMain(let name):
            return URLConstants.subscriber + "/usermain/" + name
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .addSubscriber:
            return .post
        case .getFollowList, .searchUser, .getSubscriberUserMain:
            return .get
        case .deleteFollow:
            return .delete
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .addSubscriber(let fcmToken, let name):
            return .requestParameters(
                parameters: ["fcmToken": fcmToken,
                             "name": name],
                encoding: URLEncoding.queryString
            )
        case .getFollowList:
            return .requestPlain
        case .searchUser(let name):
            return .requestParameters(
                parameters: ["name": name],
                encoding: URLEncoding.queryString
            )
        case .deleteFollow(let targetName):
            return .requestParameters(
                parameters: ["targetName": targetName],
                encoding: URLEncoding.queryString
            )
        case .getSubscriberUserMain(let name):
            return .requestParameters(
                parameters: ["name": name],
                encoding: URLEncoding.queryString
            )
        }
    }
}
