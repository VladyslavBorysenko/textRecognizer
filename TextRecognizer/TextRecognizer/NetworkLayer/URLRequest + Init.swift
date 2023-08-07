//
//  URLRequest + Init.swift
//  TextRecognizer
//
//  Created by Vlad Borisenko on 8/7/23.
//

import Foundation

extension URLRequest {

    init(url: URL, method: String, headers: HTTPHeaders?) {
        self.init(url: url)
        httpMethod = method

        if let headers = headers {
            headers.forEach {
                setValue($0.1, forHTTPHeaderField: $0.0)
            }
        }
    }
}
