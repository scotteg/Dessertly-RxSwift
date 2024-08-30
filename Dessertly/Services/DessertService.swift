//
//  DessertService.swift
//  Dessertly-RxSwift
//
//  Created by Scott Gardner on 8/17/24.
//

import Foundation
import RxSwift

/// Fetches desserts and their details. Conforms to `DessertServiceProtocol`.
final class DessertService: DessertServiceProtocol {
    static let shared = DessertService()
    
    private let scheme = "https"
    private let host = "www.themealdb.com"
    private let basePath = "/api/json/v1/1/"
    
    private init() {}
    
    /// Observable sequence of desserts, fetched from the remote API.
    var desserts: Observable<[Dessert]> {
        guard let url = makeURL(endpoint: "filter.php", queryItems: [URLQueryItem(name: "c", value: "Dessert")]) else {
            return Observable.error(URLError(.badURL))
        }
        
        return URLSession.shared.rx.data(request: URLRequest(url: url))
            .retry(2)
            .map { data in
                let dessertResponse = try JSONDecoder().decode(DessertResponse.self, from: data)
                return dessertResponse.meals.sorted { $0.name < $1.name }
            }
            .do(onError: { error in
                ErrorHandler.shared.report(error: error)
            })
    }
    
    /// Fetches detailed information for a specific dessert by its ID.
    func dessertDetail(by id: String) -> Observable<DessertDetail> {
        guard let url = makeURL(endpoint: "lookup.php", queryItems: [URLQueryItem(name: "i", value: id)]) else {
            return Observable.error(URLError(.badURL))
        }
        
        return URLSession.shared.rx.data(request: URLRequest(url: url))
            .retry(2)
            .map { data in
                try JSONDecoder().decode(DessertDetailResponse.self, from: data)
            }
            .compactMap { $0.meals.first }
            .map { detail in
                DessertDetail(
                    id: detail.id,
                    name: detail.name,
                    instructions: detail.instructions,
                    ingredients: detail.ingredients,
                    imageUrl: detail.imageUrl
                )
            }
            .do(onError: { error in
                ErrorHandler.shared.report(error: error)
            })
    }
    
    private func makeURL(endpoint: String, queryItems: [URLQueryItem]) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = basePath + endpoint
        components.queryItems = queryItems
        return components.url
    }
}
