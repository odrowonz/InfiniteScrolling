//
//  FeedCollectionViewCell.swift
//  InfiniteScrolling
//
//  Created by Andrey Antipov on 11.02.2021.
//

import UIKit

class FeedCollectionViewCell: UICollectionViewCell {
    weak var model: FeedViewModel?
    
    var item: Item? {
        didSet {
            guard let item = item else { return }
            
            // set image
            if let smallImage = item.smallImage {
                photoImageView.image = smallImage
            } else {
                photoImageView.image = UIImage(named: "broken")
            }
            
            // set exif
            guard let exif = item.exif else { return }
            if exif.exifs.count > 0 {
                exifLabel.text = exif.exifs.reduce("") {
                    let key: String
                    if let tagspace = $1.tagspace {
                        if let label = $1.label {
                            key = tagspace + ":" + label
                        } else {
                            key = tagspace
                        }
                    } else {
                        if let label = $1.label {
                            key = label
                        } else {
                            return ""
                        }
                    }
                    let value: String = $1.clean ?? ($1.raw ?? "")
                    if let beforeStr = $0 {
                        return beforeStr + key + "=" + value + "\n"
                    } else {
                        return key + "=" + value + "\n"
                    }
                }
            } else {
                exifLabel.text = "Exif no"
            }

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
