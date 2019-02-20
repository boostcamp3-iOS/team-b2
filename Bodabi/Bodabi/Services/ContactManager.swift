//
//  ContactManager.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 2. 18..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import Contacts
import CoreData
import Foundation

class ContactManager {
    static let shared = ContactManager()
    
    private let store = CNContactStore()
    private let queue = DispatchQueue(label: "com.teamB2.Bodabi.contact")
    
    private func accessContacts(completion: ((Bool) -> Void)?) {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.store.requestAccess(for: .contacts) { (granted, err) in
                if let err = err {
                    print(err.localizedDescription)
                    print("Access error")
                }
                
                let completion: (Bool) -> Void = { result in
                    DispatchQueue.main.async {
                        completion?(result)
                    }
                }
                
                guard granted else {
                    print("Access denied")
                    completion(false)
                    return
                }
                completion(granted)
            }
        }
    }
    
    private func fetchAllContacts(completion: (([CNContact]) -> Void)?)  {
        accessContacts { [weak self] (granted) in
            guard granted else {
                // FIXME: - Fix can's access issue
                return
            }
            
            self?.queue.async {
                let keys: [CNKeyDescriptor] = [CNContactGivenNameKey,
                                               CNContactFamilyNameKey,
                                               CNContactPhoneNumbersKey] as [CNKeyDescriptor]
                let request = CNContactFetchRequest(keysToFetch: keys)
                var contacts: [CNContact] = []
                
                do {
                    try self?.store.enumerateContacts(with: request) { (contact, stoppingPointer) in
                        contacts.append(contact)
                    }
                } catch {
                    print(error.localizedDescription)
                }
                
                DispatchQueue.main.async {
                    completion?(contacts)
                }
            }
        }
    }
    
    public func fetchNonexistentContact(existingFriends: [Friend]?,
                                        completion: (([CNContact]?) -> Void)?) {
        let friendsPhones = existingFriends?.map { $0.phoneNumber } ?? []
        fetchAllContacts { (result) in
            let contacts = result
                .filter { !(($0.familyName + $0.givenName).isEmpty) }
                .filter {
                    let phone = $0.phoneNumbers.first?.value.value(forKey: "digits") as? String
                    return !friendsPhones.contains(phone?.toPhoneFormat())
                }.sorted(by: { $0.familyName+$0.givenName < $1.familyName+$1.givenName })
            completion?(contacts)
        }
    }
    
    public func convertAndSaveFriend(from contact: CNContact,
                                     database manager: DatabaseManager,
                                     completion: @escaping (Result<Friend>) -> Void) {
        let phone = contact.phoneNumbers.first?.value .value(forKey: "digits") as? String
        manager.createFriend(
            name: contact.familyName + contact.givenName,
            tags: ["연락처"],
            phoneNumber: phone?.toPhoneFormat(),
            completion: completion
        )
    }
}
