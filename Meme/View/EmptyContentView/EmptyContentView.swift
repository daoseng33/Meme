//
//  EmptyContentView.swift
//  Meme
//
//  Created by DAO on 2024/10/21.
//

import SwiftUI
import Combine

struct EmptyContentView: View {
    // MARK: - Properties
    private let viewModel: EmptyContentViewModelProtocol
    
    // MARK: - Init
    init(viewModel: EmptyContentViewModelProtocol) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: Constant.UI.spacing5) {
            Image(uiImage: Asset.memeDogeDog.image)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            
            Button {
                self.viewModel.actionButtonSubject.send(())
            } label: {
                Text("Go get some fun".localized())
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.accent)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
                    .padding(.horizontal, Constant.UI.spacing6)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.secondarySystemBackground))
    }
    
    // MARK: - Preview
#if DEBUG
    struct EmptyContentView_Previews: PreviewProvider {
        static var previews: some View {
            EmptyContentView(viewModel: PreviewEmptyContentViewModel())
        }
    }
    
    // 用於 Preview 的 Mock ViewModel
    private class PreviewEmptyContentViewModel: EmptyContentViewModelProtocol {
        var actionButtonSubject = PassthroughSubject<Void, Never>()
    }
#endif
}
