//
//  LSQCellEmptyCollection.swift
//
//  Created by Charles Mastin on 11/08/16.
//

import Foundation
import UIKit

class LSQCellEmptyCollection: UITableViewCell {
    
    // this is specifically a class because we wanted to type check, and because we needed the collectionId
    
    // this is just basically a serious time saver
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // self.detailTextLabel?.textColor = LSQ.appearance.color.blueApple
        self.detailTextLabel?.text = "No known items"
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
}
