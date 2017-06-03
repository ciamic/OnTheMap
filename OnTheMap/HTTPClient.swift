//
//  HTTPClient.swift
//
//  Copyright (c) 2017 michelangelo
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import Alamofire
import PromiseKit

class HTTPClient: NSObject {
    
    // MARK: GET
    
    func taskForGETMethod(method: String, parameters: [String:AnyObject]) -> Promise<Data> {
        
        let url = URLFromParameters(parameters: parameters, withPathExtension: method)
        let request = Alamofire.request(url, headers: headersForGETRequest())
        
        return Promise { fulfill, reject in
            request.validate().responseData { response in
                switch response.result {
                case .success(let data):
                    fulfill(self.elaborate(data: data))
                case .failure(let error):
                    reject(error)
                }
            }
        }
        
    }
    
    // MARK: POST
    
    func taskForPOSTMethod(method: String, parameters: [String:AnyObject], jsonBody: [String:AnyObject]) -> Promise<Data> {
        
        let url = URLFromParameters(parameters: parameters, withPathExtension: method)
        let request = Alamofire.request(url,
                                        method: .post,
                                        parameters: jsonBody,
                                        encoding: JSONEncoding.default,
                                        headers: headersForPOSTRequest())
        
        return Promise { fulfill, reject in
            request.validate().responseData { response in
                switch response.result {
                case .success(let data):
                    fulfill(self.elaborate(data: data))
                case .failure(let error):
                   reject(error)
                }
            }
        }
        
    }
    
    // MARK: DELETE
    
    func taskForDELETEMethod(method: String, parameters: [String:AnyObject]) -> Promise<Data> {
        
        let url = URLFromParameters(parameters: parameters, withPathExtension: method)
        let request = Alamofire.request(url,
                                        method: .delete,
                                        headers: headersForDELETERequest())
        
        return Promise { fulfill, reject in
            request.validate().responseData { response in
                switch response.result {
                case .success(let data):
                    fulfill(self.elaborate(data: data))
                case .failure(let error):
                    reject(error)
                }
            }
        }
        
    }
    
    // MARK: PUT
    
    func taskForPUTMethod(method: String, parameters: [String:AnyObject], jsonBody: [String:AnyObject]) -> Promise<Data> {
        
        let url = URLFromParameters(parameters: parameters, withPathExtension: method)
        let request = Alamofire.request(url,
                                        method: .put,
                                        parameters: jsonBody,
                                        encoding: JSONEncoding.default,
                                        headers: headersForPUTRequest())
        
        return Promise { fulfill, reject in
            request.validate().responseData { response in
                switch response.result {
                case .success(let data):
                    fulfill(self.elaborate(data: data))
                case .failure(let error):
                    reject(error)
                }
            }
        }
        
    }
    
    // MARK: Utility
    
    //do nothing for this class
    func headersForPUTRequest() -> [String:String] {
        return [:]
    }
    
    //do nothing for this class
    func headersForGETRequest() -> [String:String] {
        return [:]
    }
    
    //do nothing for this class
    func headersForPOSTRequest() -> [String:String] {
        return [:]
    }
    
    //do nothing for this class
    func headersForDELETERequest() -> [String:String] {
        return [:]
    }
    
    private func URLFromParameters(parameters: [String:AnyObject], withPathExtension pathExtension : String? = nil) -> URL {
        
        var components = getURLComponents(withPathExtension: pathExtension)
        
        if parameters.isEmpty {
            return try! components.asURL()
        }
        
        components.queryItems = [URLQueryItem]()
        
        for(key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return try! components.asURL()
        
    }
    
    func getURLComponents(withPathExtension pathExtension: String? = nil) -> URLComponents {
        var components = URLComponents()
        components.scheme = HTTPConstants.APIScheme
        return components
    }
    
    //no elaboration for this class
    func elaborate(data: Data) -> Data {
        return data
    }
    
    // MARK: Cookies
    
    func cookie(withName name: String) -> HTTPCookie? {
        let sharedCookieStorage = HTTPCookieStorage.shared
        guard let cookies = sharedCookieStorage.cookies else {
            return nil
        }
        for cookie in cookies {
            if cookie.name == name {
                return cookie
            }
        }
        return nil
    }
    
}
