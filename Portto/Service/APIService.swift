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


    static let shared: APIService = APIService()
    let host = "https://api.opensea.io/api/v1"
    let testHost = "https://testnets-api.opensea.io/api/v1"
    var disposeBag = DisposeBag()
    
    func request<decoder: Decodable>(path: String, body: [String: Any]? = nil, dataModel: decoder.Type) -> Observable<Result<decoder, Error>> {
        get(url: getURL(path), as: decoder.self)
    }

    private func getURL(_ string: String) -> String {
        return "\(testHost)\(string)"
    }

    
    private func get<decoder: Decodable>(url: String, as: decoder.Type) -> Observable<Result<decoder, Error>> {

        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")

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
