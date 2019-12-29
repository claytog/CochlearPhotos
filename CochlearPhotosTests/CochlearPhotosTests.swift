//
//  CochlearPhotosTests.swift
//  CochlearPhotosTests
//
//  Created by Clayton on 29/12/19.
//  Copyright © 2019 Nomad Agency. All rights reserved.
//

import XCTest
@testable import CochlearPhotos

class CochlearPhotosTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    /// Test distance less than 1 km returns text with unit as "m" and does not contain a decimal
    func testDistanceLessThan1Km() {
        
        let distanceInMetres: Double = 100
        
        let distanceString = Util.distanceToString(distanceInMetres)
        
        let componentArray = distanceString.components(separatedBy: " ")
        let upperIndex = componentArray.endIndex - 1
        let unitComponent = componentArray[upperIndex]
        let distanceComponent = componentArray[0]
        
        XCTAssertTrue(unitComponent == Util.DistanceUnit.m.rawValue && !distanceComponent.contains("."))
    }
    
    /// Test distance equal to 1 km returns text with unit as "km"
    func testDistanceEqualTo1Km() {
        
        let distanceInMetres: Double = 1000
        
        let distanceString = Util.distanceToString(distanceInMetres)
        
        let componentArray = distanceString.components(separatedBy: " ")
        let upperIndex = componentArray.endIndex - 1
        let unitComponent = componentArray[upperIndex]
        
        XCTAssertTrue(unitComponent == Util.DistanceUnit.km.rawValue)
    }
    
    /// Test distance greater than 1 km returns text with unit as "km"
    func testDistanceGreaterThan1Km() {
        
        let distanceInMetres: Double = 2000
        
        let distanceString = Util.distanceToString(distanceInMetres)
        
        let componentArray = distanceString.components(separatedBy: " ")
        let upperIndex = componentArray.endIndex - 1
        let unitComponent = componentArray[upperIndex]
        
        XCTAssertTrue(unitComponent == Util.DistanceUnit.km.rawValue)
    }
    
    /// Test distance between 1km and 10km returns one decimal place
    func testDistanceBetween1kmAnd10Km() {
       
       let distanceInMetres: Double = 1234
       
       let distanceString = Util.distanceToString(distanceInMetres)
       
       let componentArray = distanceString.components(separatedBy: " ")
       let lowerIndex = 0
       let distanceComponent = componentArray[lowerIndex]
       
       let decimalArray = distanceComponent.components(separatedBy: ".")
       let upperIndex =  decimalArray.endIndex - 1
       
       let decimalComponent:String = decimalArray[upperIndex]
       
       XCTAssertTrue(distanceComponent.contains(".") && decimalComponent.count == 1)
    }
    
    /// Test distance greater than 10 km returns distance with no decimal place
    func testDistanceGreaterThan10Km() {
        
        let distanceInMetres: Double = 12345
        
        let distanceString = Util.distanceToString(distanceInMetres)
        
        let componentArray = distanceString.components(separatedBy: " ")
        let lowerIndex = 0
        let distanceComponent = componentArray[lowerIndex]
        
        XCTAssertTrue(!distanceComponent.contains("."))
    }
   
    /*
    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
     */

}
