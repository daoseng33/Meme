//
//  GIFsViewModel.swift
//  Meme
//
//  Created by DAO on 2024/9/22.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa
import HumorAPIService

final class GIFsViewModel: GIFsViewModelProtocol {
    // MARK: - Properties
    private let loadingStateRelay = BehaviorRelay<LoadingState>(value: .initial)
    private let webService: GIFsAPIServiceProtocol
    private let disposeBag = DisposeBag()
    let inAppReviewHandler = InAppReviewHandler()
    
    let adFullPageHandler: AdFullPageHandler = AdFullPageHandler()
    var imageDatas: [ImageData] = []
    let keywordRelay = BehaviorRelay<String?>(value: nil)
    let gridCollectionViewModel: GridCollectionViewModelProtocol = GridCollectionViewModel(gridDatas: [])
    
    var loadingState: LoadingState {
        loadingStateRelay.value
    }
    
    var loadingStateDriver: Driver<LoadingState> {
        loadingStateRelay.asDriver()
    }
    
    // MARK: - Init
    init(webService: GIFsAPIServiceProtocol) {
        self.webService = webService
        
        setupObservables()
    }
    
    // MARK: - Setup
    private func setupObservables() {
        gridCollectionViewModel
            .favoriteButtonTappedRelay
            .withUnretained(self)
            .subscribe(onNext: { (self, favoriteData) in
                DispatchQueue.main.async {
                    switch favoriteData.gridImageType {
                    case .static:
                        break
                        
                    case .gif(let url):
                        let imageData = ImageData(urlString: url.absoluteString, isFavorite: favoriteData.isFavorite)
                        DataStorageManager.shared.saveAsync(imageData)
                        
                        if var section = self.gridCollectionViewModel.sectionsRelay.value.first {
                            var gridData = section.items[favoriteData.index]
                            gridData.isFavorite = favoriteData.isFavorite
                            section.items[favoriteData.index] = gridData
                            self.gridCollectionViewModel.sectionsRelay.accept([section])
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - data handler
    func refreshData() {
        if loadingState == .initial {
            fetchData()
        } else {
            Task {
                let gridDatas = await self.updateGridDatas(with: imageDatas)
                let sections = [GridSection(items: gridDatas)]
                self.gridCollectionViewModel.sectionsRelay.accept(sections)
            }
        }
    }
    
    func fetchData() {
        loadingStateRelay.accept(.loading)
        
        adFullPageHandler.increaseRequestCount()
        
        // !query could not be empty string!
        let query: String
        if let keywordString = keywordRelay.value, !keywordString.isEmpty {
            query = keywordString
        } else {
            query = randomWord()
        }
        
        webService.fetchGifs(query: query, number: 10)
            .subscribe(onSuccess: { [weak self] result in
                guard let self else { return }
                
                switch result {
                case .success(let gif):
                    self.imageDatas = gif.images
                    Task {
                        let gridDatas = await self.updateGridDatas(with: gif.images)
                        let sections = [GridSection(items: gridDatas)]
                        self.gridCollectionViewModel.sectionsRelay.accept(sections)
                        self.loadingStateRelay.accept(.success)
                        
                        self.inAppReviewHandler.increaseGenerateContentCount()
                    }
                    
                case .failure(let error):
                    self.loadingStateRelay.accept(.failure(error: NSError(domain: error.message, code: error.code)))
                }
               
            }, onFailure: { [weak self] error in
                guard let self = self else { return }
                self.loadingStateRelay.accept(.failure(error: error))
            })
            .disposed(by: disposeBag)
    }
    
    private func updateGridDatas(with imageDatas: [ImageData]) async -> [GridData] {
        await MainActor.run {
            var gridDatas: [GridData] = []
            for imageData in imageDatas {
                if let localData = DataStorageManager.shared.fetch(ImageData.self, primaryKey: imageData.urlString),
                    let url = imageData.url {
                    let gridData = GridData(title: nil, imageType: .gif(url: url), isFavorite: localData.isFavorite)
                    gridDatas.append(gridData)
                } else if let url = imageData.url {
                    let gridData = GridData(title: nil, imageType: .gif(url: url))
                    gridDatas.append(gridData)
                }
            }
            
            return gridDatas
        }
    }
    
    func getImageType(with index: Int) -> GridImageType {
        let cellViewModel = gridCollectionViewModel.gridCellViewModel(with: index)
        return cellViewModel.currentImageType
    }
    
    private func randomWord() -> String {
        let consonants = "bcdfghjklmnpqrstvwxyz"
        let vowels = "aeiou"
        let length = Int.random(in: 3...8)
        var word = ""
        
        for i in 0..<length {
            if i % 2 == 0 {
                word += String(consonants.randomElement()!)
            } else {
                word += String(vowels.randomElement()!)
            }
        }
        
        return word
    }
    
    func saveSelectedImageData(with index: Int) {
        guard self.imageDatas.count > index else { return }
        
        DispatchQueue.main.async {
            let imageData = self.imageDatas[index]
            
            if DataStorageManager.shared.fetch(ImageData.self, primaryKey: imageData.urlString) == nil {
                DataStorageManager.shared.saveAsync(imageData)
            }
        }
    }
}
