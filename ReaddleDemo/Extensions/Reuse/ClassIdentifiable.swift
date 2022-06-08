//
//  ClassIdentifiable.swift
//  ReaddleDemo
//
//  Created by Ivan Bolgov on 06.06.2022.
//

import Foundation

protocol ClassIdentifiable: AnyObject {
    static var reuseId: String { get }
}

extension ClassIdentifiable {
    static var reuseId: String {
        return String(describing: self)
    }
}
