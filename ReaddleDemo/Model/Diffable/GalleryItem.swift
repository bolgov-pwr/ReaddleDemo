//
//  Gallery.swift
//  ReaddleDemo
//
//  Created by Ivan Bolgov on 06.06.2022.
//

import Foundation

struct GalleryItem {
    let id: String
    let url: URL?
    let size: String
}

extension GalleryItem: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: GalleryItem, rhs: GalleryItem) -> Bool {
        return lhs.id == rhs.id && lhs.url == rhs.url && lhs.size == rhs.size
    }
}
