//
//  LSQFormHeightPickerViewController.swift
//
//  Created by Charles Mastin on 1/17/17.
//

import Foundation
import UIKit

class LSQFormHeightPickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    var value: Int? = nil // centimeters my brosef
    var id: String = "myheightfield"
    
    @IBOutlet weak var picker: UIPickerView!
    @IBAction func actionDone(){
        // sum up dem inches bra
        var inches: Int = 0
        inches = inches + (self.picker.selectedRow(inComponent: 0) * 12)
        inches = inches + (self.picker.selectedRow(inComponent: 1))
        // this one should not round at all
        let centimeters: Int = LSQ.formatter.inchesToCentimeters(inches)

        NotificationCenter.default.post(
            name: LSQ.notification.form.field.change,
            object: self,
            userInfo: [
                "id": self.id,
                "value": String(centimeters) // WTF BRIZLE
            ]
        )
        self.close()
    }
    
    internal func close(){
        self.dismissMe(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // fill it out son
        if self.value != nil {
            let totalInches: Int = LSQ.formatter.centimetersToInches(self.value!)
            let feet:Int = LSQ.formatter.inchesToFeet(totalInches)
            let inches:Int = LSQ.formatter.inchesToFootInches(totalInches)
            self.picker.selectRow(feet, inComponent: 0, animated: false)
            self.picker.selectRow(inches, inComponent: 1, animated: false)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 8
        }
        if component == 1 {
            return 12
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            if row == 0 {
                return "0'"
            }
            if row == 1 {
                return "1'"
            }
            if row == 2 {
                return "2'"
            }
            if row == 3 {
                return "3'"
            }
            if row == 4 {
                return "4'"
            }
            if row == 5 {
                return "5'"
            }
            if row == 6 {
                return "6'"
            }
            if row == 7 {
                return "7'"
            }
        }
        if component == 1 {
            if row == 0 {
                return "0\""
            }
            if row == 1 {
                return "1\""
            }
            if row == 2 {
                return "2\""
            }
            if row == 3 {
                return "3\""
            }
            if row == 4 {
                return "4\""
            }
            if row == 5 {
                return "5\""
            }
            if row == 6 {
                return "6\""
            }
            if row == 7 {
                return "7\""
            }
            if row == 8 {
                return "8\""
            }
            if row == 9 {
                return "9\""
            }
            if row == 10 {
                return "10\""
            }
            if row == 11 {
                return "11\""
            }
        }
        return ""
    }
    
    
}
