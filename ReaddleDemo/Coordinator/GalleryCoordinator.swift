//
//  GalleryCoordinator.swift
//  ReaddleDemo
//
//  Created by Ivan Bolgov on 07.06.2022.
//

import UIKit

protocol GalleryCoordinatorDelegate: AnyObject {
    func didFinishGalleryCoordinator()
}

class GalleryCoordinator: Coordinator {
    
    weak var delegate: GalleryCoordinatorDelegate?

    lazy var rootViewController: UINavigationController = {
        return window.rootViewController as! UINavigationController
    }()
    
    private let window: UIWindow
    private let provider: ImageProvider
    private let storage: Storage
    
    init(
        window: UIWindow,
        delegate: GalleryCoordinatorDelegate?,
        provider: ImageProvider,
        storage: Storage
    ) {
        self.window = window
        self.delegate = delegate
        self.provider = provider
        self.storage = storage
    }
    
    override func start() {
        let vc = GalleryViewController()
        let vm = GalleryViewModel(delegate: self, provider: provider, storage: storage)
        vc.viewModel = vm
        vc.viewModel.view = vc
        window.rootViewController = UINavigationController(rootViewController: vc)
        window.makeKeyAndVisible()
    }
    
    override func finish() {
        childCoordinators.forEach({
            $0.finish()
            $0.removeAllChildCoordinators()
        })
        removeAllChildCoordinators()
        rootViewController.viewControllers.removeAll()
        delegate?.didFinishGalleryCoordinator()
    }
}

extension GalleryCoordinator: GalleryViewModelDelegate {
    func selected(_ image: GalleryImage) {
        let vm = ImageViewModel(image: image)
        let storyboard = UIStoryboard(name: "Gallery", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: ImageViewController.reuseIdentifier) as! ImageViewController
        vc.viewModel = vm
        vm.view = vc
        rootViewController.pushViewController(vc, animated: true)
    }
}
