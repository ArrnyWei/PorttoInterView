//
//  BalanceDecoder.swift
//  Portto
//
//  Created by Shih Chi Wei on 2022/4/24.
//

import Foundation

struct BalanceDecoder: Decodable {
    var jsonrpc: String
    var id: Int
    var result: String
}
