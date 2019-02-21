//
//  DummyContacts.swift
//  BodabiTests
//
//  Created by 이혜진 on 2019. 2. 21..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import Foundation
import Contacts

struct DummyContacts {
    
    static let dummyContacts: [CNContact] = makeContacts(info: contacts)
    
    static func makeContacts(info: [(given: String, family: String, phone: String)]) -> [CNContact] {
        return info.map { (info) in
            let contact = CNMutableContact()
            contact.givenName = info.given
            contact.familyName = info.family
            
            contact.phoneNumbers = [CNLabeledValue(
                label:CNLabelPhoneNumberiPhone,
                value:CNPhoneNumber(stringValue: info.phone))]
            
            return contact as CNContact
        }
    }
    
    static let contacts = [
        ("재현", "이", "010-7929-9390"),
        ("혜진", "이", "(010)3434-1244"),
        ("동환", "김", "01027489487"),
        ("힘찬나래", "김", "010-12345-345"),
        ("Amy", "정", "+8210-79299-39"),
        ("하늘", "김", "010-4043-119"),
        ("", "", "0100"),
        ("sahjklf", "fdjh", "010-7929-9390"),
        ("동환", "김", "01027489487")
    ]
}
