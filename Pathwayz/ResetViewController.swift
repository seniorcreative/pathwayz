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

class ResetViewController: UIViewController, UITextFieldDelegate {
    
    // Have this verbose line at the top for access to core data throughout app.
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var myStoredLocations : [LocationModel] = []
    
    @IBOutlet weak var bgRadCirc: UIView!
    @IBOutlet weak var topRadCirc: UIView!
    @IBOutlet weak var radiusValue: UILabel!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var resetButton: UIButton!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    
//    var delegate: ResetViewDelegate!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBOutlet weak var btnTeal: UIButton!
    @IBOutlet weak var btnOrange: UIButton!
    @IBOutlet weak var btnPurple: UIButton!
    
    @IBOutlet weak var blueCirc: UIView!
    @IBOutlet weak var orangeCirc: UIView!
    @IBOutlet weak var purpleCirc: UIView!
    
    @IBOutlet weak var blueTick: UIImageView!
    @IBOutlet weak var orangeTick: UIImageView!
    @IBOutlet weak var purpleTick: UIImageView!
    
    @IBAction func btnBlue(sender: AnyObject) {
        //
        setLineColor([0,204,204])
        blueTick.hidden = false
        orangeTick.hidden = true
        purpleTick.hidden = true
    }
    
    @IBAction func btnYellow(sender: AnyObject) {
        //
        setLineColor([255,110,0])
        blueTick.hidden = true
        orangeTick.hidden = false
        purpleTick.hidden = true
    }
    
    @IBAction func btnPurple(sender: AnyObject) {
        //
        setLineColor([102,0,153])
        blueTick.hidden = true
        orangeTick.hidden = true
        purpleTick.hidden = false
    }
    
    func setLineColor(colorArray: NSArray)
    {
        NSUserDefaults.standardUserDefaults().setObject(colorArray, forKey: "lineColor")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func getLineColor()
    {
        let lineColor = NSUserDefaults.standardUserDefaults().arrayForKey("lineColor")! as NSArray
        
        blueTick.hidden = true
        orangeTick.hidden = true
        purpleTick.hidden = true
        
        print("check line color \(lineColor[0])")
        
        if (Int(lineColor[0] as! NSNumber) == 0)
        {
            blueTick.hidden = false
        }
        if (Int(lineColor[0] as! NSNumber) == 255)
        {
            orangeTick.hidden = false
        }
        if (Int(lineColor[0] as! NSNumber) == 102)
        {
            purpleTick.hidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getLineColor()
        
        

        
        navigationController?.navigationBar.barTintColor = UIColor.yellowColor()
        navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "ShareTechMono-Regular", size: 18)!]

        
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self

        // Do any additional setup after loading the view.
        
        resetButton.backgroundColor = UIColor.yellowColor()
        resetButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        resetButton.layer.cornerRadius = resetButton.layer.visibleRect.height / 2
        
        
        saveButton.backgroundColor = UIColor.yellowColor()
        saveButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        saveButton.layer.cornerRadius = saveButton.layer.visibleRect.height/2
        
        
        bgRadCirc.backgroundColor = UIColor(colorLiteralRed: 233/255, green: 233/255, blue: 233/255, alpha: 1.0)
        bgRadCirc.layer.cornerRadius = bgRadCirc.layer.visibleRect.height / 2
        
        
        topRadCirc.backgroundColor = UIColor.yellowColor()
        topRadCirc.layer.cornerRadius = topRadCirc.layer.visibleRect.height / 2
        
        var radius = 100.0
        
        if (NSUserDefaults.standardUserDefaults().objectForKey("radiusSize") != nil) {
            
            radius = NSUserDefaults.standardUserDefaults().doubleForKey("radiusSize")
            
            radius = round(10 * radius) / 10
            
//            print("loaded radius \(radius)")
            
            radiusSlider.value = Float(radius / 10)
            
        }
        
        
        btnTeal.backgroundColor = UIColor(colorLiteralRed: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        btnTeal.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        btnTeal.layer.cornerRadius = btnTeal.layer.visibleRect.height / 2
        
        btnOrange.backgroundColor = UIColor(colorLiteralRed: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        btnOrange.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        btnOrange.layer.cornerRadius = btnOrange.layer.visibleRect.height / 2
        
        btnPurple.backgroundColor = UIColor(colorLiteralRed: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        btnPurple.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        btnPurple.layer.cornerRadius = btnPurple.layer.visibleRect.height / 2
        
        
        
        blueCirc.layer.cornerRadius = blueCirc.layer.visibleRect.height / 2
        orangeCirc.layer.cornerRadius = orangeCirc.layer.visibleRect.height / 2
        purpleCirc.layer.cornerRadius = purpleCirc.layer.visibleRect.height / 2
        
        
        resizeRadiusArea()
        
    }
    
    override func viewDidAppear(animated: Bool) {
    
        let firstName = NSUserDefaults.standardUserDefaults().stringForKey("firstNameKey")
        let lastName = NSUserDefaults.standardUserDefaults().stringForKey("lastNameKey")
        
        if (firstName != nil)
        {
            
            firstNameTextField.text = firstName
            
        }
        
        if (lastName != nil)
        {
            
            lastNameTextField.text = lastName
            
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func resetButtonAction(sender: AnyObject) {
        
//        print ("reset button pressed")
        
        
        
        
        let alertVC = UIAlertController(title: "Reset Pathwayz", message: nil, preferredStyle: .Alert)
        
        let resetAction = UIAlertAction(title: "Reset", style: .Default) { (UIAlertAction) -> Void in
            
            // Clear locally stored array of locations
    
            
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
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (UIAlertAction) -> Void in
            
            // Just Cancel
            
        }
        
        
        alertVC.addAction(resetAction)
        alertVC.addAction(cancelAction)
        
        self.presentViewController(alertVC, animated: true, completion: nil)
        
        
        
       
        
        
        
        
        
        
    }
    
    
    @IBAction func changeSlider(sender: AnyObject) {
        
        
        resizeRadiusArea()
        
    }
    
    func resizeRadiusArea()
    {
        radiusValue.text = String(round(10 * (radiusSlider.value * 100) / 10) / 10) + "m"
        
        let radiusPerc = CGFloat((radiusSlider.value - 10) / 90)
        
        let newRadius : CGFloat = CGFloat((70*radiusPerc) + 20.0)
        
//        print("slider value: \(radiusSlider.value) new circ radius \(newRadius)")
        
        topRadCirc.transform = CGAffineTransformMakeScale(radiusPerc, radiusPerc)
        
    }
    
    @IBAction func buttonSave(sender: AnyObject) {
        
        
        NSUserDefaults.standardUserDefaults().setObject(radiusSlider.value * 10, forKey: "radiusSize")
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString text: String) -> Bool {
        
        if(text == "\n") {
            
            NSUserDefaults.standardUserDefaults().setObject(firstNameTextField.text, forKey: "firstNameKey")
            NSUserDefaults.standardUserDefaults().setObject(lastNameTextField.text, forKey: "lastNameKey")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            textField.resignFirstResponder()
            return false
        }
        return true
        
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
