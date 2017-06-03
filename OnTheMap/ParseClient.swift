//
//  ParseClient.swift
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

class ParseClient: HTTPClient {
    
    // MARK: Shared Instance
    
    class var shared: ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        
        return Singleton.sharedInstance
    }
    
    // MARK: Properties
    
    var pastStudentLocationObjectId: String?
    
    /**
     Fetch student locations with specified parameters returning them in a Promise
     
     - Parameter limit: limit on the number of items in result
     - Parameter skip: skips the first specified amount of items in result
     - Parameter order: a string that specifies the order of the result (i.e. "updatedAt")
     */
    func getStudentLocations(withLimit limit: Int = ParseConstants.DefaultLocationsLimit, skip: Int = ParseConstants.DefaultLocationsSkip, order: String = ParseConstants.DefaultOrder) -> Promise<[StudentLocation]> {
        
        var parameters = [String:AnyObject]()
        parameters[ParseConstants.LimitParameter] = limit as AnyObject
        parameters[ParseConstants.SkipParamenter] = skip as AnyObject
        parameters[ParseConstants.OrderParameter] = order as AnyObject
        
        let method = ParseConstants.StudentLocation
        
        return taskForGETMethod(method: method, parameters: parameters).then { result -> Promise<[StudentLocation]> in
            return Promise { fulfill, reject in
                let json = JSON(data: result)
                guard json.error == nil else {
                    reject(NSError(domain: AppConstants.AppName, code: 0, userInfo: [NSLocalizedDescriptionKey:ErrorMessages.StudentsLocationError]))
                    return
                }
                fulfill(StudentLocation.studentLocationsFromResults(results: json[ParseConstants.Results]))
            }
        }
        
    }
    
    /**
     Tries to get past studentLocation of an user with a specified userProfileID. The objectID stored from this call
     can be used to update information on the server instead of posting a new one.
     */
    func queryForStudentWithUserProfileID(userProfileID: String) -> Promise<Bool> {
        
        //we already have the objectId for the currently logged student
        if pastStudentLocationObjectId != nil {
            return Promise(value: true)
        }
    
        var parameters = [String:AnyObject]()
        let placemarkRange = ParseConstants.QueryForStudentLocationWithUdacityUserProfileID.range(of: ParseConstants.Placemark)
        var parameterValue = ParseConstants.QueryForStudentLocationWithUdacityUserProfileID
        parameterValue.replaceSubrange(placemarkRange!, with: userProfileID)
        
        parameters[ParseConstants.Where] = parameterValue as AnyObject?
        let method = ParseConstants.StudentLocation
    
        return taskForGETMethod(method: method, parameters: parameters).then { result -> Promise<Bool> in
            return Promise { fulfill, reject in
                let json = JSON(data: result)
                guard json.error == nil else {
                    reject(NSError(domain: AppConstants.AppName, code: 0, userInfo: [NSLocalizedDescriptionKey:ErrorMessages.CannotRetreiveObjectIdForStudent]))
                    return
                }
                
                guard let objectId = json[ParseConstants.Results].array?.first?.dictionary?[ParseConstants.ObjectID]?.string else {
                    reject(NSError(domain: AppConstants.AppName, code: 0, userInfo: [NSLocalizedDescriptionKey:ErrorMessages.CannotRetreiveObjectIdForStudent]))
                    return
                }
                
                self.pastStudentLocationObjectId = objectId
                fulfill(true)
            }
        }
    }
    
    func updateStudentLocation(userProfileId: String,
                               firstName: String,
                               lastName: String,
                               location: String,
                               url: String,
                               latitude: Float,
                               longitude: Float) -> Promise<Bool> {
        
        let parameters = [String:AnyObject]()
        let jsonBody: [String:Any] = [
            ParseConstants.UniqueKey: "\(userProfileId)",
            ParseConstants.FirstName: "\(firstName)",
            ParseConstants.LastName: "\(lastName)",
            ParseConstants.MapString: "\(location)",
            ParseConstants.MediaURL: "\(url)",
            ParseConstants.Latitude: latitude,
            ParseConstants.Longitude: longitude
        ]
        var method = ParseConstants.StudentLocation
        if pastStudentLocationObjectId != nil {
            method = method + HTTPConstants.Slash + pastStudentLocationObjectId!
        }
        
        return taskForPUTMethod(method: method, parameters: parameters, jsonBody: jsonBody as [String : AnyObject]).then { result -> Promise<Bool> in
            return Promise { fulfill, reject in
                fulfill(true)
            }.catch { error in
                debugPrint(error.localizedDescription)
            }
        }
        
    }
    
    // MARK: Utility
    
    func deleteCurrentSession() {
        pastStudentLocationObjectId = nil
    }
    
    override func headersForGETRequest() -> [String:String] {
        var headers = super.headersForGETRequest()
        headers[ParseConstants.XParseApplicationID] = ParseConstants.ApplicationID
        headers[ParseConstants.XParseRESTAPIKey] = ParseConstants.RESTAPIKey
        return headers
    }
    
    override func headersForPUTRequest() -> [String:String] {
        var headers = super.headersForPUTRequest()
        headers[ParseConstants.XParseApplicationID] = ParseConstants.ApplicationID
        headers[ParseConstants.XParseRESTAPIKey] = ParseConstants.RESTAPIKey
        headers[HTTPConstants.ContentType] = HTTPConstants.ApplicationJSON
        return headers
    }
    
    override func getURLComponents(withPathExtension pathExtension: String? = nil) -> URLComponents {
        var components = super.getURLComponents(withPathExtension: pathExtension)
        components.host = ParseConstants.APIHost
        components.path = ParseConstants.APIPath + (pathExtension ?? "")
        return components
    }
    
}
