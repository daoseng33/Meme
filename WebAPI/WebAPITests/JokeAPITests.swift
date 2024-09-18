//
//  JokeAPITests.swift
//  WebAPITests
//
//  Created by DAO on 2024/9/18.
//

import Testing
import RxBlocking
@testable import WebAPI

struct JokeAPITests {
    var sut: JokeAPIServiceProtocol!
    
    init() async throws {
        sut = JokeAPIService(useMockData: true)
    }
    
    @Test func testFetchRandomJoke() async throws {
        let result = try sut.fetchRandomJoke(tags: "", excludedTags: "", minRating: 8, maxLength: 999).toBlocking().single()
        
        switch result {
        case .success(let joke):
            #expect(joke.id == 199)
            
        case .failure:
            Issue.record("Should be success")
        }
    }
    
    @Test func testFetchRandomJokeWithNoResult() async throws {
        let result = try sut.fetchRandomJoke(tags: "cats", excludedTags: "", minRating: 8, maxLength: 999).toBlocking().single()
        
        switch result {
        case .success:
            Issue.record("Should be failure")
            
        case .failure(let error):
            #expect(error.code == 400)
            #expect(error.message == "Joke tag 'cat' does not exist.")
        }
    }

}
