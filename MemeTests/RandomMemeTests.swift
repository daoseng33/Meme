//
//  RandomMemeTests.swift
//  MemeTests
//
//  Created by DAO on 2024/8/30.
//

import Testing
import HumorAPIService
import RxBlocking
@testable import Meme
struct RandomMemeTests {
    var sut: RandomMemeViewModelProtocol!
    
    init () async throws {
        let webService = MemeAPIService(useMockData: true)
        sut = RandomMemeViewModel(webService: webService)
    }

    @Test func testLoadInitialData() async throws {
        assert(sut.media.mediaURL == nil)
        
        sut.loadFirstMemeIfNeeded()
        assert(sut.media.mediaURL != nil)
    }
    
    func testFetchRandomMeme() throws {
        assert(sut.media.mediaURL == nil)
        
        sut.fetchRandomMeme()
        
        assert(sut.media.mediaURL != nil)
    }
    
    func testFetchRandomMemeWithValidKeyword() throws {
        sut.keywordRelay.accept("your mom")
        sut.fetchRandomMeme()
        
        assert(sut.description == "When you’re walking past the aisles at Walmart and finally see your mom")
    }
    
    func testFetchRandomMemeWithInvalidKeyword() throws {
        sut.keywordRelay.accept("Boobs")
        sut.fetchRandomMeme()
        
        assert(sut.description == "Could not find a meme with the given keywords.")
    }
}
