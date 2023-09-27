//
//  Array+Extension.swift
//  EasyVel
//
//  Created by 이성민 on 2023/09/06.
//

import Foundation

extension Array {
    
    func mapToTuple<S, T>(
        _ f1: (Element) -> S,
        _ f2: (Element) -> T
    ) -> [(S, T)] {
        var returnList: [(S, T)] = []
        self.forEach {
            let temp = (f1($0), f2($0))
            returnList.append(temp)
        }
        return returnList
    }
    
}
