//
//  ContactManager.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 2. 18..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import Contacts
import Foundation

class ContactManager {
    static let shared = ContactManager()
    
    private let store = CNContactStore()
    private let queue = DispatchQueue(label: "com.teamB2.Bodabi.contact")
    
    public func accessContacts(completion: ((Bool) -> Void)?) {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.store.requestAccess(for: .contacts) { (granted, err) in
                if let err = err {
                    print(err.localizedDescription)
                }
                
                guard granted else {
                    print("Access denied")
                    completion?(false)
                    return
                }
                DispatchQueue.main.async {
                    completion?(granted)
                }
            }
        }
    }
    
    public func fetchAllContacts() -> [CNContact] {
        let keys: [CNKeyDescriptor] = [CNContactGivenNameKey,
                                       CNContactFamilyNameKey,
                                       CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys)
        var contacts: [CNContact] = []
        
        do {
            try store.enumerateContacts(with: request) { (contact, stoppingPointer) in
                contacts.append(contact)
            }
        } catch {
            print(error.localizedDescription)
        }
        return contacts
    }
    
}
