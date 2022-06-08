//
//  ImageViewController.swift
//  ReaddleDemo
//
//  Created by Ivan Bolgov on 07.06.2022.
//

import UIKit

final class ImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var hideConstraint: NSLayoutConstraint!
    
    var viewModel: ImageViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        viewModel.showImage()
    }
    
    private func configureView() {
        title = "Image"
        
        imageView.alpha = 0
        hideConstraint.constant = -500
        
        let infoButton = UIButton(type: .system)
        infoButton.setTitle("Info", for: .normal)
        infoButton.setTitleColor(UIColor.systemBlue, for: .normal)
        infoButton.addTarget(self, action: #selector(infoTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton)
    }
    
    @objc private func infoTapped() {
        UIView.animate(withDuration: 0.3) {
            if self.hideConstraint.constant == 0 {
                self.hideConstraint.constant = -(self.informationLabel.frame.height + self.view.safeAreaInsets.bottom)
            } else {
                self.hideConstraint.constant = 0
            }
            self.view.layoutIfNeeded()
        }
    }
}

extension ImageViewController {
    func setInformation(model: ImagePresentModel) {
        informationLabel.text = "\(model.name) (\(model.size)) \(model.modifyDate) \(model.resolution)"
        UIView.animate(withDuration: 0.6) {
            self.imageView.image = model.image
            self.imageView.alpha = 1
        }
    }
}
