//
//  ErrorHandler.swift
//  Dessertly-RxSwift
//
//  Created by Scott Gardner on 8/19/24.
//

import Foundation
import RxSwift

/// Manages and reports errors across the app.
final class ErrorHandler {
    static let shared = ErrorHandler()
    
    private let errorSubject = ReplaySubject<Error?>.create(bufferSize: 1)
    
    private init() { }
    
    /// Reports an error to the centralized error handler.
    func report(error: Error) {
        errorSubject.onNext(error)
    }
    
    /// Observes the current error.
    func observeCurrentError() -> Observable<Error?> {
        return errorSubject.asObservable()
    }
    
    /// Clears the current error.
    func clearError() {
        errorSubject.onNext(nil)
    }
}
