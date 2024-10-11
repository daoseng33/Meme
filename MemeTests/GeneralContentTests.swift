//
//  GeneralContentTests.swift
//  MemeTests
//
//  Created by DAO on 2024/10/10.
//

import Testing
import Foundation
import HumorAPIService
@testable import Meme
@MainActor
@Suite(.serialized)
final class GeneralContentTests {
    var sut: GeneralContentViewModelProtocol!
    
    init () async throws {
        DataStorageManager.shared.deleteAll()
    }
    
    @available(iOS 16.0, *)
    @Test func testGetLocalDatas() async throws {
        let mockMeme = RandomMeme(id: 831819,
                                  memeDescription: "Cake day: I should try asking questions. It's a good way to learn things.",
                                  urlString: "https://i.imgur.com/T537Egd.png",
                                  type: "image/png")
        DataStorageManager.shared.save(mockMeme)
        
        sut = GeneralContentViewModel()
        
        sut.getLocalDatas()
        
        // wait observable debounce in general content view model
        try await Task.sleep(for: .milliseconds(150))
        
        assert(sut.getRowsCount(with: 0) == 1)
    }

    @available(iOS 16.0, *)
    @Test func testGetFavoriteLocalDatas() async throws {
        let mockMeme = RandomMeme(id: 831819,
                                  memeDescription: "Cake day: I should try asking questions. It's a good way to learn things.",
                                  urlString: "https://i.imgur.com/T537Egd.png",
                                  type: "image/png")
        DataStorageManager.shared.save(mockMeme)
        
        let mockJoke = RandomJoke(id: 199,
                                  joke: "Can you swim? Some times. What do you mean by \"some times\"? Only when I'm in the water.",
                                  isFavorite: true)
        DataStorageManager.shared.save(mockJoke)
        
        let predicate = NSPredicate(format: "isFavorite == %@", NSNumber(value: true))
        sut = GeneralContentViewModel(predicate: predicate)
        
        sut.getLocalDatas()
        
        // wait observable debounce in general content view model
        try await Task.sleep(for: .milliseconds(150))
        
        assert(sut.getRowsCount(with: 0) == 1)
    }
}
