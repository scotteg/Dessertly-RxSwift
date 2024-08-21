//
//  DessertService.swift
//  Dessertly-RxSwift
//
//  Created by Scott Gardner on 8/17/24.
//

import Foundation
import RxSwift

/// A service that conforms to `DessertServiceProtocol` and handles fetching desserts and their details using RxSwift.
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
            .map { data in
                let dessertResponse = try JSONDecoder().decode(DessertResponse.self, from: data)
                return dessertResponse.meals.sorted { $0.name < $1.name }
            }
            .do(onError: { error in
                Task {
                    await ErrorHandler.shared.report(error: error)
                }
            })
            .catch { error in
                Observable.error(error)
            }
    }
    
    /// Fetches detailed information for a specific dessert by its ID.
    func dessertDetail(by id: String) -> Observable<DessertDetail> {
        guard let url = makeURL(endpoint: "lookup.php", queryItems: [URLQueryItem(name: "i", value: id)]) else {
            return Observable.error(URLError(.badURL))
        }
        
        return URLSession.shared.rx.data(request: URLRequest(url: url))
            .map { data in
                let detailResponse = try JSONDecoder().decode(DessertDetailResponse.self, from: data)
                guard let rawDetail = detailResponse.meals.first else {
                    throw URLError(.badServerResponse)
                }
                
                return DessertDetail(
                    id: rawDetail.id,
                    name: rawDetail.name,
                    instructions: rawDetail.instructions,
                    ingredients: rawDetail.ingredients,
                    imageUrl: rawDetail.imageUrl
                )
            }
            .do(onError: { error in
                Task {
                    await ErrorHandler.shared.report(error: error)
                }
            })
            .catch { error in
                Observable.error(error)
            }
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
