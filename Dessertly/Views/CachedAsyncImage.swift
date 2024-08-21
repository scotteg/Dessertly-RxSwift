//
//  CachedAsyncImage.swift
//  Dessertly-RxSwift
//
//  Created by Scott Gardner on 8/19/24.
//

import SwiftUI
import RxSwift

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
                    print("Failed to load image: \(error.localizedDescription)")
                    self.isLoading = false
                })
                .disposed(by: disposeBag)
        }
    }
    
    /// Fetches the image using RxSwift and caches it.
    private func fetchImage() -> Observable<UIImage?> {
        return Observable.create { observer in
            let task = URLSession.shared.dataTask(with: self.url) { data, response, error in
                if let error = error {
                    observer.onError(error)
                } else if let data = data, let loadedImage = UIImage(data: data) {
                    ImageCache.shared.setImage(loadedImage, forKey: self.url.absoluteString)
                    observer.onNext(loadedImage)
                    observer.onCompleted()
                } else {
                    observer.onNext(nil)
                    observer.onCompleted()
                }
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
