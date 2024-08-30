//
//  CachedAsyncImage.swift
//  Dessertly-RxSwift
//
//  Created by Scott Gardner on 8/19/24.
//

import SwiftUI
import RxSwift
import RxCocoa

/// A view that asynchronously loads and caches an image from a given URL using RxSwift.
struct CachedAsyncImage: View {
    let url: URL
    private let disposeBag = DisposeBag()
    
    @State private var image: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if isLoading {
                ProgressView()
            } else {
                Text("Failed to load image")
                    .foregroundColor(.red)
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    /// Loads the image from the cache or fetches it from the network if not cached.
    private func loadImage() {
        if let cachedImage = ImageCache.shared.getImage(forKey: url.absoluteString) {
            self.image = cachedImage
            self.isLoading = false
        } else {
            fetchImage()
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { loadedImage in
                    self.image = loadedImage
                    self.isLoading = false
                }, onError: { error in
                    handleImageLoadError(error)
                })
                .disposed(by: disposeBag)
        }
    }
    
    /// Fetches the image using RxSwift and caches it.
    private func fetchImage() -> Observable<UIImage?> {
        return URLSession.shared.rx.data(request: URLRequest(url: url))
            .retry(2)
            .map { data in
                if let loadedImage = UIImage(data: data) {
                    ImageCache.shared.setImage(loadedImage, forKey: url.absoluteString)
                    return loadedImage
                }
                
                return nil
            }
            .catchAndReturn(nil)
    }
    
    /// Handles image load errors.
    private func handleImageLoadError(_ error: Error) {
        print("Failed to load image: \(error.localizedDescription)")
        self.isLoading = false
        ErrorHandler.shared.report(error: error)
    }
}
