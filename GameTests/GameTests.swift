//
//  GameTests.swift
//  GameTests
//
//  Created by Torben Nordtorp on 2018-03-06.
//  Copyright © 2018 Torben Nordtorp. All rights reserved.
//

import XCTest
@testable import Game

class GameTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testStructs() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let medRect = Rect(col: 3, row: 3, width: 2, height: 3)
        let smallRect = Rect(col: 3, row: 4, width: 1, height: 1)
        let smallRect2 = Rect(col: 5, row: 5, width: 1, height: 1)
        let bigRect = Rect(col: 1, row: 1, width: 4, height: 4)

        XCTAssert(medRect.contains(rect: smallRect))
        XCTAssert(bigRect.contains(rect: smallRect))
        XCTAssert(!bigRect.contains(rect: medRect))
        XCTAssert(!bigRect.contains(rect: smallRect2))
        XCTAssert(medRect.contains(pos: smallRect.toPos()))
        XCTAssert(bigRect.contains(pos: smallRect.toPos()))

        XCTAssert(bigRect.overlaps(rect: smallRect))
        XCTAssert(bigRect.overlaps(rect: medRect))
        XCTAssert(!bigRect.overlaps(rect: smallRect2))
        XCTAssert(bigRect.overlaps(rect: smallRect))
        XCTAssert(medRect.overlaps(rect: smallRect))
    }
    
    func testPathFinding() {
        let person = Person(walkCycleNamed: "guest", pos: Pos(col: 0, row: 0), type: .guest)
        
        person.generatePath()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
