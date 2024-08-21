//
//  DessertDetailResponse.swift
//  Dessertly-RxSwift
//
//  Created by Scott Gardner on 8/17/24.
//

import Foundation

/// A response from the `DessertService` that includes a `meals` array of `DessertDetail`s.
struct DessertDetailResponse: Decodable {
    let meals: [DessertDetail]
}
