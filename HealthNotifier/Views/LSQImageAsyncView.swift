//
//  LSQProfileTableViewCell.swift
//
//  Created by Charles Mastin on 3/7/16.
//
// http://stackoverflow.com/questions/24231680/loading-image-from-url

import Foundation
import UIKit

class LSQImageAsyncView :UIImageView
{
    override init(frame:CGRect)
    {
        super.init(frame:frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func getDataFromUrl(url:String, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: url)!) { (data, response, error) in
            completion(data: NSData(data: data!))
            }.resume()
    }
    
    func downloadImage(url:String){
        getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
                self.contentMode = UIViewContentMode.ScaleAspectFill
                self.image = UIImage(data: data!)
            }
        }
    }
}
