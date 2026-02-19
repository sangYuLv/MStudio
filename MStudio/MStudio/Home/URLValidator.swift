//
//  URLValidator.swift
//  MStudio
//
//  Created by 이상유 on 2026-02-20.
//

import Foundation

struct URLValidator {

    /// 문자열이 유효한 URL 주소이며, 영상 파일 URL인지 확인한다.
    static func isValidVideoURL(_ str: String) async throws -> URL {
        guard let url = URL(string: str) else {
            throw VideoURLValidationError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 5

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw VideoURLValidationError.networkError
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw VideoURLValidationError.notFound
        }

        let contentType = httpResponse.allHeaderFields["Content-Type"] as? String ?? ""
        let isValid = contentType.contains("video/") ||
            contentType.contains("mpegurl") ||
            contentType.contains("mp4")
        
        if isValid {
            return url
        } else {
            throw VideoURLValidationError.notVideoContent
        }
    }

}

/// 영상 주소 검증 에러
enum VideoURLValidationError: Error {
    case invalidURL
    case networkError
    case notVideoContent
    case notFound

    var message: String {
        switch self {
        case .invalidURL: return "올바른 주소 형식이 아닙니다."
        case .networkError: return "인터넷 연결을 확인해 주세요."
        case .notVideoContent: return "재생 가능한 영상 파일이 아닙니다."
        case .notFound: return "영상을 불러올 수 없습니다. 주소나 네트워크 상태를 확인해 주세요."
        }
    }

}
