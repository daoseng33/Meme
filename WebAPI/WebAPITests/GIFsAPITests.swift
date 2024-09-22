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
        self.sut = GIFsAPIService(useMockData: true)
    }
    
    @Test func testFetchGifs() async throws {
        let result = try sut.fetchGifs(query: "meme", number: 10).toBlocking().single()
        switch result {
            
        case .success(let gif):
            let images = gif.images
            assert(images.count == 10)
            assert(images.first?.url == URL(string: "https://media.tenor.com/-qBsG1HwR4oAAAAC/cat-dance-dancing-cat.gif"))
            assert(images.last?.url == URL(string: "https://media.tenor.com/6yMqezH9zcIAAAAC/cat-dance-dance-cat.gif"))
            
        case .failure(_):
            Issue.record("Test should be success")
        }
    }
    
    @Test func testFetchGIFsFailure() async throws {
        let result = try sut.fetchGifs(query: "", number: 10).toBlocking().single()
        switch result {
        case .success:
            Issue.record("Test should be failure")
            
        case .failure(let error):
            assert(error.code == 400)
            assert(error.message == "The parameter 'query' must be given.")
        }
    }

}
