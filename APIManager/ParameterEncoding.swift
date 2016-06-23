//
//  ParameterEncoding.swift
//  SerialHttpRequest
//
//  Created by Xueliang Zhu on 6/23/16.
//  Copyright © 2016 kotlinchina. All rights reserved.
//

import UIKit

enum ParameterEncoding {
    case URL
    case URLEncodedInURL
    case JSON
    
    func encode(request: NSMutableURLRequest, parameters: [String: AnyObject]?) -> NSMutableURLRequest? {
        
        guard let parameters = parameters else { return request }
        
        switch self {
        case .URL, .URLEncodedInURL:
            func query(parameters: [String: AnyObject]) -> String {
                var components: [(String, String)] = []
                
                for key in parameters.keys.sort(<) {
                    components += queryComponents(key, parameters[key]!)
                }
                
                return (components.map{ "\($0)=\($1)" } as [String]).joinWithSeparator("&")
            }
            
            func encodesParametersInURL(method: Method) -> Bool {
                switch self {
                case .URLEncodedInURL:
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
            if let method = Method(rawValue: request.HTTPMethod) where encodesParametersInURL(method) {
                if let components = NSURLComponents(URL: request.URL!, resolvingAgainstBaseURL: false) where !parameters.isEmpty {
                    let percentEncodedQuery = (components.percentEncodedQuery.map { $0 + "&" } ?? "") + query(parameters)
                    components.percentEncodedQuery = percentEncodedQuery
                    request.URL = components.URL
                }
            } else {
                if request.valueForHTTPHeaderField("Content-Type") == nil {
                    request.setValue(
                        "application/x-www-form-urlencoded; charset=utf-8",
                        forHTTPHeaderField: "Content-Type"
                    )
                }
                
                request.HTTPBody = query(parameters).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            }
            
        case .JSON:
            do {
                let options = NSJSONWritingOptions()
                let data = try NSJSONSerialization.dataWithJSONObject(parameters, options: options)
                
                if request.valueForHTTPHeaderField("Content-Type") == nil {
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
                
                request.HTTPBody = data
            } catch {
                return nil
            }
        }
        
        return request
    }
    
    func queryComponents(key: String, _ value: AnyObject) -> [(String, String)] {
        var components: [(String, String)] = []
        
        if let dictionary = value as? [String: AnyObject] {
            for (nestedKey, value) in dictionary {
                components += queryComponents("\(key)[\(nestedKey)]", value)
            }
        } else if let array = value as? [AnyObject] {
            for value in array {
                components += queryComponents("\(key)[]", value)
            }
        } else {
            components.append((escape(key), escape("\(value)")))
        }
        
        return components
    }
    
    func escape(string: String) -> String {
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="
        
        let allowedCharacterSet = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet
        allowedCharacterSet.removeCharactersInString(generalDelimitersToEncode + subDelimitersToEncode)
        
        var escaped = ""
        escaped = string.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacterSet) ?? string
        
        return escaped
    }
}
