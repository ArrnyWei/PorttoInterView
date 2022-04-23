//
//  AssetRepository.swift
//  Portto
//
//  Created by Shih Chi Wei on 2022/4/23.
//

import Foundation
import RxSwift
import RxCocoa

class AssetRepository {
    static let shared: AssetRepository = .init()

    func getAsset(format: String = "json",
                  next: String?,
                  limit: Int = 20,
                  owner: String = "0x19818f44faf5a217f619aff0fd487cb2a55cca65") -> Observable<Result<AssetDecoder, Error>>
    {
        var path = "/assets?format=\(format)&owner=\(owner)&limit=\(limit)"
        if let next = next {
            path += "&cursor=\(next)"
        }
        return APIService.shared.request(service: .assetList, path: path, dataModel: AssetDecoder.self)
    }

    func getBalance(owner: String = "0x19818f44faf5a217f619aff0fd487cb2a55cca65") -> Observable<Result<BalanceDecoder, Error>> {
        let path = "https://mainnet.infura.io/v3/755b3352f9a347eb8c25113eb5cd3908"

        return APIService.shared.request(service: .balance, path: path, body: ["jsonrpc": "2.0", "method": "eth_getBalance", "params": [owner, "latest"], "id": 1], dataModel: BalanceDecoder.self)
        
    }
}
