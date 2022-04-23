//
//  APIService.swift
//  TPEPolice
//
//  Created by Arrny.Wei on 2022/1/21.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

public enum HTTPRequestError: Error {
    case invalidResponse(URLResponse)
    case invalidJSON(Error)
    case timeOut
}

class APIService: NSObject, URLSessionDelegate {
    enum ServiceMode {
        case assetList
        case balance
    }

    static let shared: APIService = APIService()
    let host = "https://api.opensea.io/api/v1"
    let testHost = "https://testnets-api.opensea.io/api/v1"
    var disposeBag = DisposeBag()


    
    func request<decoder: Decodable>(service: ServiceMode, path: String, body: [String: Any]? = nil, dataModel: decoder.Type) -> Observable<Result<decoder, Error>> {
        switch service {
        case .assetList:
            return get(url: getURL(path), as: decoder.self)
        case .balance:
            return getBalance(url: path, as: decoder.self, body: body)
        }

    }

    private func getURL(_ string: String) -> String {
        return "\(host)\(string)"
    }

    
    private func get<decoder: Decodable>(url: String, as: decoder.Type) -> Observable<Result<decoder, Error>> {

        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.addValue("5b294e9193d240e39eefc5e6e551ce83", forHTTPHeaderField: "X-API-KEY")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        return doTask(request: request)
    }

    func getBalance<decoder: Decodable>(url: String, as: decoder.Type, body: [String: Any]? = nil) -> Observable<Result<decoder, Error>>  {



        var request = URLRequest(url: URL(string: "https://mainnet.infura.io/v3/755b3352f9a347eb8c25113eb5cd3908")!)
        if let body = body {
            let jsonData = try? JSONSerialization.data(withJSONObject: body)
            request.httpBody = jsonData
        }
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        return doTask(request: request)
    }

    func doTask<decoder: Decodable>(request: URLRequest) -> Observable<Result<decoder, Error>> {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 60.0
        let session = URLSession(configuration: sessionConfig)

        return session.rx.response(request: request)
            .map { result -> Data in
                guard result.response.statusCode == 200 else {
                    throw HTTPRequestError.invalidResponse(result.response)
                }
                return result.data
            }.map { data in
                do {
                    return .success(try JSONDecoder().decode(decoder.self, from: data))
                } catch let error {
                    return .failure(HTTPRequestError.invalidJSON(error))
                }
            }
            .asObservable()
    }
}
