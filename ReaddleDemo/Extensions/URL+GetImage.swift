//
//  URL+GetImage.swift
//  ReaddleDemo
//
//  Created by Ivan Bolgov on 08.06.2022.
//

import Foundation
import UIKit

extension URL {
    
    typealias ImageCompletion = (UIImage?) -> Void
    
    func getThumbnail(
        compressionPercent: Double = 0.1,
        queue: DispatchQueue = DispatchQueue.global(qos: .userInteractive),
        completion: @escaping ImageCompletion
    ) {
        queue.async {
            if let data = try? Data(contentsOf: self) {
                let image = UIImage(data: data)?.resized(withPercentage: compressionPercent)
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }
    
    func getOriginalImage(completion: @escaping ImageCompletion) {
        DispatchQueue.global(qos: .userInteractive).async {
            if let data = try? Data(contentsOf: self) {
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }
}
