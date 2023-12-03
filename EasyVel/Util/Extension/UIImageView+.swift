//
//  UIImageView+.swift
//  EasyVel
//
//  Created by 장석우 on 11/23/23.
//

import UIKit
import Kingfisher

extension UIImageView {
    
    func setDownSampleImage(with url : String?,
                    placeholder: UIImage? = .defaultPost,
                    completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil
    ) {
        guard let url = url,
              let url = URL(string: url) else {
            self.image = placeholder
            return
        }
        
        let processor = DownsamplingImageProcessor(size: self.frame.size)
        
        kf.setImage(with: url,
                    placeholder: placeholder,
                    options: [.processor(processor),
                              .scaleFactor(UIScreen.main.scale),
                              .cacheOriginalImage],
        completionHandler: completionHandler)
        
    }
}
