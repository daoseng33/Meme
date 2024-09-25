//
//  MemeAPITests.swift
//  WebAPITests
//
//  Created by DAO on 2024/8/30.
//

import Testing
import Moya
import RxBlocking
@testable import WebAPI
struct MemeAPITests {
    var sut: MemeAPIService!
    
    init() async throws {
        sut = MemeAPIService(useMockData: true)
    }

    @Test func testFetchRandomMemeImage() throws {
        let result = try sut.fetchRandomMeme(with: "", mediaType: .image, minRating: 8).toBlocking().single()
        switch result {
        case .success(let random):
            assert(random.id == 831819)
            assert(random.type == "image/png")
            
        case .failure(_):
            break
        }
        
    }

    @Test func testFetchRandomMemeVideo() throws {
        let result = try sut.fetchRandomMeme(with: "", mediaType: .video, minRating: 8).toBlocking().single()
        switch result {
        case .success(let random):
            assert(random.id == 12142)
            assert(random.type == "video/mp4")
            
        case .failure(_):
            break
        }
    }
    
    @Test func testFetchRandomMemeFail() throws {
        let result = try sut.fetchRandomMeme(with: "Boobs", mediaType: .image, minRating: 8).toBlocking().single()
        switch result {
        case .success(_):
            break
            
        case .failure(let error):
            assert(error.code == 400)
            assert(error.status == "failure")
        }
    }
}
