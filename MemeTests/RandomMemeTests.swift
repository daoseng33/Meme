//
//  RandomMemeTests.swift
//  MemeTests
//
//  Created by DAO on 2024/8/30.
//

import XCTest
import WebAPI
import RxBlocking
@testable import Meme

final class RandomMemeTests: XCTestCase {
    
    var sut: RandomMemeViewModelProtocol!
    
    override func setUpWithError() throws {
        let webService = MemeAPIService(useMockData: true)
        sut = RandomMemeViewModel(webService: webService)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLoadInitialData() throws {
        let initialMediaURL = try sut.media.take(1).toBlocking().single().mediaURL
        XCTAssertNil(initialMediaURL)
        
        sut.loadFirstMemeIfNeeded()
        let mediaURL = try sut.media.take(1).toBlocking().single().mediaURL
        XCTAssertNotNil(mediaURL)
    }
    
    func testFetchRandomMeme() throws {
        let initialMediaURL = try sut.media.take(1).toBlocking().single().mediaURL
        XCTAssertNil(initialMediaURL)
        
        sut.fetchRandomMeme()
        let mediaURL = try sut.media.take(1).toBlocking().single().mediaURL
        XCTAssertNotNil(mediaURL)
    }
    
    func testFetchRandomMemeWithValidKeyword() throws {
        sut.keywordObserver.onNext("your mom")
        sut.fetchRandomMeme()
        let description = try sut.description.take(1).toBlocking().last()
        XCTAssertEqual(description, "When you’re walking past the aisles at Walmart and finally see your mom")
    }
    
    func testFetchRandomMemeWithInvalidKeyword() throws {
        sut.keywordObserver.onNext("Boobs")
        sut.fetchRandomMeme()
        let description = try sut.description.take(1).toBlocking().last()
        XCTAssertEqual(description, "Could not find a meme with the given keywords.")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
