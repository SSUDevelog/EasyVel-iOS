//
//  CheckVersionRepository.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/07/01.
//

import Foundation

protocol VersionService {
    func getVersion(completion: @escaping (NetworkResult<Any>) -> Void)
}
