//
//  DessertDetailViewModel.swift
//  Dessertly-RxSwift
//
//  Created by Scott Gardner on 8/17/24.
//

import RxSwift

/// View model responsible for fetching and managing the details of a specific dessert.
final class DessertDetailViewModel {
    private let dessertService: DessertServiceProtocol
    private let disposeBag = DisposeBag()
    
    // Outputs
    let dessertDetail: Observable<DessertDetail>
    
    /// Initializes the view model with a specific dessert service.
    /// - Parameter dessertService: The dessert service to be used for fetching data. Defaults to `DessertService.shared`.
    init(dessertID: String, dessertService: DessertServiceProtocol = DessertService.shared) {
        self.dessertService = dessertService
        
        // Load the dessert detail from the service.
        dessertDetail = dessertService.dessertDetail(by: dessertID)
            .share(replay: 1)
    }
    
    /// Sorts the ingredients either in ascending or descending order.
    /// - Parameters:
    ///   - ingredients: A dictionary of ingredients and their measurements.
    ///   - ascending: A boolean value indicating whether the sorting should be ascending or descending.
    /// - Returns: A sorted array of tuples containing the ingredient and its measurement.
    func sortIngredients(ingredients: [String: String], ascending: Bool) -> [(ingredient: String, measure: String)] {
        let ingredientsArray = ingredients.map { ($0.key, $0.value) }
        let sortedIngredients = ingredientsArray.sorted { $0.0.lowercased() < $1.0.lowercased() }
        return ascending ? sortedIngredients : sortedIngredients.reversed()
    }
}
