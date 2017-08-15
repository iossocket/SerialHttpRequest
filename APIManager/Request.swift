//
//  Request.swift
//  SerialHttpRequest
//
//  Created by Xueliang Zhu on 6/23/16.
//  Copyright © 2016 kotlinchina. All rights reserved.
//

import UIKit

enum Method: String {
    case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
}

func request(_ url: String, method: Method, parameters: [String: Any]? = nil,
             encoding: ParameterEncoding = .url, headers: [String: String]? = nil) -> URLRequest? {
    let request = requestWithHeader(url, method: method, headers: headers)
    guard let _request = request else { return nil }
    let encodedRequest = encoding.encode(_request, parameters: parameters)
    return encodedRequest
}

func requestWithHeader(_ url: String, method: Method, headers: [String: String]? = nil) -> URLRequest? {
    guard let url = URL(string: url) else {
        return nil
    }
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    
    if let headers = headers {
        for (headerField, headerValue) in headers {
            request.setValue(headerValue, forHTTPHeaderField: headerField)
        }
    }
    
    return request
}
