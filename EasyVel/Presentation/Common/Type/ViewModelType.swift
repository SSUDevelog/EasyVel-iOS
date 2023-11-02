//
//  ViewModelType.swift
//  EasyVel
//
//  Created by 장석우 on 11/2/23.
//

import Foundation
import RxSwift

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output
}
