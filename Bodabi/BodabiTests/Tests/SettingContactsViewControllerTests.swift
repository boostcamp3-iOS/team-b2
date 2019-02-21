//
//  SettingContactsViewControllerTests.swift
//  BodabiTests
//
//  Created by 이혜진 on 2019. 2. 21..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

@testable import Bodabi
import XCTest

class SettingContactsViewControllerTests: XCTestCase {
    
    var mockCoreDataManager = MockCoreDataManager()

    override func setUp() {

        continueAfterFailure = false
        XCUIApplication().launch()

    }


    func testContactLoad() {
        // given
        let storyboard = UIStoryboard(name: "Setting", bundle: nil)
        let viewController = storyboard.instantiateViewController(ofType: SettingContactsViewController.self)
//        viewController.setDatabaseManager(mockCoreDataManager as! CoreDataManager)
        
        // when
        let dummyContacts = DummyContacts.dummyContacts
//        viewController.saveContacts(contacts: dummyContacts)
        
        
        dummyContacts.forEach { (contact) in
            ContactManager.shared.convertAndSaveFriend(
                from: contact,
                database: mockCoreDataManager
            ) { (result) in
                switch result {
                case .failure(let error):
                    XCTAssertNil(error, "error!!!!!!!!!!!!!")
                case .success(let friend):
                    XCTAssertNil(friend.name , "nameerror!!!!!!!!!!!!!")
                    XCTAssertNil(friend.tags, "tagerror!!!!!!!!!!!!!")
                    XCTAssertNil(friend.phoneNumber, "phoneerror!!!!!!!!!!!!!")
                    let info: FriendType = (friend.name!, friend.tags!, friend.phoneNumber!)
                    let friends = MockCoreDataManager.tuples
                    let count = friends.filter { (friend) -> Bool in
                        return friend.name == info.name &&
                            friend.tags == info.tags &&
                            friend.phone == info.phone
                    }.count
                    XCTAssert(count == 1)
                }
            }
        }
        
        
    }

}
