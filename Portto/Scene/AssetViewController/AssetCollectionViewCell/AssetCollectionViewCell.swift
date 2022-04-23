//
//  AssetCollectionViewCell.swift
//  Portto
//
//  Created by Shih Chi Wei on 2022/4/23.
//

import UIKit

class AssetCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var assetImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func bindUI(asset: AssetDecoder.Asset) {
        nameLabel.text = asset.name
        if let url = asset.image_url {
            assetImageView.loadImageUsingCache(withUrl: url)
        } else {
            assetImageView.image = nil
        }
    }
}
