//
//  MyTableViewController.swift
//  Pathwayz
//
//  Created by Steven Smith on 6/02/2016.
//  Copyright © 2016 Steven Smith. All rights reserved.
//

import UIKit

class FriendsTableViewController: UITableViewController {

    
    var friends : NSMutableArray = []
    
    
    let fileIO : FileIO = FileIO()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
  
        getFriendsList()
        
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.friends.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as! CustomTableViewCell
        
        let friendItem = self.friends[indexPath.row]
        
//        print("got a friend \(friendItem!["name"])")

        // Configure the cell...
        
        cell.setNameIconColor(friendItem["color"] as! NSArray)
        cell.setVisible(friendItem["visible"] as! Int)
        
        cell.title!.text        = friendItem["shortname"] as! String
        cell.subtitle!.text     = friendItem["name"] as! String
        

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func getFriendsList()
    {
        
        let jsonRead : String = fileIO.read("json.txt")
//        print("got your json \(jsonRead)")
        
        do
        {
            
            let obj:AnyObject? = try NSJSONSerialization.JSONObjectWithData(jsonRead.dataUsingEncoding(NSUTF8StringEncoding)!, options: .AllowFragments)
            
            if let items = obj!["friends"] as? NSArray {
                
                
                for item in items
                {
//                    print("item \(item)")
                    friends.addObject(item)
                    
                }
                
//                print("length of friends \(self.friends.count)")
                
                self.tableView.reloadData()
                
    
            }
            
            
        }
        catch
        {
            
            print ("Error converting read of json into object")
            
        }
        
    }

}
