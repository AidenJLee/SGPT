//
//  Whisper.swift
//  SGPT
//
//  Created by HoJun Lee on 2023/03/03.
//

import Foundation
import DeclarativeConnectKit

// MARK: - Whisper
struct Whisper: Codable {
    let text: String
}

extension Whisper {
    private struct APIEndpoints {
        static var path = "/v1/audio/transcriptions"
    }
    
    struct transcriptions: DCRequest {
        typealias ReturnType = Whisper
        
        var path: String = APIEndpoints.path
        var method: HTTPMethod = .post
        var contentType: HTTPContentType = .multipart
        var headers: HTTPHeaders?
        var body: Params?
        var multipartData: [MultipartData]?
        
        init(_ header: HTTPHeaders = ["Authorization": "Bearer \(SGPTApp.authenticationKey)"], body: Params, multipartData: [MultipartData]) {
            self.headers = header
            self.body = body
            self.multipartData = multipartData
        }
    }
}
