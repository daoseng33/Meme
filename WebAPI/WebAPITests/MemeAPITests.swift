//
//  MemeAPITests.swift
//  WebAPITests
//
//  Created by DAO on 2024/8/30.
//

import XCTest
import Moya
import RxBlocking
@testable import WebAPI

final class MemeAPITests: XCTestCase {
    
    var sut: MemeAPIService!
    
    override func setUpWithError() throws {
        sut = MemeAPIService(useMockData: true)
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFetchRandomMemeImage() throws {
        let result = try sut.fetchRandomMeme(with: "", mediaType: .image, minRating: 8).toBlocking().single()
        switch result {
        case .success(let random):
            XCTAssertEqual(random.id, 831819)
            XCTAssertEqual(random.type, "image/png")
            
        case .failure(_):
            break
        }
        
    }

    func testFetchRandomMemeVideo() throws {
        let result = try sut.fetchRandomMeme(with: "", mediaType: .video, minRating: 8).toBlocking().single()
        switch result {
        case .success(let random):
            XCTAssertEqual(random.id, 12142)
            XCTAssertEqual(random.type, "video/mp4")
            
        case .failure(_):
            break
        }
    }
    
    func testFetchRandomMemeFail() throws {
        let result = try sut.fetchRandomMeme(with: "Boobs", mediaType: .image, minRating: 8).toBlocking().single()
        switch result {
        case .success(_):
            break
            
        case .failure(let error):
            XCTAssertEqual(error.code, 400)
            XCTAssertEqual(error.status, "failure")
        }
    }
}
