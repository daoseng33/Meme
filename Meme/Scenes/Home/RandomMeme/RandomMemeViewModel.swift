//
//  RandomMemeViewModel.swift
//  Meme
//
//  Created by DAO on 2024/9/10.
//

import Foundation
import HumorAPIService
import RxRelay
import RxCocoa
import RxSwift
import Combine

final class RandomMemeViewModel: RandomMemeViewModelProtocol {
    // MARK: - Properties
    let adFullPageHandler: AdFullPageHandler = AdFullPageHandler()
    let inAppReviewHandler: InAppReviewHandler = InAppReviewHandler()
    
    var descriptionPublisher: AnyPublisher<String, Never> {
        descriptionSubscribe.eraseToAnyPublisher()
    }
    
    var loadingState: LoadingState {
        return loadingStateRelay.value
    }
    
    var loadingStateDriver: Driver<LoadingState> {
        return loadingStateRelay.asDriver()
    }
    
    var mediaPublisher: AnyPublisher<(mediaURL: URL?, type: MemeMediaType), Never> {
        mediaSubject.filter { $0.mediaURL != nil }.eraseToAnyPublisher()
    }
    
    var media: (mediaURL: URL?, type: MemeMediaType) {
        mediaSubject.value
    }
    
    var description: String {
        descriptionSubscribe.value
    }
    
    let keywordSubject = CurrentValueSubject<String?, Never>(nil)
    
    let isFavoriteRelay = BehaviorRelay<Bool>(value: false)
    let shareButtonTappedSubject = PassthroughSubject<Void, Never>()
    
    private var randomMediaType: MemeMediaType {
        return MemeMediaType.allCases.randomElement() ?? .image
    }
    private let randomMemeWebAPI: MemeAPIServiceProtocol
    private let mediaSubject = CurrentValueSubject<(mediaURL: URL?, type: MemeMediaType), Never>((nil, .image))
    private let loadingStateRelay = BehaviorRelay<LoadingState>(value: .initial)
    private let disposeBag = DisposeBag()
    private var currentMeme: RandomMeme?
    private let remoteConfigHandler = RemoteConfigHandler()
    private let descriptionSubscribe = CurrentValueSubject<String, Never>("")
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(webService: MemeAPIServiceProtocol) {
        randomMemeWebAPI = webService
        setupObservable()
    }
    
    // MARK: - Get data
    func refreshData() {
        if loadingState == .initial {
            fetchData()
        } else if let currentMeme = currentMeme {
            DispatchQueue.main.async {
                if let localMeme = DataStorageManager.shared.fetch(RandomMeme.self, primaryKey: currentMeme.id) {
                    self.isFavoriteRelay.accept(localMeme.isFavorite)
                }
            }
        }
    }

    func fetchData() {
        loadingStateRelay.accept(.loading)
        
        adFullPageHandler.increaseRequestCount()
        
        let keyword: String = keywordSubject.value ?? ""

        randomMemeWebAPI.fetchRandomMeme(with: keyword, mediaType: randomMediaType, minRating: 9)
            .subscribe(onSuccess: { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let randomMeme):
                    currentMeme = randomMeme
                    
                    DispatchQueue.main.async {
                        DataStorageManager.shared.saveAsync(randomMeme)
                    }
                    
                    mediaSubject.send((randomMeme.url, randomMeme.mediaType))
                    descriptionSubscribe.send(randomMeme.memeDescription)
                    
                    inAppReviewHandler.increaseGenerateContentCount()
                    
                case .failure(let error):
                    let noResultImageURL = Utility.getImageURL(named: Asset.Global.imageNotFound.name)
                    mediaSubject.send((noResultImageURL, .image))
                    descriptionSubscribe.send(error.message)
                }
                
                self.loadingStateRelay.accept(.success)
            }, onFailure: { [weak self] error in
                guard let self = self else { return }
                self.loadingStateRelay.accept(.failure(error: error))
            })
            .disposed(by: disposeBag)
    }
    
    func fetchUpVote() {
        guard let id = currentMeme?.id, remoteConfigHandler.getBool(forKey: .enableContentVoteApi) else {
            return
        }
        
        randomMemeWebAPI.fetchUpVoteMeme(with: id)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func fetchDownVote() {
        guard let id = currentMeme?.id, remoteConfigHandler.getBool(forKey: .enableContentVoteApi) else {
            return
        }
        
        randomMemeWebAPI.fetchDownVoteMeme(with: id)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private func setupObservable() {
        isFavoriteRelay
            .skip(1)
            .withUnretained(self)
            .subscribe(onNext: { (self, isFavorite) in
                guard let currentMeme = self.currentMeme else {
                    return
                }
                
                DispatchQueue.main.async {
                    DataStorageManager.shared.updateAsync(currentMeme, with: [Constant.Key.isFavorite: isFavorite])
                }
            })
            .disposed(by: disposeBag)
        
        shareButtonTappedSubject
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                guard let self, let currentMeme = self.currentMeme else {
                    return
                }
                
                AnalyticsManager.shared.logShareEvent(contentType: .meme, itemID: "\(currentMeme.id)")
            })
            .store(in: &cancellables)
    }
}
