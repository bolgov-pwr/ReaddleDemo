//
//  ImageViewModel.swift
//  ReaddleDemo
//
//  Created by Ivan Bolgov on 07.06.2022.
//

import UIKit

protocol ImageViewModelProtocol {
    var image: GalleryImage { get }
    func showImage()
}

final class ImageViewModel: ImageViewModelProtocol {
    
    let image: GalleryImage
    
    weak var view: ImageViewController?
    
    init(
        image: GalleryImage
    ) {
        self.image = image
    }
    
    func showImage() {
        let imageModel = image
        
        image.url?.getOriginalImage { [weak self] oImage in
            guard let image = oImage else { return }
            UIView.animate(withDuration: 0.6) {
                
                let model = ImagePresentModel(
                    name: imageModel.name,
                    size: imageModel.mbytesFormatted,
                    modifyDate: "\nModified: \(imageModel.dateFormatted)",
                    resolution: "\nDimensions: \(imageModel.resolution(image))",
                    image: image)
                self?.view?.setInformation(model: model)
            }
        }
    }
}
