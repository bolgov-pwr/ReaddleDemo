//
//  GalleryImage.swift
//  ReaddleDemo
//
//  Created by Ivan Bolgov on 06.06.2022.
//

import Foundation
import UIKit

struct GalleryImage {
    let url: URL?
    let name: String
    let size: Int
    
    var modificationDate: Date? {
        guard let url = url else { return nil }
        let attr = try? FileManager.default.attributesOfItem(atPath: url.path)
        return attr?[FileAttributeKey.modificationDate] as? Date
    }
    
    var mbytesFormatted: String {
        let mb = Double(size) / 1024 / 1024
        return "\(String(format: "%.2f", mb)) Mb"
    }
    
    var dateFormatted: String {
        let df = DateFormatter()
        df.dateFormat = "HH:mm MM.dd"
        let formattedDate = df.string(from: modificationDate ?? Date())
        return formattedDate
    }
    
    func resolution(_ image: UIImage) -> String {
        let w = Int(image.size.width)
        let h = Int(image.size.height)
        let fileResolution = "\(w)x\(h)"
        return fileResolution
    }
}

extension GalleryImage: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    static func == (lhs: GalleryImage, rhs: GalleryImage) -> Bool {
        return lhs.name == rhs.name
    }
}
