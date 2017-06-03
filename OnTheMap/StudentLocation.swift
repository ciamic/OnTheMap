//
//  StudentLocation.swift
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

import Foundation
import MapKit
import SwiftyJSON

class StudentLocation: NSObject {
    
    // MARK: Properties
    
    let objectID: String
    let uniqueKey: String?
    let firstName: String?
    let lastName: String?
    let mapString: String?
    let mediaURL: String?
    let latitude: Double
    let longitude: Double
    
    // MARK: Initializers
    
    init?(dictionary: JSON) {
        
        //at least objectID, latitude and longitude are necessary
        guard let objectID = dictionary[ParseConstants.ObjectID].string,
            let latitude = dictionary[ParseConstants.Latitude].double,
            let longitude = dictionary[ParseConstants.Longitude].double else {
            return nil
        }
        self.objectID = objectID
        self.latitude = latitude
        self.longitude = longitude
        self.uniqueKey = dictionary[ParseConstants.UniqueKey].string ?? nil
        self.firstName = dictionary[ParseConstants.FirstName].string ?? nil
        self.lastName = dictionary[ParseConstants.LastName].string ?? nil
        self.mapString = dictionary[ParseConstants.MapString].string ?? nil
        self.mediaURL = dictionary[ParseConstants.MediaURL].string ?? nil
    }
    
    class func studentLocationsFromResults(results: JSON) -> [StudentLocation] {
        var studentLocations = [StudentLocation]()
        for result in results {
            if let studentLocation = StudentLocation(dictionary: result.1) {
                studentLocations.append(studentLocation)
            }
        }
        return studentLocations
    }
    
}

// MARK: StudentAnnotation

extension StudentLocation: MKAnnotation {
    
    var title: String? {
        var title = ""
        if let firstName = firstName {
            title = firstName
        }
        if let lastName = lastName {
            if title.characters.count > 0 {
                title = title + " " + lastName
            } else {
                title = lastName
            }
        }
        return title
    }
    var coordinate: CLLocationCoordinate2D { return CLLocationCoordinate2DMake(latitude, longitude) }
    var subtitle: String? { return mediaURL }

}

// MARK: StudentLocation: Equatable

extension StudentLocation {
    
    static func == (lhs: StudentLocation, rhs: StudentLocation) -> Bool {
        return lhs.objectID == rhs.objectID
    }
    
}
