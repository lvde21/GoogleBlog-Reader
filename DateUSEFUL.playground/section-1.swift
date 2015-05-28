x// Playground - noun: a place where people can play

import UIKit

var str = "2013-07-21T19:32:00Z"

var dateFor: NSDateFormatter = NSDateFormatter()
dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"

var yourDate: NSDate? = dateFor.dateFromString(str)

println(yourDate!)