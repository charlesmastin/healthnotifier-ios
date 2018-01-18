//
//  Forms.swift
//
//  Created by Charles Mastin on 10/28/16.
//

import Foundation
import UIKit

class Forms {
    
    static func applyBaseTheme(cell: UITableViewCell) -> Void {
        //cell.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = UIColor.black.withAlphaComponent(0.8)
        cell.detailTextLabel?.textColor = UIColor.black.withAlphaComponent(0.6)
        //cell.backgroundColor = LSQ.appearance.color.newTeal
    }
    
    static func generatePrivacyRestrictedCell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellPrivacyRestrictedItem", for: indexPath) as! LSQCellPrivacyRestrictedItem
        return cell
    }
    
    static func generateEmptyCollectionCell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellEmptyCollection", for: indexPath) as! LSQCellEmptyCollection
        return cell
    }
    
    static func generateAddCollectionItemCell(_ tableView: UITableView, indexPath: IndexPath, collectionId: String) -> UITableViewCell {
        //let num: Int = Int(arc4random_uniform(100))
        //print(num)
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellAddCollectionItem", for: indexPath) as! LSQCellAddCollectionItem
        cell.collectionId = collectionId
        
        // trying here instead brolo
        
        
        return cell
    }
    
    static func generateDefaultInputCell(_ tableView: UITableView, indexPath: IndexPath, id: String, label: String, initialValue: String, required: Bool, placeholder: String? = nil) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellFormInput", for: indexPath) as! LSQCellFormInput
        cell.id = id
        cell.label?.text = label
        if required {
            cell.input?.placeholder = label + " *"
            //cell.label?.textColor = LSQ.appearance.color.black
            //cell.label?.text = label + " *"
        } else {
            //cell.label?.textColor = LSQ.appearance.color.gray0
            cell.input?.placeholder = label
        }
        cell.setInitial(initialValue)
        if LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor != nil {
            self.applyBaseTheme(cell: cell)
        }
        return cell
    }
    
    static func generateDefaultInputMultilineCell(_ tableView: UITableView, indexPath: IndexPath, id: String, label: String, initialValue: String, required: Bool, placeholder: String? = nil) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellFormInputMultiline", for: indexPath) as! LSQCellFormInputMultiline
        cell.id = id
        cell.setInitial(initialValue)
        if LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor != nil {
            self.applyBaseTheme(cell: cell)
        }
        return cell
    }
    
    static func generateDefaultSelectCell(_ tableView: UITableView, indexPath: IndexPath, id: String, label: String, initialValue: String, required: Bool, values: [[String: AnyObject]], placeholder: String? = nil) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellFormSelect", for: indexPath) as! LSQCellFormSelect
        cell.id = id
        cell.label?.text = label
        if required {
            cell.label2.placeholder = label + " *"
            //cell.label?.textColor = LSQ.appearance.color.black
            //cell.label?.text = label + " *"
        } else {
            cell.label2.placeholder = label
            //cell.label?.textColor = LSQ.appearance.color.gray0
        }
        cell.values = values
        cell.setInitial(initialValue)
        cell.addObservers()
        if LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor != nil {
            self.applyBaseTheme(cell: cell)
        }
        return cell
    }
    
    // USE cell select XIB
    static func generateDefaultDatePickerCell(_ tableView: UITableView, indexPath: IndexPath, id: String, label: String, initialValue: String, required: Bool, placeholder: String? = nil) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellFormDatePicker", for: indexPath) as! LSQCellFormDatePicker
        cell.id = id
        cell.label2.text = label
        
        if required {
            //cell.label?.textColor = LSQ.appearance.color.black
            //cell.label?.text = label + " *"
            cell.label2.placeholder = label + " *"
        } else {
            //cell.label?.textColor = LSQ.appearance.color.gray0
            cell.label2.placeholder = label
        }
        cell.setInitial(initialValue)
        cell.addObservers()
        if LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor != nil {
            self.applyBaseTheme(cell: cell)
        }
        return cell
    }
    
    // USE cell select XIB
    static func generateDefaultHeightPickerCell(_ tableView: UITableView, indexPath: IndexPath, id: String, label: String, initialValue: String, required: Bool, placeholder: String? = nil) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellFormHeightPicker", for: indexPath) as! LSQCellFormHeightPicker
        cell.id = id
        cell.label2?.text = label
        if required {
            //cell.label?.textColor = LSQ.appearance.color.black
            //cell.label?.text = label + " *"
            cell.label2.placeholder = label + " *"
        } else {
            //cell.label?.textColor = LSQ.appearance.color.gray0
            cell.label2.placeholder = label
        }
        cell.setInitial(initialValue)
        cell.addObservers()
        if LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor != nil {
            self.applyBaseTheme(cell: cell)
        }
        return cell
    }
    
    // USE cell select XIB
    static func generateDefaultAutocompleteCell(_ tableView: UITableView, indexPath: IndexPath, id: String, label: String, initialValue: String, required: Bool, autocompleteId: String) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellFormAutocomplete", for: indexPath) as! LSQCellFormAutocomplete
        cell.id = id
        cell.autocompleteId = autocompleteId
        cell.label2.text = label
        if required {
            //cell.label2.textColor = LSQ.appearance.color.black
            cell.label2.placeholder = label + " *"
        } else {
            //cell.label?.textColor = LSQ.appearance.color.gray0
            cell.label2.placeholder = label
        }
        //var iv: String = initialValue
        /*
        if iv == "" {
            iv = "–"
        }
         */
        cell.setInitial(initialValue)
        cell.addObservers()
        if LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor != nil {
            self.applyBaseTheme(cell: cell)
        }
        return cell
    }
    
    static func generateDefaultCheckboxCell(_ tableView: UITableView, indexPath: IndexPath, id: String, label: String, initialValue: Bool, required: Bool, placeholder: String? = nil) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellFormCheckbox", for: indexPath) as! LSQCellFormCheckbox
        cell.id = id
        cell.label?.text = label
        if required {
            cell.label?.textColor = LSQ.appearance.color.black
            cell.label?.text = label + " *"
        } else {
            cell.label?.textColor = LSQ.appearance.color.gray0
        }
        cell.setInitial(initialValue)
        if LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor != nil {
            self.applyBaseTheme(cell: cell)
            // AKA equivaelnt placeholder color, lolbrolo
            cell.label?.textColor = UIColor.black.withAlphaComponent(0.6)
            // black blablabla vs say a percent darker of the color, which is better bro
            cell.input?.tintColor = UIColor.black.withAlphaComponent(0.3)
            cell.input?.onTintColor = UIColor.black.withAlphaComponent(0.3)
        }
        return cell
    }
    
}
