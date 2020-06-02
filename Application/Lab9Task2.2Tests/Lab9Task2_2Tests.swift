//
//  Lab9Task2_2Tests.swift
//  Lab9Task2.2Tests
//
//  Created by Alex on 02.06.2020.
//  Copyright © 2020 Alex. All rights reserved.
//

import XCTest
import CoreLocation

class Lab9Task2_2Tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

    func test1()
    {
        let vc = ViewController()
        XCTAssertEqual(vc.myInitLocation.latitude, 32.7767, "Valid latitude")
        XCTAssertEqual(vc.myInitLocation.longitude, -96.7970, "Valid longitude")
    }

}

