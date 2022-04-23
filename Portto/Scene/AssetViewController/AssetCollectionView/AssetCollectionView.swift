//
//  AssetCollectionView.swift
//  Portto
//
//  Created by Shih Chi Wei on 2022/4/23.
//

import UIKit
import RxSwift
import RxRelay

class AssetCollectionView: UICollectionView {

    private var list: [AssetDecoder.Asset] = []
    var onCellSelectedRelay = PublishRelay<AssetDecoder.Asset>()
    var onScrollToBottomPublisher = PublishSubject<Void>()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        register(AssetCollectionViewCell.self)
        self.dataSource = self
        self.delegate = self
    }

    func update(list: [AssetDecoder.Asset]) {
        self.list = list
        reloadData()
    }
}

extension AssetCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: AssetCollectionViewCell.self, for: indexPath)
        cell.bindUI(asset: list[indexPath.row])
        return cell
    }
}

extension AssetCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row > list.count { return }
        onCellSelectedRelay.accept(list[indexPath.row])
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
         if (indexPath.row == list.count - 1 ) { //it's your last cell
             onScrollToBottomPublisher.onNext(())
         }
    }
}
