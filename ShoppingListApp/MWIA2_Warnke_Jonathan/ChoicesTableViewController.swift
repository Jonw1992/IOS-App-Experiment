//
//  ChoicesTableViewController.swift
//  MWIA2_Warnke_Jonathan
//
//  Created by Jonathan Warke on 10/29/15.
//  Copyright © 2015 Jonathan Warnke. All rights reserved.
//

import UIKit
import CoreData

class ChoicesTableViewController: UITableViewController {

    var initialData = [ "Apples", "Bread", "Butter", "Cheese", "Eggs", "Grapes", "Ice Cream", "Milk", "Oranges", "Oreos"]
    var alphabetHeaders = NSMutableArray()
    var newChoice: String = ""
    var choices = [NSManagedObject]()
    var shopList = [NSManagedObject]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Get app delegate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        // Get managed object context
        let context = appDelegate.managedObjectContext
        
        // Define the type of entity we are adding
        let entityItem = NSEntityDescription.entityForName("Choices",inManagedObjectContext: context)
        
        // Create a Boolean variable
        var emptyDB = false
        // Create a fetch request.
        let fetchRequest = NSFetchRequest(entityName: "Choices")
        
        // Fetch the records.
        do
        {
            let records = try context.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            if records.count == 0 { emptyDB = true }
        }
        catch let error as NSError
        {
            print("Cannot fetch - \(error), \(error.userInfo)")
        }

        
        // Only write the initial records if database is empty
        if emptyDB
        {
            
            for data in initialData
            {
                // Create managed object and insert it into managed object context
                let choice = NSManagedObject(entity: entityItem!, insertIntoManagedObjectContext: context)
                
                // Populate the new managed object choices
                choice.setValue(data, forKey: "name")
                choices.append(choice)
            }
            
            // Attempt to save context and reload data
            do
            {
                try context.save()
            }
            catch let error as NSError
            {
                print("Cannot save - \(error), \(error.userInfo)")
            }
        }
        self.tableView.reloadData()
        
    }
    
    
    
    
    override func viewWillAppear(animated: Bool)
    {
        fetchObjects()
    }
    
    func fetchObjects()
    {
        // Get app delegate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        // Get managed object context
        let context = appDelegate.managedObjectContext
        
        // Create a fetch request.
        let fetchRequestCourses = NSFetchRequest(entityName: "Choices")
        let fetchRequestShopList = NSFetchRequest(entityName: "ShopList")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true,
            selector: "localizedStandardCompare:")
        fetchRequestCourses.sortDescriptors = [sortDescriptor]
        
        // Fetch courses-------------------------------------------------------------------------
        do
        {
            let records = try context.executeFetchRequest(fetchRequestCourses)
            choices = records as! [NSManagedObject]
        }
        catch let error as NSError
        {
            print("Cannot fetch - \(error), \(error.userInfo)")
        }
        
        //Fetch shopping list------------------------------------------------------------------------
        do
        {
            let records = try context.executeFetchRequest(fetchRequestShopList)
            shopList = records as! [NSManagedObject]
        }
        catch let error as NSError
        {
            print("Cannot fetch - \(error), \(error.userInfo)")
        }
        
        
        //Assign an array of section headers
        alphabetHeaders = NSMutableArray()
        var previousChar: Character = " "
        
        for data in choices
        {
            //Get name of each choice
            let characters = data.valueForKey("name") as! String
            
            //If first letter of current choice is not the same as the previous one
            if(characters[characters.startIndex] != previousChar)
            {
                //Set the previous one to the current one
                previousChar = characters[characters.startIndex]
                
                //Add the first letter to the section headers array
                alphabetHeaders.addObject(String(characters[characters.startIndex]))
            }
            
        }
        
        
    }
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

//TABLE VIEW MANIPULATION-------------------------------------------------------------------------
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        // Return the number of sections
        return alphabetHeaders.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {

        //Return the header for the section
        return alphabetHeaders[section] as? String
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        var numRows = 0
        
        
        //Loop through and count number of choices that have the same first letter as the section header
        for data in choices
        {
            let characters = data.valueForKey("name") as! String

            if(characters[characters.startIndex] == Character(alphabetHeaders[section] as! String))
            {
                numRows++
            }
        }
        
        //Return the number of rows in section
        return numRows
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell1", forIndexPath: indexPath)
        
            var count = 0
            //Count how many items total are in all the previous sections
            if(indexPath.section > 0 )
            {
                for i in 0...indexPath.section - 1
                {
                    count += self.tableView.numberOfRowsInSection(i)
                }
            }
        
        //Cell text = the choices based on the number of sections before and the number of items in the same section before current
        cell.textLabel!.text = choices[count + indexPath.row].valueForKey("name") as? String

        return cell
    }
    
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?
    {
        
        var count = 0
        //Count how many items total are in all the previous sections
        if(indexPath.section > 0 )
        {
            for i in 0...indexPath.section - 1
            {
                count += self.tableView.numberOfRowsInSection(i)
            }
        }
        
        //Create delete action that is displayed as button when swiping left on a cell
        let delete = UITableViewRowAction(style: .Normal, title: "Delete")
            { action, index in
                
                //DELETE ITEM ------------------------------------------------------
                // Get app delegate
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                // Get managed object context
                let context = appDelegate.managedObjectContext
                
                var index = 0
                var found = false

                if(self.shopList.count > 0)
                {
                    //If the item you deleted is in the shopping list, set found to true
                    
                    print((self.choices[indexPath.row + count].valueForKey("name") as! String))
                    for i in 0...self.shopList.count - 1
                    {
                        if((self.choices[indexPath.row + count].valueForKey("name") as! String) == (self.shopList[i].valueForKey("choice")?.valueForKey("name") as! String))
                        {
                            index = i
                            found = true
                            print(index)
                        }
                        
                    }
                }
                
                
                var indexOfChoiceToDelete = 0
                
                
                let cell = tableView.cellForRowAtIndexPath(indexPath)
                
                
                //find the index of where the choice is to delete it
                for i in 0...self.choices.count - 1
                {
                    
                    if(String(cell!.textLabel!.text!) == String(self.choices[i].valueForKey("name")!))
                    {
                        indexOfChoiceToDelete = i
                    }
                }
                
                
                //If the item was found in shopping list, delete it there
                if(found)
                {
                    context.deleteObject(self.shopList[index])
                    self.shopList.removeAtIndex(index)
                }
                
                //Delete the item from choices
                context.deleteObject(self.choices[indexOfChoiceToDelete])
                self.choices.removeAtIndex(indexOfChoiceToDelete)
                
                
                //Attempt to save context and reload table data
                do
                {
                    try context.save()
                }
                catch let error as NSError
                {
                    print("Cannot save - \(error), \(error.userInfo)")
                }
                
                self.fetchObjects()
                
                self.tableView.reloadData()
                //-------------------------------------------------------------------
        }
        
        delete.backgroundColor = UIColor.redColor()
        
        return ([delete])
    }
    

//ON RETURN FROM CANCEL ON NEW CHOICE MENU-------------------------------------------------------------------
    @IBAction func backToChoices(segue:UIStoryboardSegue)
    {
        print("Back to choices")
    }
    
    
//ON RETURN FROM SAVING A NEW CHOICE-------------------------------------------------------------------
    @IBAction func saveChoiceAndReturn(segue:UIStoryboardSegue)
    {
        // Get app delegate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        // Get managed object context
        let context = appDelegate.managedObjectContext
        
         let entityItem = NSEntityDescription.entityForName("Choices",inManagedObjectContext: context)
        
        let choice = NSManagedObject(entity: entityItem!,
            insertIntoManagedObjectContext: context)
        
        
        // Populate the new managed object with choice data.
        choice.setValue(newChoice, forKey: "name")
        choices.append(choice)
        
        
        //Attempt to save context and reload table data
        do
        {
            try context.save()
        }
        catch let error as NSError
        {
            print("Cannot save - \(error), \(error.userInfo)")
        }
        
        fetchObjects()
        
        self.tableView.reloadData()
    }
    
    
    
//PREPARE FOR SEGUE-------------------------------------------------------------------
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        //If segue is to the shop list
        if(segue.identifier == "ChoicesToShopList")
        {
            //Send the name of selected choice
            let destination = segue.destinationViewController as! ShopListTableViewController
        
            destination.cellText = (self.tableView.cellForRowAtIndexPath(self.tableView.indexPathForSelectedRow!)?.textLabel)!.text!
        }
        
        self.tableView.reloadData()
    }
    




}
