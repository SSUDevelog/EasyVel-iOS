//
//  StoragePost.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/05/05.
//

import Foundation

struct StoragePost: Codable, Equatable, Hashable {
    let img: String?
    let name: String?
    let summary: String?
    let title: String?
    let url: String?
    
    init(img: String? = nil,
         name: String? = nil,
         summary: String? = nil,
         title: String? = nil,
         url: String? = nil) {
        self.img = img
        self.name = name
        self.summary = summary
        self.title = title
        self.url = url
    }
}
