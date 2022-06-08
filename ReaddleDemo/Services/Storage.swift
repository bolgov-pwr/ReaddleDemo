//
//  Storage.swift
//  ReaddleDemo
//
//  Created by Ivan Bolgov on 06.06.2022.
//

import Foundation

protocol Storage {
    func save(image: (String, Data)) -> [GalleryImage]
    func fetchGallery() -> [GalleryImage]
    func fetchImage(by name: String) -> GalleryImage?
    func isFileExists(by name: String) -> Bool
}

final class FileStortage: Storage {
    
    private let directory = "drive_images"
    
    func save(image: (String, Data)) -> [GalleryImage] {
        let fileManager = FileManager.default
        let documentsFolder = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let folderURL = documentsFolder.appendingPathComponent(directory)
        let folderExists = (try? folderURL.checkResourceIsReachable()) ?? false
        
        if !folderExists {
            try! fileManager.createDirectory(at: folderURL, withIntermediateDirectories: false)
        }
        
        let fileURL = folderURL.appendingPathComponent(image.0)
        if !fileManager.fileExists(atPath: fileURL.path) {
            fileManager.createFile(atPath: fileURL.path, contents: image.1, attributes: nil)
        }
        
        return gallery()
    }
    
    func fetchGallery() -> [GalleryImage] {
        return gallery()
    }
    
    func fetchImage(by name: String) -> GalleryImage? {
        let gallery = gallery()
        return gallery.first(where: { $0.name == name })
    }
    
    func isFileExists(by name: String) -> Bool {
        let gallery = gallery()
        return gallery.contains(where: { $0.name == name })
    }
    
    private func gallery() -> [GalleryImage] {
        let fileManager = FileManager.default
        let documentsFolder = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let folderURL = documentsFolder.appendingPathComponent(directory)
        
        let gallery = ((try? fileManager.contentsOfDirectory(atPath: folderURL.path)) ?? [])
            .map { path -> GalleryImage in
                
                let url = folderURL.appendingPathComponent(path)
                let attr = try! fileManager.attributesOfItem(atPath: url.path)
                let fileSize = attr[FileAttributeKey.size] as! UInt64
                
                return GalleryImage(
                    url: url,
                    name: url.lastPathComponent,
                    size: Int(fileSize))
            }
        return gallery
    }
}
