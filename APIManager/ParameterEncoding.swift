//
//  ParameterEncoding.swift
//  SerialHttpRequest
//
//  Created by Xueliang Zhu on 6/23/16.
//  Copyright © 2016 kotlinchina. All rights reserved.
//

import UIKit

enum ParameterEncoding {
    case url
    case urlEncodedInURL
    case json
    
    func encode(_ request: URLRequest, parameters: [String: Any]?) -> URLRequest? {
        
        guard let parameters = parameters else { return request }
        var request = request
        
        switch self {
        case .url, .urlEncodedInURL:
            func query(_ parameters: [String: Any]) -> String {
                var components: [(String, String)] = []
                
                for key in parameters.keys.sorted(by: <) {
                    components += queryComponents(key, parameters[key]!)
                }
                
                return (components.map{ "\($0)=\($1)" } as [String]).joined(separator: "&")
            }
            
            func encodesParametersInURL(_ method: Method) -> Bool {
                switch self {
                case .urlEncodedInURL:
                    return true
                default:
                    break
                }
                
                switch method {
                case .GET, .HEAD, .DELETE:
                    return true
                default:
                    return false
                }
            }
            if let method = Method(rawValue: request.httpMethod!), encodesParametersInURL(method) {
                if var components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false), !parameters.isEmpty {
                    let percentEncodedQuery = (components.percentEncodedQuery.map { $0 + "&" } ?? "") + query(parameters)
                    components.percentEncodedQuery = percentEncodedQuery
                    request.url = components.url
                }
            } else {
                if request.value(forHTTPHeaderField: "Content-Type") == nil {
                    request.setValue(
                        "application/x-www-form-urlencoded; charset=utf-8",
                        forHTTPHeaderField: "Content-Type"
                    )
                }
                
                request.httpBody = query(parameters).data(using: String.Encoding.utf8, allowLossyConversion: false)
            }
            
        case .json:
            do {
                let options = JSONSerialization.WritingOptions()
                let data = try JSONSerialization.data(withJSONObject: parameters, options: options)
                
                if request.value(forHTTPHeaderField: "Content-Type") == nil {
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
                
                request.httpBody = data
            } catch {
                return nil
            }
        }
        
        return request
    }
    
    func queryComponents(_ key: String, _ value: Any) -> [(String, String)] {
        var components: [(String, String)] = []
        
        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents("\(key)[\(nestedKey)]", value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents("\(key)[]", value)
            }
        } else {
            components.append((escape(key), escape("\(value)")))
        }
        
        return components
    }
    
    func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="
        
        let allowedCharacterSet = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
        allowedCharacterSet.removeCharacters(in: generalDelimitersToEncode + subDelimitersToEncode)
        
        var escaped = ""
        escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet as CharacterSet) ?? string
        
        return escaped
    }
}
