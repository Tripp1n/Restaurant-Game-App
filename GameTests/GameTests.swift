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
    
    func testPathFinding() {
        //let person = Person(walkCycleNamed: "guest", pos: Pos(col: 0, row: 0), type: .guest)
        
        //person.generatePath()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testRectFunctions() {
        /*
         r
         5  ---141--
         4  777141--
         3  --2113--
         2  -55--66-
         1  -55-----
         0  --2-----
         
         01234567 --> c
         
         XCTAssertEqual(rect3.getOverlappingEdges(of: rect1), [.east, .north])
         */
        
        let room  = Rect(blc: 0, blr: 0, nc: 8, nr: 6)
        let rect1 = Rect(blc: 3, blr: 3, nc: 3, nr: 3)
        let rect2 = Rect(blc: 2, blr: 0, nc: 1, nr: 4)
        let rect3 = Rect(blc: 5, blr: 3, nc: 1, nr: 1)
        let rect4 = Rect(blc: 4, blr: 4, nc: 1, nr: 2)
        let rect5 = Rect(blc: 1, blr: 1, nc: 2, nr: 2)
        let rect6 = Rect(blc: 5, blr: 2, nc: 2, nr: 1)
        let rect7 = Rect(blc: 0, blr: 4, nc: 3, nr: 1)
        
        XCTAssert(rect1.contains(rect4))
        XCTAssert(rect1.contains(rect3))
        XCTAssert(!rect1.contains(rect2))
        XCTAssert(rect1.contains(rect1))
        XCTAssert(!rect4.contains(rect1))
        XCTAssert(!rect3.contains(rect1))
        XCTAssert(!rect1.contains(rect2))
        XCTAssert(!rect5.contains(rect2))
        XCTAssert(!rect2.contains(rect5))
        
        XCTAssertEqual(rect1.isNextTo(rect2), Dir.east)
        XCTAssertEqual(rect2.isNextTo(rect1), Dir.west)
        XCTAssertEqual(rect3.isNextTo(rect6), Dir.north)
        XCTAssertEqual(rect2.isNextTo(rect7), Dir.south)
        XCTAssert(rect1.isNextTo(rect3) == nil)
        XCTAssert(rect1.isNextTo(rect4) == nil)
        XCTAssert(rect1.isNextTo(rect5) == nil)
        XCTAssert(rect2.isNextTo(rect5) == nil)
        
        XCTAssert(rect1.overlaps(rect1))
        XCTAssert(rect1.overlaps(rect3))
        XCTAssert(!rect1.overlaps(rect2))
        XCTAssert(rect2.overlaps(rect5))
        
        XCTAssertEqual(rect1.getOverlappingEdges(in: rect2), [])
        XCTAssertEqual(rect1.getOverlappingEdges(in: room),  Set<Dir?>([.north]))
        XCTAssertEqual(rect5.getOverlappingEdges(in: rect2), Set<Dir?>([.east, .west]))
        XCTAssertEqual(rect3.getOverlappingEdges(in: rect1), Set<Dir?>([.east, .south]))
        XCTAssertEqual(room.getOverlappingEdges(in: room),   Set<Dir?>([.east, .west, .south, .north]))
    }
}
