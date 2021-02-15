//
//  FeedCollectionViewCell.swift
//  InfiniteScrolling
//
//  Created by Andrey Antipov on 11.02.2021.
//

import UIKit

class FeedCollectionViewCell: UICollectionViewCell {
    var url: String? {
        didSet {
            guard let url = url else { return }
            photoImageView.dowloadFromServer(link: url)
        }
    }
    
    var exif: [String: String]? {
        didSet {
            guard let exif = exif else { return }
            if exif.count > 0 {
                exifLabel.text = exif.reduce("") {
                    return $0 + $1.key + ": " + $1.value + "\n"
                }
            } else {
                exifLabel.text = "Exif no"
            }
        }
    }
    
    var color: UIColor? {
        didSet {
            photoImageView.backgroundColor = color
        }
    }

    /// Picture (photo)
    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        return imageView
    }()
    
    /// Exif
    private lazy var exifLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 4
        label.textAlignment = .left
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupLayout()
    }
    
    func setupLayout() {
        addSubview(photoImageView)
        addSubview(exifLabel)

        let constraints = [
            photoImageView.topAnchor.constraint(equalTo: topAnchor),
            photoImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            photoImageView.heightAnchor.constraint(equalTo: photoImageView.widthAnchor),
            photoImageView.bottomAnchor.constraint(equalTo: exifLabel.topAnchor, constant: -5),
            exifLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            exifLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            exifLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
