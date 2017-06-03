//
//  StudentLocationMapViewController.swift
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
import SafariServices

class StudentLocationMapViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        subscribeForNotifications()
        fetchStudents()
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
        NotificationCenter.default.addObserver(self, selector: #selector(studentLocationsDidUpdate), name: NSNotification.Name(rawValue: Notifications.StudentLocationUpdateFail), object: nil)
    }
    
    private func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.StudentLocationUpdateFail), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.StudentLocationUpdateSuccess), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.StudentLocationWillUpdateData), object: nil)
    }
    
    @objc private func studentLocationsWillUpdate() {
        spinner.startAnimating()
        mapView.removeAnnotations(mapView.annotations)
    }
    
    @objc private func studentLocationsDidUpdate() {
        spinner.stopAnimating()
        for student in StudentLocationData.shared.studentLocations {
            mapView.addAnnotation(student)
        }
    }
    
    // MARK: Utility
    
    private func fetchStudents() {
        StudentLocationData.shared.refreshStudentLocations()
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

// MARK: MapViewDelegate

extension StudentLocationMapViewController: MKMapViewDelegate {
    
    private func URLFromAnnotation(annotation: MKAnnotation) -> URL? {
        if let studentLocation = annotation as? StudentLocation {
            if let urlString = studentLocation.subtitle {
                if let url = URL(string: urlString) {
                    if UIApplication.shared.canOpenURL(url) {
                        return url
                    }
                }
            }
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = Storyboard.StudentLocationAnnotationIdentifier
        if annotation.isKind(of: StudentLocation.self) {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
                annotationView!.canShowCallout = true
                
                if URLFromAnnotation(annotation: annotation) != nil {
                    annotationView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                } else {
                    annotationView!.rightCalloutAccessoryView = nil
                }
            
            } else {
                annotationView!.annotation = annotation
            }
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation {
            if let url = URLFromAnnotation(annotation: annotation) {
                let vc = SFSafariViewController(url: url)
                present(vc, animated: true, completion: nil)
            }
        }
    }
    
}
