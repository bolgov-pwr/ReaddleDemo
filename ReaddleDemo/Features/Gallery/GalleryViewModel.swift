//
//  GalleryViewModel.swift
//  ReaddleDemo
//
//  Created by Ivan Bolgov on 06.06.2022.
//

import UIKit

protocol GalleryViewModelProtocol {
    var style: GalleryStyle { get }
    var sort: GallerySort { get }
    var view: GalleryViewControllerProtocol! { get set }
    
    func getList()
    func setGallery()
    func updateStyle(to newStyle: GalleryStyle)
    func updateSort(to newSort: GallerySort)
    
    func select(_ galleryItem: GalleryItem)
}

protocol GalleryViewModelDelegate: AnyObject {
    func selected(_ image: GalleryImage)
}

enum GalleryStyle {
    case board
    case table
}

enum GallerySort {
    case inc
    case dec
}

final class GalleryViewModel: GalleryViewModelProtocol {
    
    weak var view: GalleryViewControllerProtocol!
    
    var style: GalleryStyle = .table
    var sort: GallerySort = .dec
    
    private var provider: ImageProvider
    private var storage: Storage
    
    private var delegate: GalleryViewModelDelegate?
    
    init(
        delegate: GalleryViewModelDelegate?,
        provider: ImageProvider,
        storage: Storage
    ) {
        self.provider = provider
        self.storage = storage
        self.delegate = delegate
    }
    
    func getList() {
        ActivityIndicator.shared.show()

        provider.fetchImages { [weak self] files in
            
            guard let sSelf = self else { return }
            
            let images = files
                .map { file -> GalleryImage in
                    return GalleryImage(url: nil, name: file.name ?? "", size: 0)
                }
            
            DispatchQueue.main.async {
                sSelf.updateDataSource(gallery: images)
            }
            
        } completion: { [weak self] name, data in
            
            guard let sSelf = self else { return }
            let gallery = sSelf.storage.save(image: (name, data))
                .sorted(by: { sSelf.sorting(el1: $0.size, el2: $1.size) })
            
            DispatchQueue.main.async {
                sSelf.updateDataSource(gallery: gallery)
            }
            
        } finished: {
            ActivityIndicator.shared.hide()
        }
    }
    
    func setGallery() {
        let gallery = storage.fetchGallery()
            .sorted(by: { sorting(el1: $0.size, el2: $1.size) })
        updateDataSource(gallery: gallery)
    }
    
    func updateStyle(to newStyle: GalleryStyle) {
        guard style != newStyle else { return }
        style = newStyle
        view.transitionReload()
    }
    
    func updateSort(to newSort: GallerySort) {
        guard sort != newSort else { return }
        sort = newSort
        setGallery()
    }
    
    func select(_ galleryItem: GalleryItem) {
        guard let image = storage.fetchImage(by: galleryItem.id) else { return }
        delegate?.selected(image)
    }
    
    private func updateDataSource(gallery: [GalleryImage]) {
        var snapshot = NSDiffableDataSourceSnapshot<String, GalleryItem>()
        snapshot.appendSections(["gallery"])
        
        let items = gallery.map { GalleryItem(id: $0.name, url: $0.url, size: $0.mbytesFormatted) }
        
        snapshot.appendItems(items)
        view.dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func updateDataSource(image: GalleryImage) {
        var snapshot = view.dataSource.snapshot()
        var items = snapshot.itemIdentifiers
        if let indexToRemove = snapshot.itemIdentifiers.firstIndex(where: { $0.id == image.name }) {
            items.remove(at: indexToRemove)
        }
        items.append(GalleryItem(id: image.name, url: image.url, size: image.mbytesFormatted))
        snapshot.reloadItems(items)
        
        view.dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func sorting<T: Comparable>(el1: T, el2: T) -> Bool {
        switch sort {
        case .inc: return el1 < el2
        case .dec: return el1 > el2
        }
    }
}
