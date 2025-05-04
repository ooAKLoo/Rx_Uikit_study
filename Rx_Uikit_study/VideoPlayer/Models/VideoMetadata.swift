//
//  VideoMetadata.swift
//  Rx_Uikit_study
//
//  Created by 杨东举 on 2025/5/4.
//


// VideoMetadata.swift
import Foundation

struct VideoMetadata {
    let id: String
    let title: String
    let duration: TimeInterval  // 秒数
    let durationFormatted: String  // 已格式化的时长，如 "45:39"
    let resolution: CGSize
    let fileSize: Int64  // 字节
    let thumbnailURL: URL?
    let videoURL: URL
    let createdAt: Date
    
    // 便利初始化方法，用于快速创建测试数据
    init(id: String = UUID().uuidString,
         title: String,
         duration: TimeInterval,
         videoURL: URL,
         resolution: CGSize = CGSize(width: 1920, height: 1080),
         fileSize: Int64 = 0,
         thumbnailURL: URL? = nil,
         createdAt: Date = Date()) {
        
        self.id = id
        self.title = title
        self.duration = duration
        self.videoURL = videoURL
        self.resolution = resolution
        self.fileSize = fileSize
        self.thumbnailURL = thumbnailURL
        self.createdAt = createdAt
        
        // 自动计算格式化的时长
        let mins = Int(duration) / 60
        let secs = Int(duration) % 60
        self.durationFormatted = String(format: "%02d:%02d", mins, secs)
    }
}



//struct VideoMetadata {
//    let id: String
//    let title: String
//    let duration: TimeInterval  // 秒数
//    let durationFormatted: String  // 已格式化的时长，如 "45:39"
//    let resolution: CGSize
//    let fileSize: Int64  // 字节
//    let thumbnailURL: URL?
//    let videoURL: URL
//    let createdAt: Date
//    
//    // 模拟后端返回的JSON数据
//    static func fromJSON(_ json: [String: Any]) -> VideoMetadata? {
//        guard let id = json["id"] as? String,
//              let title = json["title"] as? String,
//              let duration = json["duration"] as? TimeInterval,
//              let durationFormatted = json["duration_formatted"] as? String,
//              let videoURLString = json["video_url"] as? String,
//              let videoURL = URL(string: videoURLString) else {
//            return nil
//        }
//        
//        let resolution = CGSize(
//            width: json["width"] as? Double ?? 0,
//            height: json["height"] as? Double ?? 0
//        )
//        
//        let fileSize = json["file_size"] as? Int64 ?? 0
//        let thumbnailURL = (json["thumbnail_url"] as? String).flatMap { URL(string: $0) }
//        let createdAt = Date(timeIntervalSince1970: json["created_at"] as? TimeInterval ?? 0)
//        
//        return VideoMetadata(
//            id: id,
//            title: title,
//            duration: duration,
//            durationFormatted: durationFormatted,
//            resolution: resolution,
//            fileSize: fileSize,
//            thumbnailURL: thumbnailURL,
//            videoURL: videoURL,
//            createdAt: createdAt
//        )
//    }
//}
