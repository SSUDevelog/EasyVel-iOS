//
//  UIImage+Extension.swift
//  EasyVel
//
//  Created by 이성민 on 2023/08/23.
//

import UIKit
import Kingfisher

extension UIImage {
    
    func resizeImage(to targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resizedImage = renderer.image { context in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        return resizedImage
    }
}



