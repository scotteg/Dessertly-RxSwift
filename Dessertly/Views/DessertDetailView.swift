//
//  DessertDetailView.swift
//  Dessertly-RxSwift
//
//  Created by Scott Gardner on 8/19/24.
//

import SwiftUI
import RxSwift

struct DessertDetailView: View {
    let dessertID: String
    private let viewModel: DessertDetailViewModel
    private let disposeBag = DisposeBag()
    
    @State private var dessertDetail: DessertDetail?
    @State private var isLoading = true
    @State private var hasError = false
    @State private var sortedIngredients: [(ingredient: String, measure: String)] = []
    @State private var sortAscending = true
    @State private var currentErrorMessage: String?
    
    init(dessertID: String) {
        self.dessertID = dessertID
        self.viewModel = DessertDetailViewModel(dessertID: dessertID)
    }
    
    var body: some View {
        GeometryReader { geometry in
            if isLoading {
                ProgressView()
                    .padding()
            } else if hasError {
                Text(currentErrorMessage ?? "An error occurred while loading the dessert detail.")
                    .foregroundColor(.red)
                    .padding()
            } else if let detail = dessertDetail {
                content(for: detail, geometry: geometry)
                    .navigationTitle(detail.name)
            }
        }
        .onAppear {
            bindViewModel()
            bindErrorHandler()
        }
    }
    
    @ViewBuilder
    private func content(for detail: DessertDetail, geometry: GeometryProxy) -> some View {
        if geometry.size.width > geometry.size.height {
            landscapeContent(for: detail, geometry: geometry)
        } else {
            portraitContent(for: detail)
        }
    }
    
    private func landscapeContent(for detail: DessertDetail, geometry: GeometryProxy) -> some View {
        HStack(alignment: .top, spacing: 16) {
            if let url = URL(string: detail.imageUrl) {
                CachedAsyncImage(url: url)
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .cornerRadius(10)
                    .padding(.leading)
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    instructionsSection(detail.instructions)
                    ingredientsSection()
                }
                .frame(maxWidth: geometry.size.width - 200)
                .padding(.trailing)
            }
        }
        .padding(.top, geometry.safeAreaInsets.top)
    }
    
    private func portraitContent(for detail: DessertDetail) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let url = URL(string: detail.imageUrl) {
                    CachedAsyncImage(url: url)
                        .scaledToFill()
                        .frame(maxHeight: 300)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                instructionsSection(detail.instructions)
                ingredientsSection()
            }
            .padding(.top)
        }
    }
    
    @ViewBuilder
    private func instructionsSection(_ instructions: String?) -> some View {
        GroupBox(label: Label("Instructions", systemImage: "list.bullet")) {
            Text(instructions ?? "No instructions available.")
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func ingredientsSection() -> some View {
        if !sortedIngredients.isEmpty {
            GroupBox(label: HStack {
                Label("Ingredients", systemImage: "cart")
                Spacer()
                Button(action: {
                    sortAscending.toggle()
                    sortedIngredients = viewModel.sortIngredients(ingredients: dessertDetail?.ingredients ?? [:],
                                                                  ascending: sortAscending)
                }) {
                    Image(systemName: sortAscending ? "chevron.up" : "chevron.down")
                }
            }) {
                VStack(alignment: .leading) {
                    ForEach(sortedIngredients, id: \.ingredient) { ingredient, measure in
                        HStack {
                            Text(ingredient)
                            Spacer()
                            Text(measure)
                        }
                        Divider()
                    }
                }
                .padding()
            }
            .padding(.horizontal)
        }
    }
    
    private func bindViewModel() {
        viewModel.dessertDetail
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { detail in
                self.dessertDetail = detail
                self.sortedIngredients = self.viewModel.sortIngredients(ingredients: detail.ingredients,
                                                                        ascending: self.sortAscending)
                self.isLoading = false
            })
            .disposed(by: disposeBag)
    }
    
    private func bindErrorHandler() {
        ErrorHandler.shared.observeCurrentError()
            .compactMap { $0 } // Filter out nil errors
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { error in
                self.currentErrorMessage = error.localizedDescription
                self.hasError = true
                self.isLoading = false
            })
            .disposed(by: disposeBag)
    }
}

#Preview {
    DessertDetailView(dessertID: "53049")
}
