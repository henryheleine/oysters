//
//  OystersTests.swift
//  OystersTests
//
//  Created by Henry Heleine on 2/20/25.
//

import Combine
import SwiftUICore
import Testing
import XCTest

class OystersTests: XCTestCase {
    private var locationManager: LocationManager!
    private var oysterUpdateDidFire = false
    
    override func setUp() {
        super.setUp()
        locationManager = LocationManager()
        NotificationCenter.default.addObserver(self, selector: #selector(oysterUpdate), name: NSNotification.oysterUpdate, object: nil)
    }
    
    func testValidRequestWithImage() {
        let expectation = self.expectation(description: "Test valid async network request with image")
        let viewModel = ViewModel(locationManager: locationManager)
        
        viewModel.image = Image("TestOyster")
        Task {
            await viewModel.fetchStream { result in
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 30)
        
        XCTAssertTrue(oysterUpdateDidFire)
    }
    
    func testInvalidRequestWithoutImage() {
        let expectation = self.expectation(description: "Test valid async network request with image")
        let viewModel = ViewModel(locationManager: locationManager)
        // viewModel.image = nil
        Task {
            await viewModel.fetchStream { result in
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 30)
        
        XCTAssertNil(viewModel.response)
        XCTAssertFalse(oysterUpdateDidFire)
    }
    
    func oysterUpdate() {
        oysterUpdateDidFire = true
    }
}
