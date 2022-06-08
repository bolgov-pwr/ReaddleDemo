//
//  String+Error.swift
//  ReaddleDemo
//
//  Created by Ivan Bolgov on 08.06.2022.
//

import Foundation

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
