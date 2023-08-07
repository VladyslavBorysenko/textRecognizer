//
//  AnyError.swift
//  TextRecognizer
//
//  Created by Vlad Borisenko on 8/7/23.
//

import Foundation

struct AnyError: Error {

    let error: Error

    init(_ error: Error) {
        self.error = error
    }
}
