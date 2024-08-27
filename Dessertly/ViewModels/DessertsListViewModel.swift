//
//  DessertsListViewModel.swift
//  Dessertly-RxSwift
//
//  Created by Scott Gardner on 8/17/24.
//

import RxSwift

/// Fetches and manages a list of desserts.
final class DessertsListViewModel {
    let desserts: Observable<[Dessert]>
    let filteredDesserts: Observable<[Dessert]>
    
    private let dessertService: DessertServiceProtocol
    private let searchQuerySubject = BehaviorSubject<String>(value: "")
    
    /// Initializes the view model with a specific dessert service.
    /// - Parameter dessertService: The dessert service to be used for fetching data. Defaults to `DessertService.shared`.
    init(dessertService: DessertServiceProtocol = DessertService.shared) {
        self.dessertService = dessertService
        
        // Load the list of desserts from the service.
        desserts = dessertService.desserts
            .share(replay: 1, scope: .whileConnected) // Limit retention to active subscriptions.
        
        // Filter the desserts based on the search query.
        filteredDesserts = Observable.combineLatest(desserts, searchQuerySubject)
            .map { desserts, query in
                desserts.filter { query.isEmpty || $0.name.lowercased().contains(query.lowercased()) }
            }
            .share(replay: 1, scope: .whileConnected)
    }
    
    /// Updates the search query to filter the list of desserts.
    /// - Parameter query: The new search query.
    func updateSearchQuery(_ query: String) {
        searchQuerySubject.onNext(query)
    }
}
