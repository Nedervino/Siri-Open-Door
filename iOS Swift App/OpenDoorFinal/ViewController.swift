//
//  ViewController.swift
//  OpenDoorFinal
//
//  Created by Tim Nederveen on 21/10/15.
//  Copyright © 2015 Tim Nederveen. All rights reserved.
//
//



import UIKit
import Darwin           //needed for the exit(0) statement

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var loginStatus: UIImageView!
    @IBOutlet weak var setupStatus: UIImageView!
    @IBOutlet weak var functionStatus: UIImageView!
    
    
    
    @IBOutlet weak var loginIndicator: UIActivityIndicatorView!
    @IBOutlet weak var deviceSetupIndicator: UIActivityIndicatorView!
    @IBOutlet weak var functionCallIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    
    let textCellIdentifier = "textCellIdentifier"
    
    @IBAction func retryFunction(sender: UIButton) {
        delayOpenDoor(0.0)
        sender.titleLabel?.textColor = UIColor.grayColor()
        
    }
    
    var loggedIn = false
    var deviceFound = false
    var functionSucceeded = false
    var myPhoton : SparkDevice?
    var photonName = "<INSERT_PHOTON_NAME"
    var email = "<INSERT_EMAIL>"
    
    
    let checkPoints = ["          Cloud login", "          Device link", "          Successful request"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        loginIndicator.hidesWhenStopped = true
        deviceSetupIndicator.hidesWhenStopped = true
        functionCallIndicator.hidesWhenStopped = true
        
        loginIndicator.startAnimating()
        deviceSetupIndicator.startAnimating()
        functionCallIndicator.startAnimating()
        
        loginStatus.hidden = true
        setupStatus.hidden = true
        functionStatus.hidden = true
        
        errorLabel.hidden = true
        retryButton.hidden = true
        retryButton.layer.cornerRadius = 5
        cloudLogin()
        listDevices()                   //call openDoor function within listDevices
        
        
    }

    
    

        


    
    func loadControlScreen() {
        //add stoplights for login, devicefinder and function
        //errorLabel.hidden = false
        //retryButton.hidden = false
        
        
    }

    
        
    func cloudLogin() {
        SparkCloud.sharedInstance().loginWithUser(email, password: "<INSERT_PASSWORD>") { (error:NSError!) -> Void in   //
            if let _=error {        //replaced e with _ since never used
                print("Wrong credentials or no internet connectivity, please try again")
                self.loadControlScreen()
            }
            else {
                print("Logged in")
                self.loggedIn = true
                self.loginIndicator.stopAnimating()
                self.loginStatus.hidden = false
            }
        }
        
    }
    
    
    func listDevices() {
        SparkCloud.sharedInstance().getDevices { (sparkDevices:[AnyObject]!, error:NSError!) -> Void in
            if let _ = error {
                print("Check your internet connectivity")
                self.loadControlScreen()
            }
            else {
                if let devices = sparkDevices as? [SparkDevice] {
                    for device in devices {                         //RUNS BY ALL DEVICES. Even after specified device was found
                        if device.name == self.photonName {             //CHANGE
                            self.myPhoton = device
                            self.deviceFound = true
                            break
                        } else {
                            //not necessary?
                        }
                    }
                    if self.deviceFound {
                        print("\(self.photonName) now used for all upcoming requests")
                        self.delayOpenDoor(0.0)
                        self.deviceSetupIndicator.stopAnimating()
                        self.setupStatus.hidden = false
                    
                    } else {
                        print("Specified device \(self.photonName) was not found")
                        self.deviceSetupIndicator.stopAnimating()
                        self.setupStatus.image = UIImage(named: "Untitled-2")
                        self.setupStatus.hidden = false
                        //also display function request as failed:
                        self.functionCallIndicator.stopAnimating()
                        self.functionStatus.image = UIImage(named: "Untitled-2")
                        self.functionStatus.hidden = false
                        
                    }
                }
            }
        }
    }
    
    
    func delayOpenDoor(seconds: Double) {
        functionCallIndicator.startAnimating()
        functionStatus.hidden = true
        delay(seconds) {
            // do stuff
            let funcArgs = ["<INSERT_CODE>"]
            if (self.myPhoton != nil) {
                self.myPhoton!.callFunction("open", withArguments: funcArgs) { (resultCode : NSNumber!, error : NSError!) -> Void in
                    if (error == nil) {
                        print("Door successfully opened")
                        self.functionCallIndicator.stopAnimating()
                        self.functionSucceeded = true
                        self.functionStatus.hidden = false
                        exit(0)
                    } else {
                        print(error) //"An error occurred while calling the \"open\" function")
                        self.functionCallIndicator.stopAnimating()
                        self.functionStatus.image = UIImage(named: "Untitled-2")
                        self.functionStatus.hidden = false
                        
                        self.loadControlScreen()
                    }
                }
            } else {
                self.delay(0.5) {
                    print("myPhoton object contains nil")
                    self.functionCallIndicator.stopAnimating()
                    self.functionStatus.image = UIImage(named: "Untitled-2")
                    self.functionStatus.hidden = false
                }
            }
        }
    }
    
    //how many separate sections, such as in settings app
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checkPoints.count
    }
    
    //get a reference to the tableView requesting info, and the indexPath it is looking for it on. Then return
    //a fully setup UITableViewCell with text set
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as UITableViewCell      //request a cell based off the prototype cell, which is returned as anyObject type and cast to UITableViewCell type
        
        let row = indexPath.row
        cell.textLabel?.text = checkPoints[row]
        
        return cell
    }
    
    //only UITableViewDelegate method: when user has tapped on cell do:
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
        print("Tapped row \(row): " + checkPoints[row])
        if row == 2 {
            if !functionStatus.hidden {
                delayOpenDoor(0.0)
            }
        } else if row == 1 {
            if (!deviceFound && !setupStatus.hidden) {
                deviceSetupIndicator.startAnimating()
                setupStatus.hidden = true
                listDevices()
            }
        } else if row == 0 {
            if (!loggedIn && !loginStatus.hidden) {
                cloudLogin()
                listDevices()
            }
        }
    }
    
    
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    


}

