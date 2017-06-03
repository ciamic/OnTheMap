//
//  StudentLocationPostingInformationViewController.swift
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
import MapKit

class StudentLocationPostingInformationViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Properties
    
    fileprivate var annotation: MKPointAnnotation?
    fileprivate var naturalQueryLanguageForLocation: String?
    fileprivate var initialRegion: MKCoordinateRegion!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        linkTextField.delegate = self
        locationTextField.delegate = self
        initialRegion = mapView.region
    }
    
    // MARK: Actions
    
    @IBAction func cancelButtonTapped() {
        if let presentingViewController = presentingViewController {
            presentingViewController.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func submitButtonTapped() {
        guard annotation != nil else {
            let alert = UIAlertController(title: ErrorMessages.TryAgain, message: ErrorMessages.InsertValidLocation, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: ErrorMessages.Ok, style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard let stringUrl = linkTextField.text,
            let url = URL(string: stringUrl),
            UIApplication.shared.canOpenURL(url) else {
                let alert = UIAlertController(title: ErrorMessages.TryAgain, message: ErrorMessages.InsertValidURL, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: ErrorMessages.Ok, style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                return
        }
        
        guard let userProfileId = UdacityClient.shared.userProfileID else {
            let alert = UIAlertController(title: ErrorMessages.TryAgain, message: ErrorMessages.ErrorOccurred, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: ErrorMessages.Ok, style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        let firstName = UdacityClient.shared.firstName ?? ""
        let lastName = UdacityClient.shared.lastName ?? ""
        let location = naturalQueryLanguageForLocation ?? ""
        let latitude = Float(annotation!.coordinate.latitude)
        let longitude = Float(annotation!.coordinate.longitude)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        spinner.startAnimating()
        view.isUserInteractionEnabled = false
        ParseClient.shared.updateStudentLocation(userProfileId: userProfileId,
                                                 firstName: firstName,
                                                 lastName: lastName,
                                                 location: location,
                                                 url: stringUrl,
                                                 latitude: latitude,
                                                 longitude: longitude).then { _ -> Void in
                
            StudentLocationData.shared.refreshStudentLocations()
                
            if self.presentingViewController != nil {
                self.presentingViewController!.dismiss(animated: true, completion: nil)
            }
        }.always {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.spinner.stopAnimating()
            self.view.isUserInteractionEnabled = true
        }.catch { error in
            debugPrint(error.localizedDescription)
            let alert = UIAlertController(title: ErrorMessages.TryAgain, message: ErrorMessages.ErrorOccurred, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: ErrorMessages.Ok, style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    // MARK: Utility
    
    fileprivate func findLocation() {
        mapView.removeAnnotations(mapView.annotations)
        if let location = locationTextField.text, location.characters.count > 0 {
            let request = MKLocalSearchRequest()
            request.naturalLanguageQuery = location
            let search = MKLocalSearch(request: request)
            
            spinner.startAnimating()
            search.start { response, error in
                DispatchQueue.main.async { [weak self] in
                    if let strongSelf = self {
                        strongSelf.spinner.stopAnimating()
                        if let response = response {
                            if response.mapItems.isEmpty {
                                let alert = UIAlertController(title: ErrorMessages.TryAgain, message: ErrorMessages.CouldNotFindTheLocationOnMap, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: ErrorMessages.Ok, style: .default, handler: nil))
                                strongSelf.present(alert, animated: true, completion: nil)
                            } else {
                                let item = response.mapItems.first!
                                strongSelf.annotation = MKPointAnnotation()
                                strongSelf.annotation!.coordinate = item.placemark.coordinate
                                strongSelf.annotation!.title = item.name
                                strongSelf.naturalQueryLanguageForLocation = request.naturalLanguageQuery
                                strongSelf.mapView.addAnnotation(strongSelf.annotation!)
                                strongSelf.mapView.showAnnotations(strongSelf.mapView.annotations, animated: true)
                            }
                        } else if let error = error {
                            let alert = UIAlertController(title: ErrorMessages.TryAgain, message: ErrorMessages.CouldNotFindTheLocationOnMap, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: ErrorMessages.Ok, style: .default, handler: nil))
                            strongSelf.present(alert, animated: true, completion: nil)
                            debugPrint(error.localizedDescription)
                        }
                    }
                }
            }
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

extension StudentLocationPostingInformationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == locationTextField {
            mapView.setRegion(initialRegion, animated: true)
            findLocation()
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //if textField == locationTextField {
        //    mapView.setRegion(initialRegion, animated: true)
        //}
    }
    
}
