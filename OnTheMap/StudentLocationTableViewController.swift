//
//  StudentLocationTableViewController.swift
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

class StudentLocationTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: Properties
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }

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
    
    // MARK: Notifications
    
    @objc private func studentLocationsWillUpdate() {
        spinner.startAnimating()
    }
    
    @objc private func studentLocationsDidUpdate() {
        spinner.stopAnimating()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentLocationData.shared.studentLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.OTMCellIdentifier, for: indexPath)
        
        let studentLocation = StudentLocationData.shared.studentLocations[indexPath.row]
        var name = studentLocation.firstName ?? ""
        if let lastName = studentLocation.lastName {
            if name == "" {
                name = lastName
            } else {
                name += " " + lastName
            }
        }
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = studentLocation.mediaURL ?? studentLocation.mapString
        cell.imageView?.image = UIImage(named: Assets.PinImage)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let urlString = tableView.cellForRow(at: indexPath)?.detailTextLabel?.text {
            if let url = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(url) {
                    let vc = SFSafariViewController(url: url)
                    present(vc, animated: true, completion: nil)
                }
            }
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


