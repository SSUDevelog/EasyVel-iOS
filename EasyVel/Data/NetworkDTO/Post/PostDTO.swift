//
//  PostDTO.swift
//  VelogOnMobile
//
//  Created by 장석우 on 2023/06/27.
//

import Foundation

struct PostDTO: Codable, Hashable {
    let comment: Int?
    let date: String?
    let img: String?
    let like: Int?
    let name: String?
    let subscribed: Bool?
    let summary: String?
    let tag: [String]?
    let title: String?
    let url: String?
}

extension PostDTO {
    func toStoragePost() -> StoragePost {
        return StoragePost(
            img: self.img ?? "",
            name: self.name ?? "",
            summary: self.summary ?? "",
            title: self.title ?? "",
            url: self.url ?? ""
        )
    }
    
    func toPostModel(isScrapped: Bool) -> PostModel {
        return PostModel(post: self, isScrapped: isScrapped)
    }
    
}
