////
////  VideosRepository.swift
////  OvniVision
////
////  Created by Ulises Vazquez on 3/12/26.
////
//
//import Foundation
//import ObjectBox
//
//
//
//@Observable
//final class MockVideosRepository: VideosApi {
//    private init(localApi: LocalStoreRepository = .shared) {
//        self.localApi = localApi
//    }
//    static let shared = MockVideosRepository()
//    private let localApi: LocalApi
//    
//    var isLoading: Bool = false
//    var videos: [VideoRecord] = []
//    
//    func getVideos() {
//        self.isLoading = true
//        Task { @MainActor in
//            try await Task.sleep(for: .seconds(6), tolerance: .zero)
//            self.videos = [
//                
//            ]
//            self.isLoading = false
//        }
//        
//    }
//    
//}
