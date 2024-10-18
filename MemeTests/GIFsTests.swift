//
//  GIFsTests.swift
//  MemeTests
//
//  Created by DAO on 2024/9/23.
//

import Testing
import RxBlocking
import HumorAPIService
import Foundation
@testable import Meme
struct GIFsTests {
    var sut: GIFsViewModelProtocol!
    
    init () async throws {
        let mockWebService = GIFsAPIService(useMockData: true)
        sut = GIFsViewModel(webService: mockWebService)
    }
    
    @available(iOS 16.0, *)
    @Test func testLoadFirstDataIfNeeded() async throws {
        assert(sut.loadingState == .initial)
        assert(sut.gridCollectionViewModel.numberOfItems == 0)
        
        sut.refreshData()
        
        try await Task.sleep(for: .milliseconds(300))
        
        assert(sut.loadingState == .success)
        assert(sut.gridCollectionViewModel.numberOfItems == 10)
    }
    
    @available(iOS 16.0, *)
    @Test func testFetchGifsData() async throws {
        assert(sut.loadingState == .initial)
        assert(sut.gridCollectionViewModel.numberOfItems == 0)
        
        sut.fetchData()
        
        try await Task.sleep(for: .milliseconds(300))
        
        assert(sut.loadingState == .success)
        assert(sut.gridCollectionViewModel.numberOfItems == 10)
        
        let firstGridViewModel = sut.gridCollectionViewModel.gridCellViewModel(with: 0)
        let imageType = try firstGridViewModel.imageTypeObservable.take(1).toBlocking().single()
        switch imageType {
        case .static:
            Issue.record("Should now be image type")
            
        case .gif(let url):
            assert(url == URL(string: "https://media.tenor.com/-qBsG1HwR4oAAAAC/cat-dance-dancing-cat.gif")!)
        }
    }
}
