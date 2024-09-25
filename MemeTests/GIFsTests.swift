//
//  GIFsTests.swift
//  MemeTests
//
//  Created by DAO on 2024/9/23.
//

import Testing
import RxBlocking
import WebAPI
import Foundation
@testable import Meme
struct GIFsTests {
    var sut: GIFsViewModelProtocol!
    
    init () async throws {
        let mockWebService = GIFsAPIService(useMockData: true)
        sut = GIFsViewModel(webService: mockWebService)
    }
    
    @Test func testLoadFirstDataIfNeeded() async throws {
        assert(sut.loadingState == .initial)
        assert(sut.gridCollectionViewModel.numberOfItems == 0)
        
        sut.loadFirstDataIfNeeded()
        
        assert(sut.loadingState == .success)
        assert(sut.gridCollectionViewModel.numberOfItems == 10)
    }

    @Test func testFetchGifsData() async throws {
        assert(sut.loadingState == .initial)
        assert(sut.gridCollectionViewModel.numberOfItems == 0)
        
        sut.fetchGIFs()
        
        assert(sut.loadingState == .success)
        assert(sut.gridCollectionViewModel.numberOfItems == 10)
        
        let firstGridViewModel = sut.gridCollectionViewModel.gridCellViewModel(with: 0)
        let imageType = try firstGridViewModel.imageType.take(1).toBlocking().single()
        switch imageType {
        case .static:
            Issue.record("Should now be image type")
            
        case .gif(let url):
            assert(url == URL(string: "https://media.tenor.com/-qBsG1HwR4oAAAAC/cat-dance-dancing-cat.gif")!)
        }
    }
}
