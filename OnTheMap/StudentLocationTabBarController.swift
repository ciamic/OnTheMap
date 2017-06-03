//
//  StudentLocationTabBarController.swift
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

import UIKit

class StudentLocationTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeForNotifications()
    }
    
    deinit {
        unsubscribeFromNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Notifications
    
    private func subscribeForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(studentLocationsWillUpdate), name: NSNotification.Name(rawValue: Notifications.StudentLocationWillUpdateData), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(studentLocationsDidUpdate), name: NSNotification.Name(rawValue: Notifications.StudentLocationUpdateSuccess), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showErrorAlert), name: NSNotification.Name(rawValue: Notifications.StudentLocationUpdateFail), object: nil)
    }
    
    private func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.StudentLocationUpdateFail), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.StudentLocationUpdateSuccess), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.StudentLocationWillUpdateData), object: nil)
    }
    
    @objc private func studentLocationsWillUpdate() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    @objc private func studentLocationsDidUpdate() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    @objc private func showErrorAlert() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        let alert = UIAlertController(title: ErrorMessages.TryAgain,
                                      message: ErrorMessages.ErrorOccurred,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: ErrorMessages.Ok, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Actions
    
    @IBAction func logoutButtonTapped(_ sender: UIBarButtonItem) {
        UdacityClient.shared.deleteCurrentSession()
        let vc = storyboard!.instantiateInitialViewController()!
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func refreshButtonTapped(_ sender: UIBarButtonItem) {
        StudentLocationData.shared.refreshStudentLocations()
    }
    
    @IBAction func postLocationButtonTapped(_ sender: UIBarButtonItem) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        ParseClient.shared.queryForStudentWithUserProfileID(userProfileID: UdacityClient.shared.userProfileID!).then { _ -> Void in
            let postingVC = self.storyboard!.instantiateViewController(withIdentifier: Storyboard.StudentLocationPostingInformationViewController)
            self.present(postingVC, animated: true, completion: nil)
        }.always {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }.catch { error in
            debugPrint(error.localizedDescription)
            self.showErrorAlert()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
