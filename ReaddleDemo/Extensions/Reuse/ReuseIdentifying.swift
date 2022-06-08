//
//  ReuseIdentifying.swift
//  ReaddleDemo
//
//  Created by Ivan Bolgov on 06.06.2022.
//

import UIKit

protocol ReuseIdentifying {
    static var reuseIdentifier: String { get }
}

extension ReuseIdentifying {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}

extension UIViewController: ReuseIdentifying { }
