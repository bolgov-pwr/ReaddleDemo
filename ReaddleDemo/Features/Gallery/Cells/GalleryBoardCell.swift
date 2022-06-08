//
//  GalleryBoardCell.swift
//  ReaddleDemo
//
//  Created by Ivan Bolgov on 06.06.2022.
//

import UIKit

final class GalleryBoardCell: UICollectionViewCell, NibIdentifiable, ClassIdentifiable {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.cornerRadius = 10
        titleLabel.numberOfLines = 0
        descLabel.numberOfLines = 0
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}

extension GalleryBoardCell: GalleryCellConfigurable {
    func configure(item: GalleryItem) {
        titleLabel.text = item.id
        descLabel.text = item.size
        
        item.url?.getThumbnail { [weak self] image in
            self?.imageView.image = image
        }
    }
}
