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
    
    private func accessContacts(completion: @escaping (Result<Void>) -> Void) {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.store.requestAccess(for: .contacts) { (granted, err) in
                let completion: (Result<Void>) -> Void = { result in
                    DispatchQueue.main.async {
                        completion(result)
                    }
                }
                
                if let err = err {
                    completion(.failure(ContactError
                        .accessFailed(errorMessage: err.localizedDescription)))
                }
                
                guard granted else {
                    completion(.failure(ContactError.accessDeniedError))
                    return
                }
                completion(.success(()))
            }
        }
    }
    
    private func fetchAllContacts(completion: @escaping (Result<[CNContact]>) -> Void)  {
        accessContacts { [weak self] (result) in
            switch result {
            case .success:
                self?.queue.async { [weak self] in
                    let keys: [CNKeyDescriptor] = [
                        CNContactGivenNameKey,
                        CNContactFamilyNameKey,
                        CNContactPhoneNumbersKey
                        ] as [CNKeyDescriptor]
                    let request = CNContactFetchRequest(keysToFetch: keys)
                    var contacts: [CNContact] = []
                    
                    let completion: (Result<[CNContact]>) -> Void = { result in
                        DispatchQueue.main.async {
                            completion(result)
                        }
                    }
                    
                    do {
                        try self?.store.enumerateContacts(with: request) { (contact, stoppingPointer) in
                            contacts.append(contact)
                        }
                    } catch {
                        completion(.failure(ContactError
                            .loadFailed(errorMessage: error.localizedDescription)))
                    }
                    completion(.success(contacts))
                }
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
    
    public func fetchNonexistentContact(existingFriends: [Friend]?,
                                        completion: @escaping (Result<[CNContact]?>) -> Void) {
        let friendsPhones = existingFriends?.map { $0.phoneNumber } ?? []
        fetchAllContacts { (result) in
            switch result {
            case .success(let contacts):
                let contacts = contacts
                    .filter { !(($0.familyName + $0.givenName).isEmpty) }
                    .filter {
                        let phone = $0.phoneNumbers.first?.value.value(forKey: "digits") as? String
                        return !friendsPhones.contains(phone?.toPhoneFormat())
                    }.sorted(by: { $0.familyName+$0.givenName < $1.familyName+$1.givenName })
                completion(.success(contacts))
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
    
    public func convertAndSaveFriend(from contact: CNContact,
                                     database manager: CoreDataManager,
                                     completion: @escaping (Result<Friend>) -> Void) {
        let phone = contact.phoneNumbers.first?.value.value(forKey: "digits") as? String
        manager.createFriend(
            name: contact.familyName + contact.givenName,
            tags: ["연락처"],
            phoneNumber: phone?.toPhoneFormat(),
            completion: completion
        )
    }
}
