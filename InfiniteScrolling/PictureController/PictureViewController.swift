//
//  PictureViewController.swift
//  InfiniteScrolling
//
//  Created by Andrey Antipov on 14.02.2021.
//

import UIKit

class PictureViewController: UIViewController {
    var url: String? {
        didSet {
            guard let url = url else { return }
            photoImageView.dowloadFromServer(link: url)
        }
    }
    
    var date: Date? {
        didSet {
            guard let date = date else { return }
            downloadDateTimeLabel.text = "Download date: " + date.datetimeToString()
        }
    }
    
    var color: UIColor? {
        didSet {
            photoImageView.backgroundColor = color
        }
    }

    /// Picture (photo)
    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .white
        return imageView
    }()
    
    /// Download date+time
    private lazy var downloadDateTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()

    override func viewDidLoad() {
        view.backgroundColor = .white
        setupLayout()
    }
    
    func setupLayout() {
        view.addSubview(photoImageView)
        view.addSubview(downloadDateTimeLabel)

        let safe = view.safeAreaLayoutGuide
        let constraints = [
            photoImageView.topAnchor.constraint(equalTo: safe.topAnchor),
            photoImageView.leadingAnchor.constraint(equalTo: safe.leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: safe.trailingAnchor),
            photoImageView.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -40),
            downloadDateTimeLabel.heightAnchor.constraint(equalToConstant:20),
            downloadDateTimeLabel.centerXAnchor.constraint(equalTo: safe.centerXAnchor),
            downloadDateTimeLabel.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -16)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
