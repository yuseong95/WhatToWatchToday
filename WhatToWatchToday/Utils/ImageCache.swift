//
//  ImageCache.swift
//  WhatToWatchToday
//
//  Created by 나유성 on 6/6/25.
//
//  네트워크에서 이미지를 다운로드하고 캐싱하는 유틸리티

import UIKit

class ImageCache {
    
    // 싱글톤 패턴
    static let shared = ImageCache()
    private init() {}
    
    // 이미지 캐시 저장소 (메모리에 이미지 저장)
    private let cache = NSCache<NSString, UIImage>()
    
    // 현재 다운로드 중인 작업들을 관리
    private var downloadTasks: [String: URLSessionDataTask] = [:]
    
    // 이미지 로딩 메서드
    func loadImage(from urlString: String?, completion: @escaping (UIImage?) -> Void) {
        
        // URL이 nil이거나 빈 문자열이면 기본 이미지 반환
        guard let urlString = urlString, !urlString.isEmpty else {
            completion(UIImage(systemName: "photo.fill"))
            return
        }
        
        // 캐시에서 이미지 확인
        if let cachedImage = cache.object(forKey: urlString as NSString) {
            completion(cachedImage)
            return
        }
        
        // URL 생성
        guard let url = URL(string: urlString) else {
            completion(UIImage(systemName: "photo.fill"))
            return
        }
        
        // 이미 다운로드 중인지 확인
        if downloadTasks[urlString] != nil {
            return  // 이미 다운로드 중이면 중복 요청 방지
        }
        
        // 이미지 다운로드 시작
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            // 완료되면 다운로드 작업 목록에서 제거
            self?.downloadTasks.removeValue(forKey: urlString)
            
            // 메인 스레드에서 UI 업데이트
            DispatchQueue.main.async {
                
                // 에러가 있으면 기본 이미지 반환
                if let error = error {
                    print("🚨 이미지 다운로드 실패: \(error.localizedDescription)")
                    completion(UIImage(systemName: "photo.fill"))
                    return
                }
                
                // 데이터가 있고 이미지로 변환 가능하면
                if let data = data, let image = UIImage(data: data) {
                    // 캐시에 저장
                    self?.cache.setObject(image, forKey: urlString as NSString)
                    completion(image)
                } else {
                    // 변환 실패시 기본 이미지
                    completion(UIImage(systemName: "photo.fill"))
                }
            }
        }
        
        // 다운로드 작업 저장 및 시작
        downloadTasks[urlString] = task
        task.resume()
    }
    
    // UIImageView Extension용 편의 메서드
    func setImage(to imageView: UIImageView, from urlString: String?, placeholder: UIImage? = nil) {
        
        // 플레이스홀더 이미지 먼저 설정
        imageView.image = placeholder ?? UIImage(systemName: "photo.fill")
        
        // 이미지 로딩
        loadImage(from: urlString) { image in
            imageView.image = image
        }
    }
    
    // 캐시 관리
    func clearCache() {
        cache.removeAllObjects()
        print("🗑️ 이미지 캐시 클리어 완료")
    }
    
    func cancelDownload(for urlString: String) {
        downloadTasks[urlString]?.cancel()
        downloadTasks.removeValue(forKey: urlString)
    }
}

// UIImageView Extension
extension UIImageView {
    
    // UIImageView에서 쉽게 이미지 로딩할 수 있는 메서드
    func loadImage(from urlString: String?, placeholder: UIImage? = nil) {
        ImageCache.shared.setImage(to: self, from: urlString, placeholder: placeholder)
    }
}
