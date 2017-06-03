//
//  UdacityClient.swift
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
import PromiseKit
import SwiftyJSON
import Alamofire

class UdacityClient: HTTPClient {
    
    // MARK: Shared Instance
    
    class var shared: UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
    
    // MARK: auth state
    
    var sessionID: String? = nil
    var userProfileID: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    
    // MARK: Authentication
    
    /// Given username and password, tries to authenticate with Udacity API, returning a Promise with the result.
    /// If the call is successful, then class variables will contain auth informations for the user.
    func authenticate(username: String, password: String) -> Promise<Bool> {
        return Promise { fulfill, reject in
            firstly {
                getSessionID(username: username, password: password).then { sessionID -> Promise<UserDataInfo> in
                    //we have the sessionID, now we need user data info
                    self.sessionID = sessionID
                    return self.getUserData()
                }.then { userDataInfo -> Void in
                    self.userProfileID = userDataInfo.0
                    self.firstName = userDataInfo.1
                    self.lastName = userDataInfo.2
                    fulfill(true)
                }
            }.catch(execute: { error in
                //is it a wrong username and/or password?
                if let afError = error as? AFError {
                    if afError.isResponseValidationError {
                        if let errorCode = afError.responseCode {
                            if errorCode == HTTPConstants.UnauthorizedStatusCode {
                                reject(NSError(domain: AppConstants.AppName,
                                       code: 0,
                                       userInfo: [NSLocalizedDescriptionKey:ErrorMessages.InvalidEmailOrPassword]))
                                return
                            }
                        }
                    }
                }
                reject(error)
            })
        }
    }
    
    // MARK: Logout
    
    func deleteCurrentSession() {
        guard sessionID != nil else {
            return
        }
        let parameters = [String:AnyObject]()
        let _ = taskForDELETEMethod(method: UdacityConstants.APISession, parameters: parameters).always {
            self.sessionID = nil
            self.userProfileID = nil
            self.firstName = nil
            self.lastName = nil
            ParseClient.shared.deleteCurrentSession()
        }
    }
    
    // MARK: Utility
    
    private func getSessionID(username: String, password: String) -> Promise<String> {
        
        let parameters = [String:AnyObject]()
        let jsonBody: [String:Any] = [
            UdacityConstants.Udacity: [
                UdacityConstants.Username: "\(username)",
                UdacityConstants.Password: "\(password)"
            ]
        ]
        
        return taskForPOSTMethod(method: UdacityConstants.APISession, parameters: parameters, jsonBody: jsonBody as [String : AnyObject]).then { result -> Promise<String> in
            return Promise { fulfill, reject in
                let json = JSON(data: result)
                guard json.error == nil,
                    let sessionInfo = json[UdacityConstants.Session].dictionary,
                    let sessionID = sessionInfo[UdacityConstants.ID]?.string else {
                        reject(NSError(domain: AppConstants.AppName,
                                       code: 0,
                                       userInfo: [NSLocalizedDescriptionKey:ErrorMessages.SessionInfoError]))
                    return
                }

                fulfill(sessionID)
            }
        }
    }
    
    
    ///typealias for user info (profileID, firstName and lastName)
    typealias UserDataInfo = (String, String, String)

    /// Returns a promise containing the user data info associated with the user, accessible after login.
    private func getUserData() -> Promise<UserDataInfo> {
        let parameters = [String:AnyObject]()
        let method = UdacityConstants.APIUsers + UdacityConstants.Me
        return taskForGETMethod(method: method, parameters: parameters).then { result -> Promise<UserDataInfo> in
            return Promise { fulfill, reject in
                let json = JSON(data: result)
                guard json.error == nil,
                    let userData = json[UdacityConstants.User].dictionary,
                    let userProfileID = userData[UdacityConstants.Key]?.string,
                    let firstName = userData[UdacityConstants.FirstName]?.string,
                    let lastName = userData[UdacityConstants.LastName]?.string else {
                        reject(NSError(domain: AppConstants.AppName,
                                       code: 0,
                                       userInfo: [NSLocalizedDescriptionKey:ErrorMessages.UserDataInfoError]))
                        return
                }
                
                fulfill((userProfileID, firstName, lastName))
            }
        }
    }
    
    // MARK: Utility
    
    override func getURLComponents(withPathExtension pathExtension: String? = nil) -> URLComponents {
        var components = super.getURLComponents(withPathExtension: pathExtension)
        components.host = UdacityConstants.APIHost
        components.path = UdacityConstants.APIPath + (pathExtension ?? "")
        return components
    }
    
    override func headersForPOSTRequest() -> [String:String] {
        var headers = super.headersForPOSTRequest()
        headers[HTTPConstants.Accept] = HTTPConstants.ApplicationJSON
        headers[HTTPConstants.ContentType] = HTTPConstants.ApplicationJSON
        return headers
    }
    
    override func headersForDELETERequest() -> [String : String] {
        var headers = super.headersForDELETERequest()
        if let xsrfCookie = cookie(withName: Cookies.XsrfTokenName) {
            headers[Cookies.XsrfTokenHeaderName] = xsrfCookie.value
        }

        return headers
    }
    
    //subset response data for Udacity API
    //the first bytes are used for security reasons and hence discarded
    override func elaborate(data: Data) -> Data {
        let nsRange = NSMakeRange(UdacityConstants.NSecurityChars, data.count - UdacityConstants.NSecurityChars)
        if let range = nsRange.toRange() {
            return data.subdata(in: range)
        } else {
            return data
        }
    }
    
}
