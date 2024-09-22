//
//  GIFsAPITests.swift
//  WebAPITests
//
//  Created by DAO on 2024/9/22.
//

import Testing
import RxBlocking
@testable import WebAPI
struct GIFsAPITests {

    let sut: GIFsAPIServiceProtocol!
    
    init() async throws {
        self.sut = GIFsAPIService()
    }
    
    @Test func testFetchGifs() async throws {
        let gifs = try sut.fetchGifs(query: "", number: 10).toBlocking().single()
        let images = gifs.images
        
        assert(images.count == 10)
        assert(images.first?.url == URL(string: "https://media.tenor.com/-qBsG1HwR4oAAAAC/cat-dance-dancing-cat.gif"))
        assert(images.last?.url == URL(string: "https://media.tenor.com/6yMqezH9zcIAAAAC/cat-dance-dance-cat.gif"))
    }

}
