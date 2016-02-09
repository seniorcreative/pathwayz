//
//  CustomTableViewCell.swift
//  Pathwayz
//
//  Created by Steven Smith on 9/02/2016.
//  Copyright © 2016 Steven Smith. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var onSwitch: UISwitch!
    
    var myColor : UIColor = UIColor.redColor()
    
    var boolLocationOn : Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        colorView.layer.cornerRadius = colorView.layer.visibleRect.height / 2
        
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setNameIconColor(colorArray: NSArray)
    {
        
        let red = colorArray[0] as? Float
        
        let green = colorArray[1] as? Float
        
        let blue = colorArray[2] as? Float
        
        
        colorView.backgroundColor = UIColor(colorLiteralRed: red!/255, green: green!/255, blue: blue!/255, alpha: 1.0)
        
        
    }
    
    func setVisible(visible: Int)
    {
        
        if visible == 1
        {
            onSwitch.setOn(true, animated: true)
        }
        else
        {
            onSwitch.setOn(false, animated: false)
        }
        
    }

}
