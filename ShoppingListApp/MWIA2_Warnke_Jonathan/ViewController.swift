//
//  ViewController.swift
//  MWIA2_Warnke_Jonathan
//
//  Created by Jonathan Warnke on 10/29/15.
//  Copyright © 2015 Jonathan Warnke. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var text: UITextField!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        //If segue is "Save" then set the destination view controller string variable to the new choice with a capitalized first letter
        if(segue.identifier == "Save")
        {
            let destination = segue.destinationViewController as! ChoicesTableViewController
            
            let x = String(UTF8String: text.text!)!
            let z = x.characters.dropFirst()

            destination.newChoice = String(String(x[x.startIndex]).uppercaseString + String(z))
        }
        
    }

}

