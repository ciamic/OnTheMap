//
//  Constants.swift
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

// MARK: App Constants

struct AppConstants {
    static let AppName = "OnTheMap"
}

// MARK: Assets 

struct Assets {
    static let PinImage = "Pin_Nav"
}

// MARK: HTTP Constants

struct HTTPConstants {
    static let ApplicationJSON = "application/json"
    static let ContentType = "Content-Type"
    static let POST = "POST"
    static let GET = "GET"
    static let PUT = "PUT"
    static let DELETE = "DELETE"
    static let Accept = "Accept"
    static let APIScheme = "https"
    static let Slash = "/"
    static let UnauthorizedStatusCode = 403
}

// MARK: Notifications

struct Notifications {
    static let StudentLocationUpdateSuccess = "StudentLocationUpdateSuccess"
    static let StudentLocationUpdateFail = "StudentLocationUpdateFail"
    static let StudentLocationWillUpdateData = "StudentLocationWillUpdateData"
}

// MARK: Storyboard Constants

struct Storyboard {
    static let OnTheMapTabBarViewControllerSegue = "OnTheMapTabBarViewControllerSegue"
    static let StudentLocationAnnotationIdentifier = "StudentLocationAnnotation"
    static let OTMCellIdentifier = "OTMCellIdentifier"
    static let StudentLocationPostingInformationViewController = "StudentLocationPostingInformationViewController"
}

// MARK: Error Messages

struct ErrorMessages {
    static let LoginError = "Login Error"
    static let EmptyEmailOrPassword = "Empty Email or Password."
    static let Ok = "Ok"
    static let TryAgain = "Try Again"
    static let UserDataInfoError = "Could not retreive user info."
    static let SessionInfoError = "Could not retreive session info."
    static let ErrorOccurred = "An error has occurred. Please try again."
    static let StudentsLocationError = "Could not retreive students location. Please try again."
    static let CouldNotFindTheLocationOnMap = "Could not find location on map. Please try another location."
    static let CannotRetreiveObjectIdForStudent = "Past objectId for student could not be retreived."
    static let InsertValidLocation = "Insert valid location."
    static let InsertValidURL = "Insert valid link (include http:// or https://)."
    static let InvalidEmailOrPassword = "Invalid username or password."
}

// MARK: Udacity Constants

struct UdacityConstants {
    //static let UdacityFacebookAppID = "365362206864879"
    static let APISession = "/api/session"
    static let Udacity = "udacity"
    static let Username = "username"
    static let Password = "password"
    static let NSecurityChars = 5
    static let APIUsers = "/api/users/"
    static let Me = "me"
    static let APIHost = "www.udacity.com"
    static let APIPath = ""
    static let UdacitySignUpPage = "https://www.udacity.com/account/auth#!/signup"
    static let Session = "session"
    static let ID = "id"
    static let User = "user"
    static let LastName = "last_name"
    static let FirstName = "first_name"
    static let Key = "key"
}

// MARK: ParseConstants

struct ParseConstants {
    static let Results = "results"
    static let ApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static let RESTAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    static let LimitParameter = "limit"
    static let SkipParamenter = "skip"
    static let OrderParameter = "order"
    static let DefaultOrder = "-updatedAt"
    static let APIHost = "parse.udacity.com"
    static let APIPath = "/parse/classes/"
    static let StudentLocation = "StudentLocation"
    static let XParseApplicationID = "X-Parse-Application-Id"
    static let XParseRESTAPIKey = "X-Parse-REST-API-Key"
    static let UniqueKey = "uniqueKey"
    static let FirstName = "firstName"
    static let LastName = "lastName"
    static let MapString = "mapString"
    static let MediaURL = "mediaURL"
    static let Latitude = "latitude"
    static let Longitude = "longitude"
    static let ObjectID = "objectId"
    static let DefaultLocationsLimit = 100
    static let DefaultLocationsSkip = 0
    static let Placemark = "{_}"
    static let QueryForStudentLocationWithUdacityUserProfileID = "{\"uniqueKey\":\"" + Placemark + "\"}"
    static let Where = "where"
}

// MARK: Cookies

struct Cookies {
    static let XsrfTokenName = "XSRF-TOKEN"
    static let XsrfTokenHeaderName = "X-XSRF-TOKEN"
}
