//
//  GalleryViewController.swift
//  ReaddleDemo
//
//  Created by Ivan Bolgov on 06.06.2022.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST

protocol GalleryViewControllerProtocol: AnyObject {
    var dataSource: UICollectionViewDiffableDataSource<String, GalleryItem>! { get set }
    func transitionReload()
}

final class GalleryViewController: UIViewController, GalleryViewControllerProtocol {

    var viewModel: GalleryViewModelProtocol!
    var boardCollectionView: UICollectionView!
    
    var dataSource: UICollectionViewDiffableDataSource<String, GalleryItem>! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureDataSource()
        viewModel.setGallery()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
                self?.viewModel.getList()
            }
        } else {
            GIDSignIn.sharedInstance.signIn(with: GIDConfiguration(clientID: "178597121047-lp6pkk3f61aqfcueud8l71008a34ol29.apps.googleusercontent.com"), presenting: self, hint: nil, additionalScopes: [kGTLRAuthScopeDrive]) { [weak self] user, error in
                self?.viewModel.getList()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ActivityIndicator.shared.hide()
    }
    
    private func configureView() {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: generateLayout())
        view.addSubview(collectionView)
        view.backgroundColor = collectionView.backgroundColor
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(cellType: GalleryTableCell.self)
        collectionView.register(cellType: GalleryBoardCell.self)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        boardCollectionView = collectionView
        
        title = "Gallery"
        
        let styleButton = UIButton(type: .system)
        let styleItems: [UIAction] = [
            UIAction(title: "Table", image: UIImage(systemName: "sun.max"), handler: { [weak self] _ in
                self?.viewModel.updateStyle(to: .table)
            }),
            UIAction(title: "Board", image: UIImage(systemName: "moon"), handler: { [weak self] _ in
                self?.viewModel.updateStyle(to: .board)
            })
        ]
        let styleMenu = UIMenu(title: "Style", image: nil, identifier: nil, options: [], children: styleItems)
        styleButton.menu = styleMenu
        styleButton.showsMenuAsPrimaryAction = true
        styleButton.setTitle("Style", for: .normal)
        styleButton.setTitleColor(UIColor.systemBlue, for: .normal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: styleButton)
        
        
        let sortButton = UIButton(type: .system)
        let sortItems: [UIAction] = [
            UIAction(title: "Increment", handler: { [weak self] _ in
                self?.viewModel.updateSort(to: .inc)
            }),
            UIAction(title: "Decrement", handler: { [weak self] _ in
                self?.viewModel.updateSort(to: .dec)
            })
        ]
        let sortMenu = UIMenu(title: "Sort", image: nil, identifier: nil, options: [], children: sortItems)
        sortButton.menu = sortMenu
        sortButton.showsMenuAsPrimaryAction = true
        sortButton.setTitle("Sort", for: .normal)
        sortButton.setTitleColor(UIColor.systemBlue, for: .normal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: sortButton)
    }
    
    func transitionReload() {
        UIView.transition(with: boardCollectionView, duration: 0.4, options: .transitionCurlDown) {
            self.boardCollectionView.reloadData()
        } completion: { _ in }
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<String, GalleryItem>(collectionView: boardCollectionView) {
            [weak self] (collectionView: UICollectionView, indexPath: IndexPath, item: GalleryItem) -> UICollectionViewCell? in

            guard let sSelf = self else { fatalError() }
            
            switch sSelf.viewModel.style {
            case .table:
                let cell: GalleryTableCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
                cell.configure(item: item)
                return cell
            case .board:
                let cell: GalleryBoardCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
                cell.configure(item: item)
                return cell
            }
        }
    }

    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let sSelf = self else {
                return NSCollectionLayoutSection(group: .init(layoutSize: .init(widthDimension: .absolute(1), heightDimension: .absolute(1))))
            }
            
            switch sSelf.viewModel.style {
            case .table: return sSelf.generateTableLayout()
            case .board: return sSelf.generateBoardLayout()
            }
        }
        return layout
    }

    func generateTableLayout() -> NSCollectionLayoutSection {
        let spacing: CGFloat = 8
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(101))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: spacing, bottom: 0, trailing: spacing)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(101))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        return NSCollectionLayoutSection(group: group)
    }
    
    func generateBoardLayout() -> NSCollectionLayoutSection {
        let spacing: CGFloat = 16
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1 / 2),
            heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1 / 1.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        return NSCollectionLayoutSection(group: group)
    }
}

extension GalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        viewModel.select(item)
    }
}
