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
    
    @available(iOS 16.0, *)
    init () async throws {
        DataStorageManager.shared.deleteAll()
        try await Task.sleep(for: .milliseconds(100))
    }
    
    deinit {
        DispatchQueue.main.async {
            DataStorageManager.shared.deleteAll()
        }
    }
    
    @available(iOS 16.0, *)
    @Test func testGetLocalDatas() async throws {
        sut = GeneralContentViewModel()
        
        let mockMeme = RandomMeme(id: 831819,
                                  memeDescription: "Cake day: I should try asking questions. It's a good way to learn things.",
                                  urlString: "https://i.imgur.com/T537Egd.png",
                                  type: "image/png")
        DataStorageManager.shared.save(mockMeme)
        try await Task.sleep(for: .milliseconds(100))
        
        sut.getLocalDatas()
        try await Task.sleep(for: .milliseconds(100))
        
        assert(sut.getRowsCount(with: 0) == 1)
    }

    @available(iOS 16.0, *)
    @Test func testGetFavoriteLocalDatas() async throws {
        let predicate = NSPredicate(format: "isFavorite == %@", NSNumber(value: true))
        sut = GeneralContentViewModel(predicate: predicate)
        
        let mockMeme = RandomMeme(id: 831819,
                                  memeDescription: "Cake day: I should try asking questions. It's a good way to learn things.",
                                  urlString: "https://i.imgur.com/T537Egd.png",
                                  type: "image/png")
        DataStorageManager.shared.save(mockMeme)
        try await Task.sleep(for: .milliseconds(100))
        
        let mockJoke = RandomJoke(id: 199,
                                  joke: "Can you swim? Some times. What do you mean by \"some times\"? Only when I'm in the water.",
                                  isFavorite: true)
        DataStorageManager.shared.save(mockJoke)
        try await Task.sleep(for: .milliseconds(100))
        
        sut.getLocalDatas()
        try await Task.sleep(for: .milliseconds(100))
        
        print(sut.getRowsCount(with: 0))
        assert(sut.getRowsCount(with: 0) == 1)
    }
}
