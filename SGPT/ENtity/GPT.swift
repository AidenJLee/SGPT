//
//  GPT.swift
//  SGPT
//
//  Created by HoJun Lee on 2023/03/03.
//
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let gPT = try? JSONDecoder().decode(GPT.self, from: jsonData)

import Foundation
import DeclarativeConnectKit

extension GPT {
    private struct APIEndpoints {
        static var path = "/v1/chat/completions"
    }
    
    struct ChatCompletion: DCRequest {
        typealias ReturnType = GPT
        var path: String = APIEndpoints.path
        var method: HTTPMethod = .post
        var body: Params?
        
        init(body: Params) {
            self.body = body
        }
    }
}

// MARK: - GPT
struct GPT: Codable {
    let id, object: String
    let created: Int
    let model: String
    let choices: [Choice]
    let usage: Usage
}

// MARK: - Choice
struct Choice: Codable {
    let index: Int
    let finishReason: String?
    let message: Message

    enum CodingKeys: String, CodingKey {
        case index
        case finishReason = "finish_reason"
        case message
    }
}

// MARK: - Message
struct Message: Codable {
    let role, content: String
}

// MARK: - Usage
struct Usage: Codable {
    let promptTokens, completionTokens, totalTokens: Int

    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}
