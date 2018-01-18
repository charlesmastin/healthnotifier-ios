//
//  LSQModels.swift
//
//  Created by Charles Mastin on 11/8/16.
//

import Foundation
import SwiftyJSON
import UIKit

// be huggin JOINKs

protocol LSQModelField {
    var property: String { get set } // for JSON api
    var label: String { get set }
    var formControl: String { get set } // input, select, autocomplete, checkbox, etc
    var required: Bool { get set }
    var dataType: String { get set } // datatype, but really only json valid things basically
    // var initial: AnyObject { get set }
}


class LSQModelFieldC: LSQModelField {
    var property: String = ""
    var label: String = ""
    var formControl: String = "input"
    var required: Bool = false
    var dataType: String = "string"
    
    // base getter on the label, returns the camel to snake case on dat property
    var values: [[String: AnyObject]] = []
    var autocompleteId: String = ""
    
    var keyboard: UIKeyboardType = UIKeyboardType.default
    
    // var validation type - something or a custom blall
    // relevant for stuffs like emails and phone nums son
    
    // default falue son? to be "cast" later
    var initial: AnyObject?
}

protocol LSQSelectField: LSQModelField {
    var values: [[String: AnyObject]] { get set } // TODO make optional or cut son
}

protocol LSQAutocompleteField: LSQModelField {
    var autocompleteId: String { get set }
}

class LSQModel {
    
    // so we have the fields as a virtual attribute
    
    // reinventing wheels, but this is mmkay now mmkay
    // base class for the model
    // contain all the common logics son
    // how to import json (basically) don't bother, just do the raw json object
    // how to create a new object
    // how to edit objects
    // magic method to iterate all properties that have LSQModelField in their protocol chain
    func getDefaultJson() -> JSON {
        var attributes: [String:AnyObject] = [:]
        let mirrored_object = Mirror(reflecting: self)
        
        for (_, attr) in mirrored_object.children.enumerated() {
            
            if attr.value is LSQModelFieldC {
                // provide defaults son
                
                let field: LSQModelFieldC = (attr.value as? LSQModelFieldC)!
                if field.dataType == "string" {
                    attributes[field.property] = "" as AnyObject?
                    /* subclass doesn't access this, so let's just punt on the stuff for now :( */
                    
                    if field.initial != nil {
                        attributes[field.property] = field.initial as AnyObject?
                    }
                    
                }
                // ints only I suppose
                if field.dataType == "number" {
                    attributes[field.property] = 0 as AnyObject?
                }
                
                if field.dataType == "boolean" {
                    attributes[field.property] = false as AnyObject?
                }
            }
        }
        return JSON(attributes)
    }
}

class LSQModelCollectionItem: LSQModel {

//    var patientId: Int = 0
    var recordOrder: Int = 0
    var collectionName: String = ""
    
    var privacy: LSQModelFieldC
    
    override init () {
        self.privacy = LSQModelFieldC()
        self.privacy.property = "privacy"
        self.privacy.label = "Privacy"
        self.privacy.formControl = "select"
        self.privacy.required = true
        self.privacy.values = LSQAPI.sharedInstance.getValues("privacy")
        
        super.init()
    }
    

    override func getDefaultJson() -> JSON {
        var json: JSON = super.getDefaultJson()
        // little skeez doesn't understand privacy, ok, ok, ok, fair
        json["privacy"].string = "provider" // we need a default per collection!!!!
        json["record_order"].int = self.recordOrder
        
        // FML
        if self.collectionName == "patient_contacts" ||
            self.collectionName == "patient_allergies" ||
            self.collectionName == "patient_medical_facilities" {
            json["privacy"].string = "public"
        }
        
        return json
    }

}

// convenience field definitions, like privacy, which always get their values from the same place

class LSQModelProfile : LSQModel {
    // each subclass
    // field definitions
    // plugins on value changes "watched properties"
    // unique instanaces, aka, change on record123.property
    // db migration uuid on every collection table
    // deal with the hidden fields
    // magic method to iterate all properties that have LSQModelField in their protocol chain
    var firstName: LSQModelFieldC
    var lastName: LSQModelFieldC
    var middleName: LSQModelFieldC
    var suffix: LSQModelFieldC
    var birthdate: LSQModelFieldC
    var organDonor: LSQModelFieldC
    var searchable: LSQModelFieldC
    var demographicsPrivacy: LSQModelFieldC
    var gender: LSQModelFieldC
    var ethnicity: LSQModelFieldC
    var biometricsPrivacy: LSQModelFieldC
    var hairColor: LSQModelFieldC
    var eyeColor: LSQModelFieldC
    var height: LSQModelFieldC
    var weight: LSQModelFieldC
    var bloodType: LSQModelFieldC
    var bpSystolic: LSQModelFieldC
    var bpDiastolic: LSQModelFieldC
    var pulse: LSQModelFieldC
    
    override init () {
        // bring our own fields up to speed now
        self.firstName = LSQModelFieldC()
        self.firstName.property = "first_name"
        self.firstName.label = "First Name"
        self.firstName.required = true
        // self.firstName.keyboard = UIKeyboardType.
        
        self.lastName = LSQModelFieldC()
        self.lastName.property = "last_name"
        self.lastName.label = "Last Name"
        self.lastName.required = true
        
        self.middleName = LSQModelFieldC()
        self.middleName.property = "middle_name"
        self.middleName.label = "Middle Name"
        
        self.suffix = LSQModelFieldC()
        self.suffix.property = "suffix"
        self.suffix.label = "Suffix"
        
        self.birthdate = LSQModelFieldC()
        self.birthdate.property = "birthdate"
        self.birthdate.label = "DOB"
        self.birthdate.required = true
        self.birthdate.formControl = "datepicker"
        // YYYY-MM-DD
        // date string son so we can go to and from
        
        self.organDonor = LSQModelFieldC()
        self.organDonor.property = "organ_donor"
        self.organDonor.label = "Organ Donor"
        self.organDonor.formControl = "checkbox"
        self.organDonor.dataType = "boolean"
        
        self.searchable = LSQModelFieldC()
        self.searchable.property = "searchable"
        self.searchable.label = "Discoverable"
        self.searchable.formControl = "checkbox"
        self.searchable.dataType = "boolean"
        
        self.demographicsPrivacy = LSQModelFieldC()
        self.demographicsPrivacy.property = "demographics_privacy"
        self.demographicsPrivacy.label = "Privacy"
        self.demographicsPrivacy.formControl = "select"
        self.demographicsPrivacy.required = true
        self.demographicsPrivacy.values = LSQAPI.sharedInstance.getValues("privacy")
        
        self.gender = LSQModelFieldC()
        self.gender.property = "gender"
        self.gender.label = "Gender"
        self.gender.formControl = "select"
        self.gender.values = LSQAPI.sharedInstance.getValues("patient", attribute: "gender")
        
        self.ethnicity = LSQModelFieldC()
        self.ethnicity.property = "ethnicity"
        self.ethnicity.label = "Race"
        self.ethnicity.formControl = "select"
        self.ethnicity.values = LSQAPI.sharedInstance.getValues("patient", attribute: "ethnicity")
        
        self.biometricsPrivacy = LSQModelFieldC()
        self.biometricsPrivacy.property = "biometrics_privacy"
        self.biometricsPrivacy.label = "Privacy"
        self.biometricsPrivacy.formControl = "select"
        self.biometricsPrivacy.required = true
        self.biometricsPrivacy.values = LSQAPI.sharedInstance.getValues("privacy")
        
        self.hairColor = LSQModelFieldC()
        self.hairColor.property = "hair_color"
        self.hairColor.label = "Hair Color"
        self.hairColor.formControl = "select"
        self.hairColor.values = LSQAPI.sharedInstance.getValues("patient", attribute: "hair_color")
        
        self.eyeColor = LSQModelFieldC()
        self.eyeColor.property = "eye_color_both"
        self.eyeColor.label = "Eye Color"
        self.eyeColor.formControl = "select"
        self.eyeColor.values = LSQAPI.sharedInstance.getValues("patient", attribute: "eye_color")
        
        self.bloodType = LSQModelFieldC()
        self.bloodType.property = "blood_type"
        self.bloodType.label = "Blood Type"
        self.bloodType.formControl = "select"
        self.bloodType.values = LSQAPI.sharedInstance.getValues("patient", attribute: "blood_type")
        
        self.height = LSQModelFieldC()
        self.height.property = "height"
        self.height.label = "Height"
        self.height.dataType = "number"
        self.height.formControl = "heightpicker"
        // self.height.keyboard = UIKeyboardType.NumberPad
        // special use case since we have Ft'In" blablablablablabla
        
        self.weight = LSQModelFieldC()
        self.weight.property = "weight"
        self.weight.label = "Weight (lbs)"
        self.weight.dataType = "number"
        self.weight.keyboard = UIKeyboardType.numberPad
        
        
        self.bpSystolic = LSQModelFieldC()
        self.bpSystolic.property = "bp_systolic"
        self.bpSystolic.label = "BP Systolic"
        self.bpSystolic.dataType = "number"
        self.bpSystolic.keyboard = UIKeyboardType.numberPad
        
        self.bpDiastolic = LSQModelFieldC()
        self.bpDiastolic.property = "bp_diastolic"
        self.bpDiastolic.label = "BP Diastolic"
        self.bpDiastolic.dataType = "number"
        self.bpDiastolic.keyboard = UIKeyboardType.numberPad
        
        self.pulse = LSQModelFieldC()
        self.pulse.property = "pulse"
        self.pulse.label = "Pulse"
        self.pulse.dataType = "number"
        self.pulse.keyboard = UIKeyboardType.numberPad
        
        super.init()
    }
}

class LSQModelPatientLanguage: LSQModel {
    var code: LSQModelFieldC
    var proficiency: LSQModelFieldC
//    var patientId: Int = 0
    var recordOrder: Int = 0
    var collectionName: String = ""
    
    override init(){
        self.code = LSQModelFieldC()
        self.code.property = "language_code"
        self.code.label = "Language"
        self.code.required = true
        self.code.formControl = "select"
        self.code.values = LSQAPI.sharedInstance.getValues("language_code")
        
        self.proficiency = LSQModelFieldC()
        self.proficiency.property = "language_proficiency"
        self.proficiency.label = "Proficiency"
        self.proficiency.required = true
        self.proficiency.formControl = "select"
        self.proficiency.values = LSQAPI.sharedInstance.getValues("patient_language", attribute: "proficiency")
        
        // self.proficiency.initial = "NATIVE"
        
        super.init()
        
        self.collectionName = "patient_languages"
    }
    
    override func getDefaultJson() -> JSON {
        var json: JSON = super.getDefaultJson()
        json["record_order"].int = self.recordOrder
        // WTF SON?
        json["language_proficiency"].string = "NATIVE"
        return json
    }
    
}

class LSQModelPatientResidence: LSQModelCollectionItem {
    
    var address1: LSQModelFieldC
    var address2: LSQModelFieldC
    var city: LSQModelFieldC
    var state: LSQModelFieldC // the raw string input
    var stateSelect: LSQModelFieldC
    var zip: LSQModelFieldC
    var country: LSQModelFieldC
    var residenceType: LSQModelFieldC
    var lifesquareLocation: LSQModelFieldC
    var lifesquareLocationOther: LSQModelFieldC
    var mailingAddress: LSQModelFieldC
    
    // primary
    
    override init () {
        
        self.address1 = LSQModelFieldC()
        self.address1.property = "address_line1"
        self.address1.label = "Street Address"
        self.address1.required = true
        
        self.address2 = LSQModelFieldC()
        self.address2.property = "address_line2"
        self.address2.label = "Address 2"
        
        self.city = LSQModelFieldC()
        self.city.property = "city"
        self.city.label = "City"
        self.city.required = true
        
        self.stateSelect = LSQModelFieldC()
        self.stateSelect.property = "state_province"
        self.stateSelect.label = "State / Province"
        self.stateSelect.formControl = "select"
        self.stateSelect.required = true
        self.stateSelect.values = LSQAPI.sharedInstance.getValues("state") // currently just US son
        
        self.state = LSQModelFieldC()
        self.state.property = "state_province"
        self.state.label = "State / Province"
        self.state.required = true
        
        self.country = LSQModelFieldC()
        self.country.property = "country"
        self.country.label = "Country"
        self.country.formControl = "select"
        self.country.required = true
        self.country.values = LSQAPI.sharedInstance.getValues("country")
        // default son
        
        self.zip = LSQModelFieldC()
        self.zip.property = "postal_code"
        self.zip.label = "Postal Code"
        self.zip.required = true
        
        self.residenceType = LSQModelFieldC()
        self.residenceType.property = "residence_type"
        self.residenceType.label = "Type"
        self.residenceType.formControl = "select"
        self.residenceType.required = true
        self.residenceType.values = LSQAPI.sharedInstance.getValues("patient_residence", attribute: "residence_type")
        
        self.lifesquareLocation = LSQModelFieldC()
        self.lifesquareLocation.property = "lifesquare_location_type"
        self.lifesquareLocation.label = "LifeSticker Location"
        self.lifesquareLocation.formControl = "select"
        self.lifesquareLocation.required = true
        self.lifesquareLocation.values = LSQAPI.sharedInstance.getValues("patient_residence", attribute: "lifesquare_location_type")
        
        self.lifesquareLocationOther = LSQModelFieldC()
        self.lifesquareLocationOther.property = "lifesquare_location_other"
        self.lifesquareLocationOther.label = "Location"
        
        self.mailingAddress = LSQModelFieldC()
        self.mailingAddress.property = "mailing_address"
        self.mailingAddress.label = "Mailing Address"
        self.mailingAddress.formControl = "checkbox"
        self.mailingAddress.dataType = "boolean"
        
        
        super.init()
        
        // self.country.initial = "US" as AnyObject?
        
        self.collectionName = "patient_residences"
        
    }
    
    override func getDefaultJson() -> JSON {
        var json: JSON = super.getDefaultJson()
        // FML
        // json["country"].string = "US"
        json["residence_type"].string = "HOME"
        return json
    }
    
}

class LSQModelPatientTherapy: LSQModelCollectionItem {
    
    var medication: LSQModelFieldC
    var dose: LSQModelFieldC
    var frequency: LSQModelFieldC
    var quantity: LSQModelFieldC
    
    override init(){
        self.medication = LSQModelFieldC()
        self.medication.property = "therapy"
        self.medication.label = "Medication"
        self.medication.required = true
        self.medication.formControl = "autocomplete"
        self.medication.autocompleteId = "medication"
        
        self.dose = LSQModelFieldC()
        self.dose.property = "therapy_strength_form"
        self.dose.label = "Dose"
        self.dose.formControl = "select"
        
        self.frequency = LSQModelFieldC()
        self.frequency.property = "therapy_frequency"
        self.frequency.label = "Frequency"
        self.frequency.formControl = "select"
        self.frequency.values = LSQAPI.sharedInstance.getValues("patient_therapy", attribute: "therapy_frequency")
        
        self.quantity = LSQModelFieldC()
        self.quantity.property = "therapy_quantity"
        self.quantity.label = "Quantity"
        self.quantity.formControl = "select"
        self.quantity.values = LSQAPI.sharedInstance.getValues("patient_therapy", attribute: "therapy_quantity")
        
        super.init()
        
        self.collectionName = "patient_therapies"
    }

}

class LSQModelPatientAllergy: LSQModelCollectionItem {
 
    var allergen: LSQModelFieldC
    var reaction: LSQModelFieldC
 
    // TODO: imo_code - fill after response
    // TODO: icd9_code - fill after response
    // TODO: ic10_code just doesn't seem used ever
 
    override init() {
        self.allergen = LSQModelFieldC()
        self.allergen.property = "allergen"
        self.allergen.label = "Allergy"
        self.allergen.required = true
        self.allergen.formControl = "autocomplete"
        self.allergen.autocompleteId = "allergy"
        
        
        self.reaction = LSQModelFieldC()
        self.reaction.property = "reaction"
        self.reaction.label = "Reaction"
        self.reaction.formControl = "select"
        self.reaction.values = LSQAPI.sharedInstance.getValues("patient_allergy", attribute: "reaction")
        
        super.init()
        
        self.collectionName = "patient_allergies"
    }

}

class LSQModelPatientImmunization: LSQModelCollectionItem {
    
    var healthEvent: LSQModelFieldC
    var startDate: LSQModelFieldC
    
    override init(){
        
        self.healthEvent = LSQModelFieldC()
        self.healthEvent.required = true
        self.healthEvent.property = "health_event"
        self.healthEvent.label = "Immunization"
        self.healthEvent.formControl = "autocomplete"
        self.healthEvent.autocompleteId = "immunization"
        
        self.startDate = LSQModelFieldC()
        self.startDate.property = "start_date"
        self.startDate.label = "Date Administered"
        self.startDate.formControl = "datepicker"
        
        super.init()
        
        self.collectionName = "patient_health_events"
    }
    
    override func getDefaultJson() -> JSON {
        var json: JSON = super.getDefaultJson()
        json["start_date"].string = "" // FML OO FAILS
        json["health_event_type"].string = "IMMUNIZATION"
        return json
    }
    
}

class LSQModelPatientCondition: LSQModelCollectionItem {
    
    var healthEvent: LSQModelFieldC
    var startDate: LSQModelFieldC
    
    override init(){
        
        self.healthEvent = LSQModelFieldC()
        self.healthEvent.required = true
        self.healthEvent.property = "health_event"
        self.healthEvent.label = "Condition"
        self.healthEvent.formControl = "autocomplete"
        self.healthEvent.autocompleteId = "condition"
        
        self.startDate = LSQModelFieldC()
        self.startDate.property = "start_date"
        self.startDate.label = "Date Diagnosed"
        self.startDate.formControl = "datepicker"
        
        super.init()
        
        self.collectionName = "patient_health_events"
    }
    
    override func getDefaultJson() -> JSON {
        var json: JSON = super.getDefaultJson()
        json["start_date"].string = "" // FML OO FAILS
        json["health_event_type"].string = "CONDITION"
        return json
    }
    
}

class LSQModelPatientProcedure: LSQModelCollectionItem {
    
    var healthEvent: LSQModelFieldC
    var startDate: LSQModelFieldC
    
    override init(){
        
        self.healthEvent = LSQModelFieldC()
        self.healthEvent.required = true
        self.healthEvent.property = "health_event"
        self.healthEvent.label = "Procedure or Device"
        self.healthEvent.formControl = "autocomplete"
        self.healthEvent.autocompleteId = "procedure"
        
        self.startDate = LSQModelFieldC()
        self.startDate.property = "start_date"
        self.startDate.label = "Date Performed"
        self.startDate.formControl = "datepicker"
        
        super.init()
        
        self.collectionName = "patient_health_events"
    }
    
    override func getDefaultJson() -> JSON {
        var json: JSON = super.getDefaultJson()
        json["start_date"].string = "" // FML OO FAILS
        json["health_event_type"].string = "PROCEDURE"
        return json
    }
    
}

class LSQModelPatientContact: LSQModelCollectionItem {
    
    var firstName: LSQModelFieldC
    var lastName: LSQModelFieldC
    var relationship: LSQModelFieldC
    var phone: LSQModelFieldC
    var email: LSQModelFieldC
    var notificationPostscan: LSQModelFieldC
    var powerOfAttorney: LSQModelFieldC
    var nextOfKin: LSQModelFieldC
    
    override init(){
        
        self.firstName = LSQModelFieldC()
        self.firstName.property = "first_name"
        self.firstName.label = "First Name"
        self.firstName.required = true
        
        self.lastName = LSQModelFieldC()
        self.lastName.property = "last_name"
        self.lastName.label = "Last Name"
        self.lastName.required = true
        
        self.relationship = LSQModelFieldC()
        self.relationship.property = "contact_relationship"
        self.relationship.label = "Relationship"
        self.relationship.required = true
        self.relationship.formControl = "select"
        self.relationship.values = LSQAPI.sharedInstance.getValues("patient_contact", attribute: "relationship")
        
        self.phone = LSQModelFieldC()
        self.phone.property = "home_phone"
        self.phone.label = "Phone Number"
        self.phone.required = true
        self.phone.keyboard = UIKeyboardType.phonePad
        
        self.email = LSQModelFieldC()
        self.email.property = "email"
        self.email.label = "Email"
        
        self.notificationPostscan = LSQModelFieldC()
        self.notificationPostscan.property = "notification_postscan"
        self.notificationPostscan.label = "Notify when Scanned"
        self.notificationPostscan.formControl = "checkbox"
        self.notificationPostscan.dataType = "boolean"
        
        self.powerOfAttorney = LSQModelFieldC()
        self.powerOfAttorney.property = "power_of_attorney"
        self.powerOfAttorney.label = "Power of Attorney" // "Durable health care
        self.powerOfAttorney.formControl = "checkbox"
        self.powerOfAttorney.dataType = "boolean"
        
        self.nextOfKin = LSQModelFieldC()
        self.nextOfKin.property = "next_of_kin"
        self.nextOfKin.label = "Next of Kin"
        self.nextOfKin.formControl = "checkbox"
        self.nextOfKin.dataType = "boolean"
        
        super.init()
        
        // TODO: establish defaults son buns
        self.privacy.initial = "private" as AnyObject?
        self.notificationPostscan.initial = true as AnyObject
        
        self.collectionName = "patient_contacts"
    }
    


}

class LSQModelPatientInsurance: LSQModelCollectionItem {
    var orgName: LSQModelFieldC
    var phone: LSQModelFieldC
    var policyCode: LSQModelFieldC
    var groupCode: LSQModelFieldC
    var firstName: LSQModelFieldC
    var lastName: LSQModelFieldC
    var photoFront: LSQModelFieldC
    var photoBack: LSQModelFieldC
    
    override init(){
        
        self.orgName = LSQModelFieldC()
        self.orgName.required = true
        self.orgName.property = "organization_name"
        self.orgName.label = "Company"
        
        self.phone = LSQModelFieldC()
        self.phone.property = "phone"
        self.phone.label = "Phone Number"
        self.phone.keyboard = UIKeyboardType.phonePad
        
        self.policyCode = LSQModelFieldC()
        self.policyCode.property = "policy_code"
        self.policyCode.label = "Member ID"
        
        self.groupCode = LSQModelFieldC()
        self.groupCode.property = "group_code"
        self.groupCode.label = "Group #"
        
        self.firstName = LSQModelFieldC()
        self.firstName.property = "policyholder_first_name"
        self.firstName.label = "First Name" // Policyholder's
        
        self.lastName = LSQModelFieldC()
        self.lastName.property = "policyholder_last_name"
        self.lastName.label = "Last Name" // Policyholder's
        
        // FILE hack son
        self.photoFront = LSQModelFieldC()
        self.photoFront.property = "photo_front"
        self.photoFront.label = "Photo of Card Front"
        
        self.photoBack = LSQModelFieldC()
        self.photoBack.property = "photo_back"
        self.photoBack.label = "Photo of Card Back"

        super.init()
        
        self.collectionName = "patient_insurances"
    }
    
}

class LSQModelPatientCareProvider: LSQModelCollectionItem {
    
    var facilityName: LSQModelFieldC
    var specialization: LSQModelFieldC
    var address1: LSQModelFieldC
    var address2: LSQModelFieldC
    var city: LSQModelFieldC
    var state: LSQModelFieldC
    var stateSelect: LSQModelFieldC
    var zip: LSQModelFieldC
    var country: LSQModelFieldC
    var phone: LSQModelFieldC
    var firstName: LSQModelFieldC
    var lastName: LSQModelFieldC
    
    override init(){
        
        self.facilityName = LSQModelFieldC()
        self.facilityName.property = "medical_facility_name"
        self.facilityName.label = "Facility Name"
        
        self.specialization = LSQModelFieldC()
        self.specialization.property = "care_provider_class"
        self.specialization.label = "Specialization"
        self.specialization.formControl = "select"
        self.specialization.values = LSQAPI.sharedInstance.getValues("patient_care_provider", attribute: "care_provider_class")

        self.phone = LSQModelFieldC()
        self.phone.property = "phone1"
        self.phone.label = "Phone Number"
        self.phone.keyboard = UIKeyboardType.phonePad
        
        self.address1 = LSQModelFieldC()
        self.address1.property = "address_line1"
        self.address1.label = "Street Address"
        
        self.address2 = LSQModelFieldC()
        self.address2.property = "address_line2"
        self.address2.label = "Suite"
        
        self.city = LSQModelFieldC()
        self.city.property = "city"
        self.city.label = "City"
        
        self.stateSelect = LSQModelFieldC()
        self.stateSelect.property = "state_province"
        self.stateSelect.label = "State / Province"
        self.stateSelect.formControl = "select"
        self.stateSelect.required = false
        self.stateSelect.values = LSQAPI.sharedInstance.getValues("state") // currently just US son
        
        self.state = LSQModelFieldC()
        self.state.property = "state_province"
        self.state.label = "State / Province"
        self.state.required = false
        
        self.zip = LSQModelFieldC()
        self.zip.property = "postal_code"
        self.zip.label = "Postal Code"
        
        self.country = LSQModelFieldC()
        self.country.property = "country"
        self.country.label = "Country"
        self.country.formControl = "select"
        self.country.required = false
        self.country.values = LSQAPI.sharedInstance.getValues("country")
        
        self.firstName = LSQModelFieldC()
        self.firstName.property = "first_name"
        self.firstName.label = "First Name"
        
        self.lastName = LSQModelFieldC()
        self.lastName.property = "last_name"
        self.lastName.label = "Last Name"
        self.lastName.required = true

        
        super.init()
        
        // self.country.initial = "US" as AnyObject?
        
        self.collectionName = "patient_care_providers"
    }
    
    override func getDefaultJson() -> JSON {
        var json: JSON = super.getDefaultJson()
        // FML
        // json["country"].string = "US"
        return json
    }
}

class LSQModelPatientMedicalFacility: LSQModelCollectionItem {
 
    var name: LSQModelFieldC
    var phone: LSQModelFieldC
    var address1: LSQModelFieldC
    var city: LSQModelFieldC
    var state: LSQModelFieldC
    var stateSelect: LSQModelFieldC
    var zip: LSQModelFieldC
    var country: LSQModelFieldC
 
    override init(){
        self.name = LSQModelFieldC()
        self.name.property = "name"
        self.name.label = "Name"
        self.name.required = true
 
        self.phone = LSQModelFieldC()
        self.phone.property = "phone"
        self.phone.label = "Phone Number"
        self.phone.keyboard = UIKeyboardType.phonePad
 
        self.address1 = LSQModelFieldC()
        self.address1.property = "address_line1"
        self.address1.label = "Street Address"
 
        self.city = LSQModelFieldC()
        self.city.property = "city"
        self.city.label = "City"
        
        self.stateSelect = LSQModelFieldC()
        self.stateSelect.property = "state_province"
        self.stateSelect.label = "State / Province"
        self.stateSelect.formControl = "select"
        self.stateSelect.required = false
        self.stateSelect.values = LSQAPI.sharedInstance.getValues("state") // currently just US son
        
        self.state = LSQModelFieldC()
        self.state.property = "state_province"
        self.state.label = "State"
        self.state.required = false
        
        self.zip = LSQModelFieldC()
        self.zip.property = "postal_code"
        self.zip.label = "Postal Code"
        
        self.country = LSQModelFieldC()
        self.country.property = "country"
        self.country.label = "Country"
        self.country.formControl = "select"
        self.country.required = false
        self.country.values = LSQAPI.sharedInstance.getValues("country")
        
        super.init()
        
        //self.country.initial = "US" as AnyObject?
        self.collectionName = "patient_medical_facilities"
    }
    
    override func getDefaultJson() -> JSON {
        var json: JSON = super.getDefaultJson()
        json["medical_facility_type"].string = "HOSPITAL"
        //json["country"].string = "US"
        return json
    }
    
}

class LSQModelPatientPharmacy: LSQModelCollectionItem {
    var name: LSQModelFieldC
    var phone: LSQModelFieldC
    var address1: LSQModelFieldC
    var city: LSQModelFieldC
    var state: LSQModelFieldC
    var stateSelect: LSQModelFieldC
    var zip: LSQModelFieldC
    var country: LSQModelFieldC
    
    override init(){
        self.name = LSQModelFieldC()
        self.name.property = "name"
        self.name.label = "Name"
        self.name.required = true
        
        self.phone = LSQModelFieldC()
        self.phone.property = "phone"
        self.phone.label = "Phone Number"
        self.phone.keyboard = UIKeyboardType.phonePad
        
        self.address1 = LSQModelFieldC()
        self.address1.property = "address_line1"
        self.address1.label = "Street Address"
        
        self.city = LSQModelFieldC()
        self.city.property = "city"
        self.city.label = "City"
    
        self.stateSelect = LSQModelFieldC()
        self.stateSelect.property = "state_province"
        self.stateSelect.label = "State / Province"
        self.stateSelect.formControl = "select"
        self.stateSelect.required = false
        self.stateSelect.values = LSQAPI.sharedInstance.getValues("state") // currently just US son
        
        self.state = LSQModelFieldC()
        self.state.property = "state_province"
        self.state.label = "State / Province"
        self.state.required = false
        
        self.zip = LSQModelFieldC()
        self.zip.property = "postal_code"
        self.zip.label = "Postal Code"
        
        self.country = LSQModelFieldC()
        self.country.property = "country"
        self.country.label = "Country"
        self.country.formControl = "select"
        self.country.required = false
        self.country.values = LSQAPI.sharedInstance.getValues("country")
        
        super.init()
        
        //self.country.initial = "US" as AnyObject?
        
        self.collectionName = "patient_pharmacies"
    }
    
    override func getDefaultJson() -> JSON {
        var json: JSON = super.getDefaultJson()
        // FML
        //json["country"].string = "US"
        return json
    }
}

struct LSQModelUtils {
    // manhandling the external wonkiness of SwiftyJSON
    static func bindToJson(_ fields: [LSQModelFieldC], json: JSON, attribute: String, value: AnyObject) -> JSON {
        var data: JSON = json
        
        for field in fields {
            if field.property == attribute {
                if data[field.property].exists() {
                    if field.dataType == "string" {
                        data[field.property].string = (value as? String)!
                        break
                    }
                    if field.dataType == "number" {
                        if let value = Int(value as! String) {
                            data[field.property].int = value
                            // if we're weight son, this should be on the model field instance itself, but whatever FML
                            if field.property == "weight" {
                                data[field.property].double = LSQ.formatter.weightToMetric(value)
                            }
                        } else {
                            data[field.property] = JSON.null
                        }
                        break
                    }
                    if field.dataType == "boolean" {
                        data[field.property].bool = (value as? Bool)!
                        break
                    }
                }
                break
            }
        }
        return data
    }
    
    static func validateForm(_ fields: [LSQModelFieldC], json: JSON) -> [[String: AnyObject]] {
        // TODO: optional getters for each "type" to ensure any server data and client "model" out of sync is handled
        // TODO: if the property has already been flagged, ie, state_province try to only show the message once
        
        var errors:[[String:AnyObject]] = []
        for field in fields {
            // TODO: or we need a specific validation, aka regex on this
            // e.g. email, phone, etc, that said, those might live in respetive smart components (cell fields)
            
            // yea son buns
            var valid: Bool = true
            var message: String = ""
            
            if field.required {
                // switch on datatype son for proper comparison, until we push some of that crap back to the model field def
                // get the data attribute here as AnyObject, then cast that in side the bla
                valid = false
                message = "Value for \(field.label) is missing"
                
                if field.dataType == "string" {
                    if let val = json[field.property].string {
                        if val != "" {
                            valid = true
                        }
                    }
                }
                // integer?
                if field.dataType == "number" {
                    // YOU KNOW THIS IS STRAIGHT UP WRONG SON, because well, it is
                    if let val = json[field.property].number {
                        if val != 0 {
                            valid = true
                        }
                    }
                }
                // float?
                // hmm, this is basically only for some opt-in bs, ok
                if field.dataType == "boolean" {
                    // TODO: guard this entire statement, because FWIW, the attribute "might" be missing
                    
                    if let val = json[field.property].bool {
                        if val {
                            valid = true
                        } else {
                            message = "\(field.label) must be checked"
                        }
                    }
                }
            }
            
            // this is in non-required land, so only check if filled in
            // however, they will have been marked failed if empty and required already
            
            // quick "validation" hacks son
            if field.property.contains("email") {
                // obtain val
                if let val = json[field.property].string {
                    if val != "" && !LSQ.validator.email(val) {
                        valid = false
                        message = "Invalid email"
                    }
                }
            }
            if field.property.contains("phone") {
                if let val = json[field.property].string {
                    if val != "" && !val.isPhoneNumber {
                        valid = false
                        message = "Invalid phone number"
                    }
                }
            }
            
            // max on "numbers"
            
            // min on "numbers"
            
            if !valid {
                errors.append([
                    "field": field,
                    "message": message as AnyObject
                ])
            }
            
        }
        return errors
    }
}
