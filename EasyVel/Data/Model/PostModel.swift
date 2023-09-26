//
//  PostModel.swift
//  EasyVel
//
//  Created by 이성민 on 2023/09/21.
//

import Foundation

struct PostModel: Identifiable, Hashable {
    let id: UUID
    let post: PostDTO?
    var isScrapped: Bool
}
