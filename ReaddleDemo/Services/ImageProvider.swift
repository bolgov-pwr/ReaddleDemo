//
//  ImageProvider.swift
//  ReaddleDemo
//
//  Created by Ivan Bolgov on 06.06.2022.
//

import Foundation
import GoogleAPIClientForREST

enum ImageProviderError: Error {
    case noData(String)
}

protocol ImageProvider {
    func fetchImages(
        templateCompletion: @escaping (([GTLRDrive_File]) -> Void),
        completion: @escaping ((String, Data) -> Void),
        finished: @escaping () -> Void
    )
}

final class GoogleDiskImageProvider: ImageProvider {
    
    private let service: GTLRDriveService
    private let storage: Storage
    
    init(
        service: GTLRDriveService,
        storage: Storage
    ) {
        self.service = service
        self.service.apiKey = "AIzaSyA-OJeRjXvdkw0DVSjrtjPu7UvZjuOEVeE"
        self.storage = storage
    }
    
    func fetchImages(
        templateCompletion: @escaping (([GTLRDrive_File]) -> Void),
        completion: @escaping ((String, Data) -> Void),
        finished: @escaping () -> Void
    ) {
        listFiles("18yUbgxJDjBYMg8fdL9JAsssIuJUyCtCh") { [weak self] files in
            var count = 0
            var totalCount = files.count
            for file in files {
                if self?.storage.isFileExists(by: file.name ?? "") == false {
                    self?.download(file) { result in
                        
                        switch result {
                        case .success(let data):
                            completion(file.name ?? "", data)
                            count += 1
                            if count == totalCount {
                                finished()
                            }
                            
                        case .failure(let error):
                            print(error.localizedDescription)
                            totalCount -= 1
                        }
                    }
                } else {
                    totalCount -= 1
                }
            }
            if count == totalCount {
                finished()
            } else {
                templateCompletion(files)
            }
        }
    }
    
    private func listFiles(_ folderID: String, completion: @escaping ([GTLRDrive_File]) -> Void) {
        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 100
        query.q = "'\(folderID)' in parents and mimeType != 'application/vnd.google-apps.folder'"
        
        service.executeQuery(query) { (ticket, result, error) in
            let list = result as? GTLRDrive_FileList
            completion(list?.files ?? [])
        }
     }
    
    private func download(_ fileItem: GTLRDrive_File, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let fileID = fileItem.identifier else {
            completion(.failure(ImageProviderError.noData("File hasn't an identifier to download")))
            return
        }
        
        service.executeQuery(GTLRDriveQuery_FilesGet.queryForMedia(withFileId: fileID)) { (ticket, file, error) in
            guard let data = (file as? GTLRDataObject)?.data else {
                completion(.failure(ImageProviderError.noData("File doesn't provided by Google")))
                return
            }
            completion(.success(data))
        }
    }
}
