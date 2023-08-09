//
//  BaseRepository.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/05/02.
//

import Foundation

import Moya

class BaseNetworkService {
    
    private func judgeStatus<T: Codable>(by statusCode: Int, _ data: Data, _ object: T.Type) -> NetworkResult<Any> {
        let decoder = JSONDecoder()
        guard let decodedData = try? decoder.decode(T.self, from: data)
        else {
            print("⛔️ \(self)애서 디코딩 오류가 발생했습니다 ⛔️")
            return .decodedErr
        }
        
        switch statusCode {
        case 200..<300:
            return .success(decodedData as Any)
        case 400..<500:
            guard let decodedData = try? decoder.decode(ErrorResponse.self, from: data) else {
                return .pathErr
            }
            return .requestErr(decodedData)
        case 500:
            return .serverErr
        default:
            return .networkFail
        }
    }
    
    private func judgeSimpleResponseStatus(by statusCode: Int, _ data: Data) -> NetworkResult<Any> {
        
        switch statusCode {
        case 200..<205:
            return .success(Void())
        case 400..<500:
            return .pathErr
        case 500:
            return .serverErr
        default:
            return .networkFail
        }
    }
    
    public func disposeNetwork<T: Codable>(_ result: Result<Response, MoyaError>,
                                    dataModel: T.Type,
                                    completion: @escaping (NetworkResult<Any>) -> Void) {
        print("📍\(#function) 에서 result \(result)")
        switch result{
        case .success(let response):
            let statusCode = response.statusCode
            let data = response.data
            
            if dataModel == String.self {
                guard let data = String(data: data, encoding: .utf8) else {
                    completion(.decodedErr)
                    return
                }
                completion(.success(data))
            }
            
            if dataModel != VoidDTO.self{
                let networkResult = self.judgeStatus(by: statusCode, data, dataModel.self)
                completion(networkResult)
            } else {
                let networkResult = self.judgeSimpleResponseStatus(by: statusCode, data)
                completion(networkResult)
            }
            
        case .failure(let err):
            print(err)
            completion(.serverErr)
        }
    }
    
}


//func isValidData(data: Data, responseData: ResponseData) -> NetworkResult<Any> {
//    let decoder = JSONDecoder()
//    switch responseData {
//    case .checkVersion:
//        guard let decodedData = try? decoder.decode(VersionCheckDTO.self, from: data) else {
//            return .pathErr
//        }
//        return .success(decodedData)
//    case .addTag: return .success((Any).self)
//    case .deleteTag: return .success((Any).self)
//    case .getTag:
//        guard let decodedData = try? decoder.decode([String].self, from: data) else {
//            return .pathErr
//        }
//        return .success(decodedData)
//    case .addSubscriber: return .success((Any).self)
//    case .getSubscriber:
//        guard let decodedData = try? decoder.decode([SubscriberListResponse].self, from: data) else {
//            return .pathErr
//        }
//        return .success(decodedData)
//    case .searchSubscriber:
//        guard let decodedData = try? decoder.decode(SearchSubscriberResponse.self, from: data) else {
//            return .pathErr
//        }
//        return .success(decodedData)
//    case .deleteSubscriber:
//        guard let decodedData = try? decoder.decode(UnSubscribeResponse.self, from: data) else {
//            return .pathErr
//        }
//        return .success(decodedData)
//    case .getSubscriberPosts:
//        guard let decodedData = try? decoder.decode(GetSubscriberPostResponse.self, from: data) else {
//            return .pathErr
//        }
//        return .success(decodedData)
//    case .getTagPosts:
//        guard let decodedData = try? decoder.decode(GetTagPostResponse.self, from: data) else {
//            return .pathErr
//        }
//        return .success(decodedData)
//    case .getOneTagPosts:
//        guard let decodedData = try? decoder.decode([PostDTO].self, from: data) else {
//            return .pathErr
//        }
//        return .success(decodedData)
//    case .signIn:
//        guard let decodedData = try? decoder.decode(SignInResponse.self, from: data) else {
//            return .pathErr
//        }
//        return .success(decodedData)
//    case .signOut:
//        guard let decodedData = try? decoder.decode(SignOutResponse.self, from: data) else {
//            return .pathErr
//        }
//        return .success(decodedData)
//    case .signUp:
//        guard let decodedData = try? decoder.decode(SignUpResponse.self, from: data) else {
//            return .pathErr
//        }
//        return .success(decodedData)
//    case .broadCast:
//        guard let decodedData = try? decoder.decode(BroadcastResponse.self, from: data) else {
//            return .pathErr
//        }
//        return .success(decodedData)
//    case .joinGroup: return .success((Any).self)
//    case .getPopularPosts:
//        guard let decodedData = try? decoder.decode([String].self, from: data) else {
//            return .pathErr
//        }
//        return .success(decodedData)
//    case .getSubscriberUserMain:
//        guard let decodedData = try? decoder.decode(SubscriberUserMainResponse.self, from: data) else {
//            return .pathErr
//        }
//        return .success(decodedData)
//    case .trendPosts:
//        guard let decodedData = try? decoder.decode(TrendPostResponse.self, from: data) else {
//            return .pathErr
//        }
//        return .success(decodedData)
//    case .refreshToken:
//        guard let data = String(data: data, encoding: .utf8) else {
//            return .decodedErr
//        }
//        return .success(data)
//        
//    }
//
