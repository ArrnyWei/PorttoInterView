//
//  AssetDetailViewController.swift
//  Portto
//
//  Created by Shih Chi Wei on 2022/4/23.
//

import UIKit
import RxSwift
import RxCocoa

class AssetDetailViewController: UIFlowViewController {

    var viewModel: AssetDetailViewModel!
    @IBOutlet weak var assetImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var linkButton: UIButton!

    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        bindUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bindViewModel()
    }

    func bindViewModel() {
        viewModel.assetRelay.subscribe(onNext: { [unowned self] asset in
            if let asset = asset {
                if let name = asset.name {
                    self.nameLabel.text = name
                }

                if let description = asset.description {
                    self.descriptionTextView.text = description
                }

                if let imageUrl = asset.image_url {
                    self.assetImageView.loadImageUsingCache(withUrl: imageUrl)
                }

                if let collectionName = asset.collection?.name {
                    self.title = collectionName
                }
            }
        }).disposed(by: disposeBag)
    }

    func bindUI() {
        linkButton.rx.tap.subscribe(onNext: { [unowned self] in
            if let link = self.viewModel.asset.permalink, let url = URL(string: link) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        }).disposed(by: disposeBag)
    }
}
