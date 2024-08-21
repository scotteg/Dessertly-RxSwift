//
//  DessertServiceProtocol.swift
//  Dessertly-RxSwift
//
//  Created by Scott Gardner on 8/17/24.
//

import RxSwift

/// Protocol that defines the requirements to fetch dessert data using RxSwift.
protocol DessertServiceProtocol {
    
    /// An observable sequence of a sorted array of `Dessert` instances.
    var desserts: Observable<[Dessert]> { get }
    
    /// Fetches detailed information for a specific dessert by its ID.
    /// - Parameter id: The ID of the dessert to fetch details for.
    /// - Returns: An observable sequence of a `DessertDetail` instance.
    func dessertDetail(by id: String) -> Observable<DessertDetail>
}
