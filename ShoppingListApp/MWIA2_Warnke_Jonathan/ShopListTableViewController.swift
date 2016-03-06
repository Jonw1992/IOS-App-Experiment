//
//  ShopListTableViewController.swift
//  MWIA2_Warnke_Jonathan
//
//  Created by Jonathan Warnke on 11/5/15.
//  Copyright © 2015 Jonathan Warnke. All rights reserved.
//

import UIKit
import CoreData

class ShopListTableViewController: UITableViewController
{
    var shopList = [NSManagedObject]()
    var choices = [NSManagedObject]()
    var cellText: String = ""
    var indexOfAddedItem = 0
    var shaken: Bool = false

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tableView.reloadData()        
    }
    
    override func viewWillAppear(animated: Bool)
    {
        // Get app delegate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        // Get managed object context
        let context = appDelegate.managedObjectContext
        
        // Create a fetch request.
        let fetchRequest = NSFetchRequest(entityName: "ShopList")
        
        // Fetch the shopping list
        do
        {
            let records = try context.executeFetchRequest(fetchRequest)
            shopList = records as! [NSManagedObject]
        }
        catch let error as NSError
        {
            print("Cannot fetch - \(error), \(error.userInfo)")
        }
        
        self.tableView.reloadData()
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
//TABLE VIEW MANIPULATION-------------------------------------------------------------------------
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // #warning Incomplete implementation, return the number of rows
        return shopList.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        //Get cell at index path
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell1", forIndexPath: indexPath)
        
        

        //If the shopping list item is not nil then set the text label to the item and the detail label to the count
        if(shopList[indexPath.row].valueForKey("choice")?.valueForKey("name")! != nil)
        {
            cell.textLabel!.text = (shopList[indexPath.row].valueForKey("choice")!.valueForKey("name")! as! String)
            
            let count: Int = shopList[indexPath.row].valueForKey("count") as! Int
            
            cell.detailTextLabel!.text = String(count)
        
            //print(shopList[indexPath.row].valueForKey("count")!)
        }
        

        //Add tap gesture recognizer to the image view of the table cell
        let tap = UITapGestureRecognizer(target: self, action: Selector("imageTapped:"))
        cell.imageView!.addGestureRecognizer(tap)
        
        //print("TAG: " + String(cell.imageView!.tag))
    
        
        return cell
    }
    

    
    
    
    
//CALLED WHEN THE PHONE IS SHAKEN-------------------------------------------------------------------------
    override func  motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?)
    {
        shaken = true
        //self.tableView.reloadData()
        
        
        
        let indexPaths: [NSIndexPath] = tableView.indexPathsForVisibleRows!
        

        //print(indexPaths)
        for i in 0...shopList.count - 1
        {
            let cell = tableView.cellForRowAtIndexPath(indexPaths[i])
            //print("I = " + String(i))
            if((cell?.imageView) != nil)
            {
            if(cell!.imageView!.tag == 1)
            {
                
                // Get app delegate
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                // Get managed object context
                let context = appDelegate.managedObjectContext
                
                
                //Delete the object, save the context and reload the tableview
                context.deleteObject(self.shopList[indexPaths[i].row])
                self.shopList.removeAtIndex(indexPaths[i].row)
                
                do
                {
                    try context.save()
                }
                catch let error as NSError
                {
                    print("Cannot save - \(error), \(error.userInfo)")
                }
                
                //print("Found Checked Cell")
                
                cell!.imageView!.tag = 0
                //set image view of cell to unchecked image
                cell!.imageView!.image = UIImage(named:"unchecked.png")
                
                
            }
            //Reset the tag to 0

            
 
            }
            self.tableView.reloadData()

        }
        
               print("You shook the phone.")
    }
    
    
    
//ACTION FOR RETURNING FROM CHOICES VIEW BY TAPPING AN ITEM-------------------------------------------------------------------------
    @IBAction func backToShopList(segue:UIStoryboardSegue)
    {
        
        // Get app delegate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        // Get managed object context
        let context = appDelegate.managedObjectContext
        
        //Create fetch request for choices
        let fetchRequest = NSFetchRequest(entityName: "Choices")
        
        do
        {
            let records = try context.executeFetchRequest(fetchRequest)
            choices = records as! [NSManagedObject]
        }
        catch let error as NSError
        {
            print("Cannot fetch - \(error), \(error.userInfo)")
        }
        

        // Define the type of entity we are adding.
        let entityItem = NSEntityDescription.entityForName("ShopList",inManagedObjectContext: context)

        //Find Choice in Choices entity, get the object and assign it to ShopList
        var alreadyAdded = false
        
        self.tableView.reloadData()
        
        for data in shopList
        {
            
            if cellText == (data.valueForKey("choice")!.valueForKey("name")! as! String)
            {
                alreadyAdded = true
            }
        }
        
        //If the item is already on the list find the index of the item and increment the item's count
        if(alreadyAdded)
        {
            for i in 0...(choices.count - 1)
            {
                if(cellText == choices[i].valueForKeyPath("name")! as! String)
                {
                    indexOfAddedItem = i
                }
            }
            
            incrementItemInShopList()
        }
        //Otherwise add the item to the shopping list
        else
        {
            for i in 0...(choices.count - 1)
            {
                if(cellText == choices[i].valueForKeyPath("name")! as! String)
                {
                    let choiceItem = NSManagedObject(entity: entityItem!,insertIntoManagedObjectContext: context)
          
                    choiceItem.setValue(choices[i], forKey: "choice")
                    choiceItem.setValue(1, forKey: "count")
                    shopList.append(choiceItem)
                    
                    indexOfAddedItem = i
                }
            }
            

        }
        
        //Attempt to save the context and reload the table data
        do
        {
            try context.save()
        }
        catch let error as NSError
        {
            print("Cannot save - \(error), \(error.userInfo)")
        }
        
        self.tableView.reloadData()
    }
    
    

    
    
    
//HANDLE SWIPING LEFT ON A SHOPLIST ITEM------------------------------------------------------------------------------------------------------------
    
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?
    {
        //Create tableview row action
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete")
        { action, index in
            
            //Create UIAlertController
            let alertController = UIAlertController(title: "Delete how many?", message: "", preferredStyle: .Alert)
            
    //If item count is > 1 present the option to delete 1 or all choices----------------------------------------
            if (self.shopList[indexPath.row].valueForKey("count") as! Int > 1)
            {
                //Add "All" button that deletes an item completely from the shop list
                let reset = UIAlertAction(title: "All", style: .Default)
                { (action) in
                       self.deleteItemFromShopList(indexPath)
                }
                alertController.addAction(reset)
                
                //Add "One" button to controlller that decrements an items count by 1
                let cancel = UIAlertAction(title: "1", style: .Cancel) { (action) in
                    self.decremenItemInShopList(tableView, indexPath: indexPath)
                }
                alertController.addAction(cancel)
                    
                
                //Display UIAlert
                self.presentViewController(alertController, animated: true) {}
            }
                
    //Otherwise just delete the item from the shopping list------------------------------------------------------
            else
            {
                self.deleteItemFromShopList(indexPath)
            }
        }
        

        delete.backgroundColor = UIColor.redColor()

        return ([delete])
    }
    

    
    
//ACTION FUNCTIONS-------------------------------------------------------
    
    func imageTapped(sender: UITapGestureRecognizer?)
    {
        //get image view of the cell that was tapped
        let img = sender!.view as! UIImageView
        
        //determine if the cell should be checked/unchecked... change tag and image accordingly
        if(sender!.view!.tag == 0)
        {
            sender!.view!.tag = 1
            img.image = UIImage(named:"checked.png")
        }
        else
        {
            sender!.view!.tag = 0
            img.image = UIImage(named:"unchecked.png")
        }
        
        //reload table data
        self.tableView.reloadData()
    }
    
    
    
//EXTRA FUNCTIONS IN ATTEMPT TO SIMPLIFY CODE READABILITY-------------------------------------------------------
    
    
    
    func decremenItemInShopList(tableView: UITableView, indexPath: NSIndexPath)
    {
        // Get app delegate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        // Get managed object context
        let context = appDelegate.managedObjectContext
        
        //Create a fetch request for the shop list
        let fetchRequest = NSFetchRequest(entityName: "ShopList")
        
        //Set fetch request predicate to a choice has the same name as the lable on the cell
        fetchRequest.predicate = NSPredicate(format: "choice.name == %@",(tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text)!)
        
        do
        {
            //Fetch record and decrement the count for that item
            if let records = try context.executeFetchRequest(fetchRequest) as? [NSManagedObject]{
                
                let c: Int = records[0].valueForKey("count") as! Int
                records[0].setValue(c - 1,forKey:"count")
            }
            
            
            //Attempt to save the context and reload the table data
            do
            {
                try context.save()
            }
            catch let error as NSError
            {
                print("Cannot save - \(error), \(error.userInfo)")
            }
            
            self.tableView.reloadData()
        }
        catch
        {
            print("error")
        }
        
        
        self.tableView.reloadData()
    }
    func deleteItemFromShopList(indexPath: NSIndexPath)
    {
        //DELETE ITEM ------------------------------------------------------
        // Get app delegate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        // Get managed object context
        let context = appDelegate.managedObjectContext
        
        
        //Delete item from context and the NSManagedObject
        context.deleteObject(self.shopList[indexPath.row])
        self.shopList.removeAtIndex(indexPath.row)
        
        //Attempt to save the context and reload the table data
        do
        {
            try context.save()
        }
        catch let error as NSError
        {
            print("Cannot save - \(error), \(error.userInfo)")
        }
        
        self.tableView.reloadData()
        //-------------------------------------------------------------------
    }
    
    func incrementItemInShopList()
    {
        // Get app delegate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        // Get managed object context
        let context = appDelegate.managedObjectContext
        
        //Create a fetch request for the shop list
        let fetchRequest = NSFetchRequest(entityName: "ShopList")
        
        //Set fetch request predicate to a shopping list item that was clicked on the choices view
        fetchRequest.predicate = NSPredicate(format: "choice = %@",choices[indexOfAddedItem])
        
        do{
            //Fetch record and increment the count for that item
            if let records = try context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            {
                let c: Int = records[0].valueForKey("count") as! Int
                records[0].setValue(c + 1,forKey:"count")
            }
            
            
            //Attempt to save the context and reload the table data
            do
            {
                try context.save()
            }
            catch let error as NSError
            {
                print("Cannot save - \(error), \(error.userInfo)")
            }
            
            self.tableView.reloadData()
        }
            
        catch
        {
            print("error")
        }
        
    }

}
