//
//  LSQCellAddCollectionItem.swift
//
//  Created by Charles Mastin on 10/28/16.
//

import Foundation
import UIKit

class LSQCellAddCollectionItem: UITableViewCell {
    
    // this is specifically a class because we wanted to type check, and because we needed the collectionId
    var labelText: String = "Add Item"
    var labelColor: UIColor = LSQ.appearance.color.blueApple
    var deleteMode: Bool = false
    
    // this is just basically a serious time saver
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // constants son
        self.detailTextLabel?.text = self.labelText
        self.selectionStyle = UITableViewCellSelectionStyle.default
        
        // toggle state based on global appearance state
        if LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor != nil {
            self.backgroundColor = UIColor.clear
            self.detailTextLabel?.textColor = UIColor.white.withAlphaComponent(0.8)
            self.detailTextLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
            if self.deleteMode {
                // bold it???
            } else {
                // self.detailTextLabel?.textColor = UIColor.white.withAlphaComponent(0.8)
            }
        } else {
            self.backgroundColor = UIColor.white
            self.detailTextLabel?.textColor = LSQ.appearance.color.blueApple
            self.detailTextLabel?.font = UIFont.systemFont(ofSize: 14.0)
            // WAY TOO MUCH CONFLICT HERE!!!!! with the cache cycle
            /*
            if self.deleteMode {
                self.detailTextLabel?.textColor = LSQ.appearance.color.red
            } else {
                self.detailTextLabel?.textColor = LSQ.appearance.color.blueApple
            }
             */
        }
        
        // then assign/re-assign display properties in here son
    }
    
    // just store the collection id, that's it
    var collectionId: String? = nil
    
    // just a FYI, this is furthering our desire to handle the "press" internally to this cell vs in the containing table
    // that way we're drying this MOther trucker up
    // that said, we could migrate the code into here later
    
    override func prepareForReuse() {
        super.prepareForReuse() // oooops
        self.layoutSubviews()
    }
    
}
