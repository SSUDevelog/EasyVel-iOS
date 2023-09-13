//
//  ListViewModel.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/04/30.
//

import UIKit

import RxRelay
import RxSwift

final class FollowViewModel: BaseViewModel {
    
    let service: FollowService
    
    var followList: [FollowListResponse]?
    var isFollowEmpty: Bool = Bool()
    var tempDeleteFollow: String?
    
    // MARK: - Output

    var followListOutput = PublishRelay<[FollowListResponse]>()
    var isFollowEmptyOutput = PublishRelay<Bool>()
    var followUserMainURLOutput = PublishRelay<String>()
    var presentUnfollowAlertOutput = PublishRelay<Bool>()
    
    // MARK: - Input
    
    let refreshFollowList = PublishRelay<Bool>()
    let followTableViewCellDidTap = PublishRelay<String>()
    let unfollowButtonDidTap = PublishRelay<String>()
    let deleteFollowEvent = PublishRelay<Void>()
    
    // MARK: - init
    
    init(service: FollowService) {
        self.service = service
        super.init()
        makeOutput()
    }
    
    // MARK: - func
    
    private func makeOutput() {
        viewWillAppear
            .subscribe(onNext: { [weak self] in
                self?.getListData()
            })
            .disposed(by: disposeBag)
        
        deleteFollowEvent
            .subscribe(onNext: { [weak self] _ in
                guard let self = self,
                      let tempDeleteSubscriber = tempDeleteFollow else { return }
                if let followList = self.followList {
                    let reloadFollowList = followList.filter {
                        $0.name != tempDeleteSubscriber
                    }
                    self.followList = reloadFollowList
                    self.followListOutput.accept(reloadFollowList)
                }
                self.deleteSubscriber(targetName: tempDeleteSubscriber) { [weak self] _ in
                    self?.getListData()
                }
            })
            .disposed(by: disposeBag)
        
        refreshFollowList
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.getListData()
            })
            .disposed(by: disposeBag)
        
        followTableViewCellDidTap
            .subscribe(onNext: { [weak self] subscriberName in
                guard let self = self else { return }
                self.getSubscriberUserMainURL(
                    name: subscriberName
                ) { [weak self] subscriberUserMainURLString in
                    guard let userMainURL = subscriberUserMainURLString.userMainUrl else { return }
                    self?.followUserMainURLOutput.accept(userMainURL)
                }
            })
            .disposed(by: disposeBag)
        
        unfollowButtonDidTap
            .subscribe { name in
                self.tempDeleteFollow = name
                self.presentUnfollowAlertOutput.accept(true)
            }
            .disposed(by: disposeBag)
    }
    
    private func getListData() {
        getSubscriberList()
            .map { Array($0.reversed()) }
            .subscribe(onNext: { [weak self] subscriberList in
                self?.followList = subscriberList
                self?.followListOutput.accept(subscriberList)
                let subscriberNameList = subscriberList.map { $0.name }
                self?.checkListIsEmpty(subsciberList: subscriberNameList)
            })
            .disposed(by: disposeBag)
    }
    
    private func checkListIsEmpty(
        subsciberList: [String]
    ) {
        if subsciberList.isEmpty == true {
            isFollowEmptyOutput.accept(true)
        } else {
            isFollowEmptyOutput.accept(false)
        }
    }
}

// MARK: - API

private extension FollowViewModel {
    func getSubscriberList() -> Observable<[FollowListResponse]> {
        return Observable.create { observer -> Disposable in
            DefaultFollowService.shared.getFollowList() { [weak self] result in
                switch result {
                case .success(let response):
                    guard let list = response as? [FollowListResponse] else {
                        self?.serverFailOutput.accept(true)
                        return
                    }
                    observer.onNext(list)
                    observer.onCompleted()
                case .requestErr(let errResponse):
                    self?.serverFailOutput.accept(true)
                    dump(errResponse)
                default:
                    self?.serverFailOutput.accept(true)
                    print("error")
                }
            }
            return Disposables.create()
        }
    }
    
    func deleteSubscriber(
        targetName: String,
        completion: @escaping (String) -> Void
    ) {
        DefaultFollowService.shared.deleteFollow(
            targetName: targetName
        ){ [weak self] result in
            switch result {
            case .success(_):
                completion("success")
            case .requestErr(let errResponse):
                self?.serverFailOutput.accept(true)
                dump(errResponse)
            default:
                self?.serverFailOutput.accept(true)
                print("error")
            }
        }
    }
    
    func getSubscriberUserMainURL(
        name: String,
        completion: @escaping (FollowUserMainResponse) -> Void
    ) {
        service.getFollowUserMain(
            name: name
        ) { [weak self] result in
            switch result {
            case .success(let response):
                guard let url = response as? FollowUserMainResponse else {
                    self?.serverFailOutput.accept(true)
                    return
                }
                completion(url)
            case .requestErr(let errResponse):
                self?.serverFailOutput.accept(true)
                dump(errResponse)
            default:
                self?.serverFailOutput.accept(true)
                print("error")
            }
        }
    }
}
