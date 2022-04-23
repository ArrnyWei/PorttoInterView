//
//  AssetUseCase.swift
//  Portto
//
//  Created by Shih Chi Wei on 2022/4/23.
//

import Foundation
import RxSwift

protocol SyncAssetListUseCase {
    func getAssetList(next: String?, completion: @escaping (Result<AssetDecoder, Error>) -> Void)
    func getBalance(completion: @escaping (Result<BalanceDecoder, Error>) -> Void)
}

class syncAssetListUseCase: SyncAssetListUseCase {

    private var disposeBag = DisposeBag()
    func getAssetList(next: String? = nil, completion: @escaping (Result<AssetDecoder, Error>) -> Void) {
        AssetRepository.shared.getAsset(next: next).subscribe(onNext: { result in
            completion(result)
        }).disposed(by: disposeBag)
    }

    func getBalance(completion: @escaping (Result<BalanceDecoder, Error>) -> Void) {
        AssetRepository.shared.getBalance().subscribe(onNext: { result in
            completion(result)
        }).disposed(by: disposeBag)
    }
}
