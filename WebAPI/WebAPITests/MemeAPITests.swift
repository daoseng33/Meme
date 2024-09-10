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
    
    let sut: MemeAPIService = {
        var sut = MemeAPIService()
        sut.provider = MoyaProvider<MemeAPI>.stub
        
        return sut
    }()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFetchRandomMemeImage() throws {
        let random = try sut.fetchRandomMeme(with: "", mediaType: .image, minRating: 8).toBlocking().single()
        XCTAssertEqual(random.id, 831819)
        XCTAssertEqual(random.type, "image/png")
    }

    func testFetchRandomMemeVideo() throws {
        let random = try sut.fetchRandomMeme(with: "", mediaType: .video, minRating: 8).toBlocking().single()
        XCTAssertEqual(random.id, 12142)
        XCTAssertEqual(random.type, "video/mp4")
    }
}
