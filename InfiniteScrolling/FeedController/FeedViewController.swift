//
//  FeedViewController.swift
//  InfiniteScrolling
//
//  Created by Andrey Antipov on 11.02.2021.
//

import UIKit

enum MaxCountOfItemsInSection: Int {
    case vertical = 3
    case horizontal = 4
}

class FeedViewController: UIViewController {    
    // How many maximum cells should fit in a section
    private var maxCountOfItemsInSection: Int {
        didSet {
            if let layout = self.collectionView.collectionViewLayout as? CustomCollectionViewFlowLayout {
                layout.numberOfItemsPerRow = maxCountOfItemsInSection
            }
        }
    }
    
    // Collection
    private lazy var collectionView: UICollectionView = {
        // Define the layer
        let layout = CustomCollectionViewFlowLayout()
        layout.numberOfItemsPerRow = maxCountOfItemsInSection
        layout.scrollDirection = .vertical
        // Create a collection with a zero frame and a previously defined layer
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        // Register cell classes
        // Image cell
        collectionView.register(FeedCollectionViewCell.self,
                                forCellWithReuseIdentifier: String(describing: FeedCollectionViewCell.self))
        // Loading cell
        collectionView.register(LoadingCollectionViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: String(describing: LoadingCollectionViewCell.self))

        // Align everything
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        // White background
        collectionView.backgroundColor = .white

        collectionView.dataSource = self
        collectionView.delegate = self

        return collectionView
    }()
    
    private var viewmodel: FeedViewModel
    
    var previewArray = [Item]()

    var loadingView: LoadingCollectionViewCell?

    var isLoading = false
    
    init(maxCountOfItemsInSection: Int, viewmodel: FeedViewModel) {
        self.maxCountOfItemsInSection = maxCountOfItemsInSection
        self.viewmodel = viewmodel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.topItem?.title = "Flickr cars"

        setupLayout()
        
        loadData()
    }
    
    func setupLayout() {
        view.addSubview(collectionView)

        let safe = view.safeAreaLayoutGuide
        let constraints = [
            collectionView.topAnchor.constraint(equalTo: safe.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: safe.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safe.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safe.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func loadData() {
        isLoading = false
        collectionView.collectionViewLayout.invalidateLayout()
        self.viewmodel.getPage(saving: {
            [weak self] items in
            guard let self = self else { return }
            self.previewArray.append(contentsOf: items)
            self.collectionView.reloadData()
            self.isLoading = false
        },
        crash: {
            [weak self] in
            guard let self = self else { return }
            self.isLoading = false
            self.collectionView.collectionViewLayout.invalidateLayout()
        },
        refresh: {
            [weak self] in
            guard let self = self else { return }
            self.collectionView.reloadData()
        })
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            maxCountOfItemsInSection = MaxCountOfItemsInSection.horizontal.rawValue
        } else {
            maxCountOfItemsInSection = MaxCountOfItemsInSection.vertical.rawValue
        }
    }
}
    
extension FeedViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return previewArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: FeedCollectionViewCell.self), for: indexPath) as? FeedCollectionViewCell else { return UICollectionViewCell() }
        
        cell.url = self.previewArray[indexPath.row].urlSmall
        cell.exif = self.previewArray[indexPath.row].exif
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == previewArray.count - 10 && !self.isLoading {
            loadMoreData()
        }
    }

    func loadMoreData() {
            if !self.isLoading {
                self.isLoading = true
                
                self.viewmodel.getPage(saving: {
                    [weak self] items in
                    guard let self = self else { return }
                    self.previewArray.append(contentsOf: items)
                    self.collectionView.reloadData()
                    self.isLoading = false
                },
                crash: {
                    [weak self] in
                    guard let self = self else { return }
                    self.isLoading = false
                    self.collectionView.collectionViewLayout.invalidateLayout()
                },
                refresh: {
                    [weak self] in
                    guard let self = self else { return }
                    self.collectionView.reloadData()
                })
            }
    }

        
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
            if self.isLoading {
                return CGSize.zero
            } else {
                return CGSize(width: collectionView.bounds.size.width, height: 55)
            }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            guard let aFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: LoadingCollectionViewCell.self), for: indexPath) as? LoadingCollectionViewCell else { return UICollectionReusableView() }
            loadingView = aFooterView
            loadingView?.backgroundColor = UIColor.clear
            return aFooterView
        } else { return UICollectionReusableView() }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
            if elementKind == UICollectionView.elementKindSectionFooter {
                self.loadingView?.loadingIndicator.startAnimating()
            }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
            if elementKind == UICollectionView.elementKindSectionFooter {
                self.loadingView?.loadingIndicator.stopAnimating()
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = PictureViewController()
        vc.url = self.previewArray[indexPath.row].urlBig ?? self.previewArray[indexPath.row].urlSmall
        vc.date = self.previewArray[indexPath.row].downloadDate
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
