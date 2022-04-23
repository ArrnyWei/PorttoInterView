//
//  AssetViewModel.swift
//  Portto
//
//  Created by Shih Chi Wei on 2022/4/23.
//

import Foundation
import RxSwift
import RxRelay

class AssetViewModel {

    var disposeBag = DisposeBag()
    var assetUseCase = syncAssetListUseCase()

    let assetListRelay = BehaviorRelay<[AssetDecoder.Asset]?>(value: nil)
    let balanceRelay = BehaviorRelay<Double?>(value: nil)

    var assetListArray: [AssetDecoder.Asset] = []
    var next: String? = nil

    let errorRelay = PublishRelay<Error>()

    func syncData(next: String? = nil, reNew: Bool = true) {
        assetUseCase.getAssetList(next: next) { [weak self] result in
            ensureInMainQueue {
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.errorRelay.accept(error)
                case .success(let assetDecoder):
                    if reNew {
                        self.assetListArray = assetDecoder.assets
                    } else {
                        self.assetListArray.append(contentsOf: assetDecoder.assets)
                    }
                    self.next = assetDecoder.next
                    self.assetListRelay.accept(self.assetListArray)
                }
            }
        }

        assetUseCase.getBalance { [weak self] result in
            ensureInMainQueue {
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.errorRelay.accept(error)
                case .success(let balanceDecoder):
                    self.balanceRelay.accept(Double(self.strHex2Int(String(balanceDecoder.result.suffix(balanceDecoder.result.count - 2)))) / 1000000000000000000)
                }
            }
        }
    }

    func nextPage() {
        if let next = self.next {
            syncData(next: next, reNew: false)
        }
    }

    func strHex2Int(_ strHex:String) -> Int {
        let nInt = Int(strHex, radix: 16)
        return nInt!
    }
}
