//
//  MasterViewController.swift
//  Blog Reader
//
//  Created by Lala Vaishno De on 5/27/15.
//  Copyright (c) 2015 Casa Wee. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    
    
    var managedObjectContext: NSManagedObjectContext? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK : initialization for core data saving
        
        var appDel : AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        var context : NSManagedObjectContext = appDel.managedObjectContext!
        
        
        
        
        
        // MARK : setting up URL
    
        let url = NSURL(string: "https://www.googleapis.com/blogger/v3/blogs/10861780/posts?key=AIzaSyCWHQIxPFhF5hG-UIppwBB1zl2BBeRO4zg")
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in
            
            if(error != nil)
            {
                println(error)
            }
            else
            {
                // MARK : Parse JSON
                
                //println(NSString(data: data, encoding: NSUTF8StringEncoding))
                
                let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
                
                if(jsonResult.count > 0)
                {
                    if let items = jsonResult["items"] as? NSArray
                    {
                        
                        
                        // delete pre-existing items from core data
                        
                        var request = NSFetchRequest(entityName: "Posts")
                        
                        request.returnsObjectsAsFaults = false
                        
                        var results = context.executeFetchRequest(request, error: nil)!
                        
                        if results.count > 0
                        {
                            for result in results
                            {
                            
                                context.deleteObject(result as NSManagedObject)
                            
                                context.save(nil)
                            }
                        }
                        
                        
                        
                        
                        // save All items into core data
                        
                        for item in items
                        {
                            if let title = item["title"] as? String
                            {
                                if let content = item["content"] as? String
                                {
                                    // if both title and content exists
                
                                    var newPost : NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName("Posts", inManagedObjectContext: context) as NSManagedObject
                                    
                                    newPost.setValue(title, forKey: "title")
                                    
                                    newPost.setValue(content, forKey: "content")
                                    
                                    
                                    // silly date parsing
                                    
                                    if var date = item["published"] as? NSString {
                                    
                                        date = date.substringToIndex(10)
                                        newPost.setValue(date, forKey: "date")
                                        
//                                        var dateFor : NSDateFormatter = NSDateFormatter()
//                                        dateFor.dateFormat = "yyyy-MM-dd"
//                                        
//                                        var savedDate : NSDate? = dateFor.dateFromString(date)
//                                        
//                                        println(savedDate)
//                                        
//                                        println("WTF HAPPENED!")
                                        
                                        
                                        
                                    }
                                    
                                    context.save(nil)
                                    
                                }
                            }
                        }
                    }
                    
                }
                
                
                
                // TEST : checking if core data has been ideally saved
                
//                var request = NSFetchRequest(entityName: "Posts")
//                request.returnsObjectsAsFaults = false
//                var results = context.executeFetchRequest(request, error: nil)!
//                println(results)
                
                
                
                // update table from core data
                
                self.tableView.reloadData()
                
            }
            
            
        })
   
        task.resume()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        
    }

   
    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail"
        {
           
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject
                
                // sets the detailviewcontroller's object called detailItem to be equal to the object
                (segue.destinationViewController as DetailViewController).detailItem = object
            }

            
        }
    
    }
    

    // MARK: - Table View
    

     override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

     override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }

     override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject
        cell.textLabel!.text = object.valueForKey("title")!.description
        cell.detailTextLabel!.text = object.valueForKey("date")!.description
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return false
    }
    
    
    
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Posts", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        // sort key is used to sort the data based on the key
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        let sortDescriptors = [sortDescriptor]
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        var error: NSError? = nil
        if !_fetchedResultsController!.performFetch(&error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }

    
}



