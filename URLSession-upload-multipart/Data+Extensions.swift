//
//  Data+Extensions.swift
//  URLSession-upload-multipart
//
//  Created by YouTube on 2022-10-23.
//

import Foundation

extension Data {
    
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
