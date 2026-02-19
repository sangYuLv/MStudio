//
//  URLValidator.swift
//  MStudio
//
//  Created by 이상유 on 2026-02-20.
//

import Foundation

struct URLValidator {

    /// 문자열이 유효한 URL 주소이며, 영상 파일 URL인지 확인한다.
    static func isValidVideoURL(_ str: String) async -> URL? {
        guard let url = URL(string: str) else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200
            else { return nil }

            let contentType = httpResponse.allHeaderFields["Content-Type"] as? String ?? ""
            let isValid = contentType.contains("video/") ||
                contentType.contains("mpegurl") ||
                contentType.contains("mp4")
            
            return isValid ? url : nil
        } catch {
            return nil
        }
    }

}
