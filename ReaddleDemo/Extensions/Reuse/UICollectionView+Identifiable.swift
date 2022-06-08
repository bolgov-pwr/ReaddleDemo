//
//  UICollectionView+Identifiable.swift
//  ReaddleDemo
//
//  Created by Ivan Bolgov on 06.06.2022.
//

import UIKit

extension UICollectionView {
    func register<T: UICollectionViewCell>(cellType: T.Type) where T: ClassIdentifiable {
        register(cellType.self, forCellWithReuseIdentifier: cellType.reuseId)
    }

    func register<T: UICollectionViewCell>(cellType: T.Type) where T: NibIdentifiable & ClassIdentifiable {
        register(cellType.nib, forCellWithReuseIdentifier: cellType.reuseId)
    }
    
    func register<T: UICollectionReusableView>(viewType: T.Type) where T: ClassIdentifiable {
        register(viewType.self, forSupplementaryViewOfKind: viewType.reuseId, withReuseIdentifier: String(describing: viewType.reuseId))
    }
    
    func register<T: UICollectionReusableView>(viewType: T.Type) where T: ClassIdentifiable & NibIdentifiable {
        register(viewType.nib, forSupplementaryViewOfKind: viewType.reuseId, withReuseIdentifier: viewType.reuseId)
    }

    func dequeueReusableCell<T: UICollectionViewCell>(withCellType type: T.Type = T.self, forIndexPath indexPath: IndexPath) -> T where T: ClassIdentifiable {
        guard let cell = dequeueReusableCell(withReuseIdentifier: type.reuseId, for: indexPath) as? T else { fatalError(dequeueError(withIdentifier: type.reuseId, type: self)) }

        return cell
    }
}

extension UIView {
    func dequeueError<T>(withIdentifier reuseIdentifier: String, type _: T) -> String {
        return "Couldn't dequeue \(T.self) with identifier \(reuseIdentifier)"
    }
}
