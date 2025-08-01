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
        
        sut.refreshData()
        assert(sut.media.mediaURL != nil)
    }
    
    func testFetchRandomMeme() throws {
        assert(sut.media.mediaURL == nil)
        
        sut.fetchData()
        
        assert(sut.media.mediaURL != nil)
    }
    
    func testFetchRandomMemeWithValidKeyword() throws {
        sut.keywordSubject.send("your mom")
        sut.fetchData()
        
        assert(sut.description == "When you’re walking past the aisles at Walmart and finally see your mom")
    }
    
    func testFetchRandomMemeWithInvalidKeyword() throws {
        sut.keywordSubject.send("Boobs")
        sut.fetchData()
        
        assert(sut.description == "Could not find a meme with the given keywords.")
    }
}
