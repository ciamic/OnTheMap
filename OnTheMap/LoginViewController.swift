//
//  LoginViewController.swift
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
import SafariServices
import PromiseKit

class LoginViewController: UIViewController {
    
    fileprivate weak var activeTextField: UITextField?
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterFromKeyboardNotifications()
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(LoginViewController.keyboardWillShow),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(LoginViewController.keyboardWillHide),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
        
    }
    
    func unregisterFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIKeyboardWillShow,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIKeyboardWillHide,
                                                  object: nil)
    
    }
    
    func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size,
            let activeTextField = activeTextField else {
                return
        }
        scrollView.isScrollEnabled = true
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        var rect = view.frame
        rect.size.height -= keyboardSize.height
        if rect.contains(activeTextField.frame.origin) {
            scrollView.scrollRectToVisible(activeTextField.frame, animated: true)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size else {
                return
        }
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize.height, 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        view.endEditing(true)
        scrollView.isScrollEnabled = false
    }
    
    // MARK: Actions
    
    @IBAction func loginButtonTapped() {
        guard !emailTextField.text!.isEmpty && !passwordTextField.text!.isEmpty else {
            let alert = UIAlertController(title: ErrorMessages.LoginError,
                                          message: ErrorMessages.EmptyEmailOrPassword,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: ErrorMessages.Ok, style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        spinner.startAnimating()
        view.isUserInteractionEnabled = false
        firstly { Void -> Promise<Bool> in
            return UdacityClient.shared.authenticate(username: emailTextField.text!, password: passwordTextField.text!)
        }.then { success -> Void in
            if success {
                self.performSegue(withIdentifier: Storyboard.OnTheMapTabBarViewControllerSegue, sender: self)
            }
        }.always {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.spinner.stopAnimating()
            self.view.isUserInteractionEnabled = true
        }.catch { error in
            debugPrint(error.localizedDescription)
            let alert = UIAlertController(title: ErrorMessages.TryAgain,
                                          message: error.localizedDescription,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: ErrorMessages.Ok, style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func signUpButtonTapped() {
        if let url = URL(string: UdacityConstants.UdacitySignUpPage) {
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true, completion: nil)
        }
    }

}

// MARK: UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
