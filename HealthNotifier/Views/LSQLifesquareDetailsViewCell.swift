//
//  LSQLifesquareDetailsViewCell.swift
//
//  Created by Charles Mastin on 3/8/16.
//

import Foundation
import UIKit

class LSQLifesquareDetailsViewCell : UITableViewCell {
    
    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var addressTextLabel: UILabel!
    @IBOutlet weak var locationTextLabel: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setup()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }

    func setup() -> Void {
        // TODO: we should allow selection if we've already scanned this patient, lol and then send the show.patient message
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
}
