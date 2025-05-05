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
    
    override func setUp() {
        super.setUp()
        locationManager = LocationManager()
    }
    
    func testValidRequestWithImage() {
        let expectation = self.expectation(description: "Test valid async network request with image")
        let viewModel = ViewModel(locationManager: locationManager)
        
        viewModel.image = Image("TestOyster")
        Task {
            await viewModel.requestInfo(completion: {
                expectation.fulfill()
            })
        }
        
        waitForExpectations(timeout: 30)
        
        let response = viewModel.response?.content.lowercased() ?? ""
        
        XCTAssertTrue(response.contains("characteristics"))
        XCTAssertTrue(response.contains("oyster"))
        
        viewModel.cancellables.first?.cancel()
    }
    
    func testInvalidRequestWithoutImage() {
        let expectation = self.expectation(description: "Test valid async network request with image")
        let viewModel = ViewModel(locationManager: locationManager)
        
        // viewModel.image = nil
        Task {
            await viewModel.requestInfo(completion: {
                expectation.fulfill()
            })
        }
        
        waitForExpectations(timeout: 30)
        
        XCTAssertNil(viewModel.response)
        
        viewModel.cancellables.first?.cancel()
    }
}
