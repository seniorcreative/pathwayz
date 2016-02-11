//
//  ResetViewController.swift
//  Pathwayz
//
//  Created by Steven Smith on 8/02/2016.
//  Copyright © 2016 Steven Smith. All rights reserved.
//

import UIKit
import CoreData

//protocol ResetViewDelegate {
//    
//    func resetPaths()
//}

class ResetViewController: UIViewController {
    
    // Have this verbose line at the top for access to core data throughout app.
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var myStoredLocations : [LocationModel] = []
    
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var resetButton: UIButton!
    
//    var delegate: ResetViewDelegate!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        resetButton.backgroundColor = UIColor.redColor()
        resetButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        resetButton.layer.cornerRadius = resetButton.layer.visibleRect.height / 2
        
        
        saveButton.backgroundColor = UIColor.yellowColor()
        saveButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        saveButton.layer.cornerRadius = saveButton.layer.visibleRect.height/2
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func resetButtonAction(sender: AnyObject) {
        
        print ("reset button pressed")
        
        // MARK : CORE DATA CLEARING
        
        // Code credit https://www.andrewcbancroft.com/2015/02/18/core-data-cheat-sheet-for-swift-ios-developers/#delete-multiple-entities
        
//        let predicate = NSPredicate(format: "MyEntityAttribute == %@", "Matching Value")
        let fetchRequest = NSFetchRequest(entityName: "LocationModel")
//        fetchRequest.predicate = predicate
        
        do {
            let fetchedEntities = try self.managedObjectContext.executeFetchRequest(fetchRequest) as! [LocationModel]
            
            for entity in fetchedEntities {
                self.managedObjectContext.deleteObject(entity)
            }
        } catch {
            // Do something in response to error condition
        }
        
        do {
            try self.managedObjectContext.save()
        } catch {
            // Do something in response to error condition
        }
        
    }
    
    
    
    @IBAction func buttonSave(sender: AnyObject) {
        
        
        NSUserDefaults.standardUserDefaults().setObject(radiusSlider.value * 10, forKey: "radiusSize")
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
