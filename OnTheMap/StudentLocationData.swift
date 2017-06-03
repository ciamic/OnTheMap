//
//  StudentLocationData.swift
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

class StudentLocationData {
    
    // MARK: Properties
    
    var studentLocations = [StudentLocation]()
    
    // MARK: Shared Instance
    
    class var shared: StudentLocationData {
        struct Singleton {
            static var sharedInstance = StudentLocationData()
        }
        
        return Singleton.sharedInstance
    }
    
    // MARK: Notifications
    
    private func sendDataNotification(notificationName: String) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: notificationName), object: nil)
    }
    
    // MARK: Refresh Student Locations
    
    func refreshStudentLocations() {
        sendDataNotification(notificationName: Notifications.StudentLocationWillUpdateData)
        ParseClient.shared.getStudentLocations().then { newStudentLocations -> Void in
            self.studentLocations = newStudentLocations
            self.sendDataNotification(notificationName: Notifications.StudentLocationUpdateSuccess)
        }.catch { error in
            self.sendDataNotification(notificationName: Notifications.StudentLocationUpdateFail)
            debugPrint(error.localizedDescription)
        }
    }
    
}
