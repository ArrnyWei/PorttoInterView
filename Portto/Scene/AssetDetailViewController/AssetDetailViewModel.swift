//
//  AssetDetailViewModel.swift
//  Portto
//
//  Created by Shih Chi Wei on 2022/4/23.
//

import Foundation
import RxSwift
import RxRelay

class AssetDetailViewModel {

    let assetRelay = BehaviorRelay<AssetDecoder.Asset?>(value: nil)

    var asset: AssetDecoder.Asset! {
        didSet {
            self.assetRelay.accept(asset)
        }
    }
}
