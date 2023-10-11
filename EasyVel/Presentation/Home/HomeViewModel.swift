//
//  HomeViewModel.swift
//  EasyVel
//
//  Created by 장석우 on 2023/10/05.
//

import Foundation

import RxCocoa
import RxSwift

final class HomeViewModel {
    
    // MARK: - Properties
    
    private let service: TagService
    
    // MARK: - Initialize
    
    init(service: TagService) {
        self.service = service
    }
    
    
    
    // MARK: - Input
    
    struct Input {
        let viewDidLoadEvent: Observable<Void>
        let updateHomeEvent: Observable<Void>
    }
    
    struct Output {
        let tags = BehaviorRelay<[String]>(value: [])
    }
    
    // MARK: - Custom Functions
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        
        let output = Output()
        
        Observable.merge(input.viewDidLoadEvent,
                         input.updateHomeEvent)
            .subscribe(with: self, onNext: { owner, _ in
                owner.requestGetTagAPI(output: output)
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
}

extension HomeViewModel {
    private func requestGetTagAPI(output: Output) {
        service.getTag { result in
            switch result {
            case .success(let response):
                guard let response = response as? [String] else { return }
                output.tags.accept(response)
            default : break
            }
        }
    }
}
