//
//  Tests.swift
//  Tests
//
//  Created by Mgen on 15/12/17.
//  Copyright © 2017 Mgen. All rights reserved.
//  https://github.com/mgenware/Swift-LRUWithExpiration
//

import XCTest
@testable import LRUWithExpiration

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAdd() {
        let lru = LRUWithExpiration<String, Int>(capacity: 3)
        lru.setValue(value: 1, forKey: "k1")
        lru.setValue(value: 2, forKey: "k2")
        
        XCTAssertEqual(lru.count, 2)
        XCTAssertEqual(lru["k1"]!, 1)
        XCTAssertEqual(lru["k2"]!, 2)
        XCTAssertEqual(lru["k3"], nil)
    }
    
    func testSet() {
        let lru = LRUWithExpiration<String, Int>(capacity: 3)
        lru.setValue(value: 1, forKey: "k1")
        lru.setValue(value: 2, forKey: "k1")
        XCTAssertEqual(lru["k1"]!, 2)
    }
    
    func testRemove() {
        let lru = LRUWithExpiration<String, Int>(capacity: 3)
        lru.setValue(value: 1, forKey: "k1")
        lru.setValue(value: 2, forKey: "k2")
        
        XCTAssertEqual(lru.removeValue(forKey: "k1")!, 1)
        XCTAssertEqual(lru.count, 1)
        XCTAssertEqual(lru["k1"], nil)
        XCTAssertEqual(lru["k2"]!, 2)
    }
    
    func testRemoveAll() {
        let lru = LRUWithExpiration<String, Int>(capacity: 3)
        lru.setValue(value: 1, forKey: "k1")
        lru.setValue(value: 2, forKey: "k2")

        XCTAssertEqual(lru.count, 2)
        lru.removeAll()
        XCTAssertEqual(lru.count, 0)
    }
    
    func testOverflow() {
        let lru = LRUWithExpiration<String, Int>(capacity: 2)
        lru.setValue(value: 1, forKey: "k1")
        lru.setValue(value: 2, forKey: "k2")
        lru.setValue(value: 3, forKey: "k3")
        lru.setValue(value: 4, forKey: "k4")
        _ = lru["k3"]
        lru.setValue(value: 5, forKey: "k5")
        
        XCTAssertEqual(lru.count, 2)
        XCTAssertEqual(lru["k1"], nil)
        XCTAssertEqual(lru["k2"], nil)
        XCTAssertEqual(lru["k3"]!, 3)
        XCTAssertEqual(lru["k4"], nil)
        XCTAssertEqual(lru["k5"]!, 5)
    }
    
    func testAddWithExpiration() {
        let expect = expectation(description: "testAddWithExpiration")
        let lru = LRUWithExpiration<String, Int>(capacity: 3)
        lru.setValue(value: 1, forKey: "k1", expire: 1)
        lru.setValue(value: 2, forKey: "k2", expire: -1)
        lru.setValue(value: 3, forKey: "k3", expire: 2)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            XCTAssertEqual(lru.count, 2)
            XCTAssertEqual(lru["k1"], nil)
            XCTAssertEqual(lru["k2"]!, 2)
            XCTAssertEqual(lru["k3"]!, 3)
            
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSetWithExpiration() {
        let expect = expectation(description: "testSetWithExpiration")
        let lru = LRUWithExpiration<String, Int>(capacity: 3)
        lru.setValue(value: 1, forKey: "k1", expire: 1)
        lru.setValue(value: 2, forKey: "k1", expire: 3)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            XCTAssertEqual(lru.count, 1)
            XCTAssertEqual(lru["k1"]!, 2)
            
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testOverflowWithExpiration() {
        let expect = expectation(description: "testSetWithExpiration")
        let lru = LRUWithExpiration<String, Int>(capacity: 2)
        lru.setValue(value: 1, forKey: "k1", expire: 1)
        lru.setValue(value: 2, forKey: "k2", expire: -1)
        _ = lru["k1"]
        lru.setValue(value: -1, forKey: "k3", expire: 1)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            XCTAssertEqual(lru.count, 0)
            XCTAssertEqual(lru["k1"], nil)
            XCTAssertEqual(lru["k2"], nil)
            
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
