//
//  DessertsListViewModel.swift
//  Dessertly-RxSwift
//
//  Created by Scott Gardner on 8/17/24.
//

import RxSwift

/// View model responsible for fetching and managing a list of desserts.
final class DessertsListViewModel {
    private let dessertService: DessertServiceProtocol
    private let disposeBag = DisposeBag()
    
    // Inputs
    private let searchQuerySubject = BehaviorSubject<String>(value: "")
    
    // Outputs
    let desserts: Observable<[Dessert]>
    let filteredDesserts: Observable<[Dessert]>
    
    /// Initializes the view model with a specific dessert service.
    /// - Parameter dessertService: The dessert service to be used for fetching data. Defaults to `DessertService.shared`.
    init(dessertService: DessertServiceProtocol = DessertService.shared) {
        self.dessertService = dessertService
        
        // Load desserts from the service
        desserts = dessertService.desserts
            .share(replay: 1)
        
        // Filter the desserts based on the search query
        filteredDesserts = Observable.combineLatest(desserts, searchQuerySubject)
            .map { desserts, query in
                guard !query.isEmpty else { return desserts }
                return desserts.filter { $0.name.lowercased().contains(query.lowercased()) }
            }
            .share(replay: 1)
    }
    
    /// Updates the search query, triggering a new filter on the desserts.
    func updateSearchQuery(_ query: String) {
        searchQuerySubject.onNext(query)
    }
}
