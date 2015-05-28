//
//  DetailViewController.swift
//  Blog Reader
//
//  Created by Lala Vaishno De on 5/27/15.
//  Copyright (c) 2015 Casa Wee. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!

    @IBOutlet weak var blogTitle: UINavigationItem!
    
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail: AnyObject = self.detailItem {
            
            // setting blog title
            blogTitle.title = detail.valueForKey("title")!.description
            
            if let wv = self.webView {
                
                // takes value for the content for the key and load it onto web view **
                wv.loadHTMLString(detail.valueForKey("content")!.description, baseURL: nil)
                
                
                
                
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

