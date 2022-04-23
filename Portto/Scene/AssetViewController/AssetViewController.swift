//
//  ViewController.swift
//  Portto
//
//  Created by Shih Chi Wei on 2022/4/23.
//

import UIKit
import RxSwift

class AssetViewController: UIFlowViewController {

    var viewModel: AssetViewModel!
    @IBOutlet weak var assetCollectionView: AssetCollectionView!
    @IBOutlet weak var assetCollectionViewFlowLayout: UICollectionViewFlowLayout!

    private var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bindUI()
        bindViewModel()
    }

    private func bindUI() {
        assetCollectionView
            .onScrollToBottomPublisher
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.viewModel.nextPage()
        })
        .disposed(by: disposeBag)

        assetCollectionView.onCellSelectedRelay.subscribe(onNext: { [unowned self] asset in
            self.coordinator.next(from: self, to: AssetDetailViewController.self, bundle: asset)
        }).disposed(by: disposeBag)
    }

    private func bindViewModel() {
        viewModel.assetListRelay
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] list in
            guard let self = self else { return }
            if let list = list {
                self.assetCollectionView.update(list: list)
            }
        }).disposed(by: disposeBag)

        viewModel.errorRelay
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                let alertController = UIAlertController(title: "錯誤", message: "讀取資料錯誤", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "確定", style: .default))
                self?.present(alertController, animated: true)
            }).disposed(by: disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let inset: CGFloat = 16
        let interitemSpacing: CGFloat = 8
        let lineSpacing: CGFloat = 8
        let cardWidth: CGFloat = (self.view.frame.size.width - (interitemSpacing + inset * 2)) / 2
        let cardHeight: CGFloat = cardWidth * 220 / 167

        assetCollectionViewFlowLayout.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        assetCollectionViewFlowLayout.minimumLineSpacing = lineSpacing
        assetCollectionViewFlowLayout.minimumInteritemSpacing = interitemSpacing
        assetCollectionViewFlowLayout.scrollDirection = .vertical
        assetCollectionViewFlowLayout.itemSize.height = cardHeight
        assetCollectionViewFlowLayout.itemSize.width = cardWidth

        viewModel.syncData()
    }
}

