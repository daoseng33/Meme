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
    
    @Test func testLoadFirstDataIfNeeded() async throws {
        assert(sut.loadingState == .initial)
        
        let initialJoke = try sut.joke.take(1).toBlocking().last()
        assert(initialJoke == "")
        
        sut.loadFirstMemeIfNeeded()
        assert(sut.loadingState == .success)
        
        let loadedJoke = try sut.joke.take(1).toBlocking().last()
        assert(loadedJoke == "Can you swim? Some times. What do you mean by \"some times\"? Only when I'm in the water.")
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
    
    @Test func testJokeCategories() async throws {
        assert(sut.categories == JokeCategory.allCases.map { $0.rawValue })
    }
    
    @Test func testSelectedJokeCategory() async throws {
        // initial value
        assert(sut.selectedCategory == .Random)
        
        sut.selectedCategoryObserver.onNext("Clean")
        
        assert(sut.selectedCategory == .Clean)
    }
}
