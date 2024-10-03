//
//  HistoryViewModelProtocol.swift
//  Meme
//
//  Created by DAO on 2024/10/2.
//

import Foundation
import RxCocoa

protocol HistoryViewModelProtocol {
    var reloadDataSignal: Signal<Void> { get }
    func getCellViewModel(at indexPath: IndexPath) -> GeneralContentCellViewModelProtocol
    func getRowsCount(with section: Int) -> Int
    func getLocalDatas()
}
