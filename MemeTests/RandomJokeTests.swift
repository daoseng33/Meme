//
//  RandomJokeTests.swift
//  MemeTests
//
//  Created by DAO on 2024/9/18.
//

import Testing
import WebAPI
@testable import Meme
struct RandomJokeTests {

    var sut: RandomJokeViewModelProtocol!
    
    init () async throws {
        let mockWebService = JokeAPIService(useMockData: true)
        sut = RandomJokeViewModel(webService: mockWebService)
    }
    
    @Test func testFetchRandomJoke() async throws {
        assert(sut.loadingState == .initial)
        
        let initialJoke = try sut.joke.take(1).toBlocking().last()
        assert(initialJoke == "")
        
        sut.fetchRandomJoke()
        assert(sut.loadingState == .success)
        
        let loadedJoke = try sut.joke.take(1).toBlocking().last()
        assert(loadedJoke == "Can you swim? Some times. What do you mean by \"some times\"? Only when I'm in the water.")
    }
}
