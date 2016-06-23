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

func request(url: String, method: Method, parameters: [String: AnyObject]? = nil,
             encoding: ParameterEncoding = .URL, headers: [String: String]? = nil) -> NSMutableURLRequest? {
    let request = requestWithHeader(url, method: method, headers: headers)
    guard let _request = request else { return nil }
    let encodedRequest = encoding.encode(_request, parameters: parameters)
    return encodedRequest
}

func requestWithHeader(url: String, method: Method, headers: [String: String]? = nil) -> NSMutableURLRequest? {
    guard let url = NSURL(string: url) else {
        return nil
    }
    let mutableRequest = NSMutableURLRequest(URL: url)
    mutableRequest.HTTPMethod = method.rawValue
    
    if let headers = headers {
        for (headerField, headerValue) in headers {
            mutableRequest.setValue(headerValue, forHTTPHeaderField: headerField)
        }
    }
    
    return mutableRequest
}
