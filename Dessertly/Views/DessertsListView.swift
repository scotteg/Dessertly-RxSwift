//
//  DessertsListView.swift
//  Dessertly-RxSwift
//
//  Created by Scott Gardner on 8/17/24.
//

import SwiftUI
import RxSwift

struct DessertsListView: View {
    @State private var desserts: [Dessert] = []
    @State private var filteredDesserts: [Dessert] = []
    @State private var isLoading = true
    @State private var isShowingError = false
    @State private var currentErrorMessage: String?
    @State private var searchQuery: String = ""
    
    private let viewModel = DessertsListViewModel()
    private let disposeBag = DisposeBag()
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                } else if desserts.isEmpty {
                    Text("No desserts available")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(filteredDesserts, id: \.id) { dessert in
                        NavigationLink(destination: DessertDetailView(dessertID: dessert.id)) {
                            HStack {
                                if let url = URL(string: dessert.thumbnail) {
                                    CachedAsyncImage(url: url)
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(5)
                                }
                                Text(dessert.name)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Desserts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Dessertly 💙 RxSwift")
                        .font(.custom("Lobster-Regular", size: 24))
                        .foregroundColor(.blue)
                        .accessibilityAddTraits(.isHeader)
                }
            }
            .searchable(text: Binding(
                get: { searchQuery },
                set: { newValue in
                    searchQuery = newValue
                    viewModel.updateSearchQuery(newValue)
                }
            ), prompt: "Search for desserts")
            .alert(isPresented: Binding(
                get: { isShowingError },
                set: { _ in }
            )) {
                Alert(
                    title: Text("Error"),
                    message: Text(currentErrorMessage ?? "An error occurred."),
                    dismissButton: .default(Text("OK")) {
                        isShowingError = false
                        currentErrorMessage = nil
                    }
                )
            }
            .onAppear {
                bindViewModel()
                bindErrorHandler()
            }
        }
    }
    
    private func bindViewModel() {
        viewModel.filteredDesserts
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { desserts in
                self.filteredDesserts = desserts
                self.isLoading = false
            })
            .disposed(by: disposeBag)
        
        viewModel.desserts
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { desserts in
                self.desserts = desserts
            })
            .disposed(by: disposeBag)
    }
    
    private func bindErrorHandler() {
        ErrorHandler.shared.observeCurrentError()
            .compactMap { $0 } // Filter out nil errors
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { error in
                self.currentErrorMessage = error.localizedDescription
                self.isShowingError = true
            })
            .disposed(by: disposeBag)
    }
}

#Preview {
    DessertsListView()
}
