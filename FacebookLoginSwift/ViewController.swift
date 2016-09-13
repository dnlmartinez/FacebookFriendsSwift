//
//  ViewController.swift
//  FacebookLoginSwift
//
//  Created by daniel martinez gonzalez on 13/9/16.
//  Copyright © 2016 daniel martinez gonzalez. All rights reserved.
//

import UIKit

struct Friends
{
    let id : String
    let name: String
    let url: String
    var flight : Bool
    var depCod : String
    var arrCod : String
    var Datedep : String
    var Datearr : String
    var State : String
}

class ViewController: UIViewController , FBSDKLoginButtonDelegate , UITableViewDataSource , UITableViewDelegate
{
    
    let loginView : FBSDKLoginButton = FBSDKLoginButton()
    var FriendsApp : [Friends]!
    var Load : Bool = false

    @IBOutlet weak var ViewTable: UIView!
    @IBOutlet weak var TablaFriends: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        dispatch_async(dispatch_get_main_queue())
        {
            let screenSize: CGRect = UIScreen.mainScreen().bounds
            let screenWidth = screenSize.width
            
            self.ViewTable.hidden = true
            self.TablaFriends.dataSource = self
            self.TablaFriends.delegate = self

            if screenWidth > 410
            {
                self.loginView.frame = CGRectMake(38 , self.view.frame.height - 140 , self.view.frame.width - 76 , 44)
            }
            else
            {
                self.loginView.frame = CGRectMake(34 , self.view.frame.height - 140 , self.view.frame.width - 68 , 44)
            }
            
            self.view.addSubview(self.loginView)
            self.loginView.readPermissions = ["public_profile", "email", "user_friends"]
            self.loginView.delegate = self
        }

    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: FACEBOOK DELEGATE
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!)
    {
        if ((error) != nil)
        {
            
        }
        else if result.isCancelled
        {
            
        }
        else
        {
            if result.grantedPermissions.contains("email")
            {
                dispatch_async(dispatch_get_main_queue())
                {
                    self.loginView.hidden = true
                    self.returnUserData()
                }
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!)
    {
        FBSDKAccessToken.currentAccessToken()
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
    }
    
    
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                dispatch_async(dispatch_get_main_queue())
                {
                    self.loginView.hidden = false
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue())
                {
                    self.loginView.hidden = true
                    self.FriendsApp = [Friends]()
                    self.DownloadFriendsFacebook()
                }
            }
        })
    }

    func DownloadFriendsFacebook()
    {
        let fbRequest = FBSDKGraphRequest(graphPath:"/me/friends", parameters: ["fields": "id, name, first_name, last_name, picture "]);
        fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            
            if error == nil
            {
                let Array : NSArray = result.objectForKey("data") as! NSArray
                for i in 0  ..< Array.count
                {
                    let Dict : NSDictionary = Array.objectAtIndex(i) as! NSDictionary
                    let Picture : NSDictionary = Dict.objectForKey("picture") as! NSDictionary
                    let PictureData : NSDictionary = Picture.objectForKey("data") as! NSDictionary
                    
                    let Id : String = Dict.objectForKey("id") as! String
                    let Name : String = Dict.objectForKey("name") as! String
                    let URLPicture : String = PictureData.objectForKey("url") as! String
                    
                    let depCod : String = ""
                    let arrCod : String = ""
                    let Datedep : String = ""
                    let Datearr : String = ""
                    let State : String = ""
                    
                    let friend = Friends(id: Id, name: Name, url: URLPicture, flight: false, depCod: depCod, arrCod: arrCod, Datedep: Datedep, Datearr: Datearr , State:State)
                    
                    self.FriendsApp.append(friend)
                }
                dispatch_async(dispatch_get_main_queue())
                {
                    self.Load = true 
                    self.TablaFriends.reloadData()
                    self.ViewTable.hidden = false
                }
            }
            else
            {
                print("Error Getting Friends \(error)")
            }
        }
    }
    
    //MARK: UITABLEVIEWDELEGATE
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if !Load
        {
            return 0
        }
        else
        {
            return FriendsApp.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
        
        let name : String = FriendsApp[indexPath.row].name
        
        cell.textLabel?.text = name

        return cell
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        self.TablaFriends .deselectRowAtIndexPath(indexPath, animated: true)
    }



}

