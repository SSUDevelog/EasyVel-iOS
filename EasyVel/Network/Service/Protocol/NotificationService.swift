//
//  NotificationRepository.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/05/02.
//

import Foundation

protocol NotificationService {
    func broadCast(body: BroadcastRequest, completion: @escaping (NetworkResult<Any>) -> Void)
}
