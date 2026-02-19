//
//  URLValidatorTests.swift
//  HomeTests
//
//  Created by 이상유 on 2026-02-20.
//

import Testing
import Foundation
@testable import MStudio

// MARK: - MockURLProtocol

private final class MockURLProtocol: URLProtocol, @unchecked Sendable {

    nonisolated(unsafe) static var requestHandler: (@Sendable (URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.requestHandler else {
            client?.urlProtocolDidFinishLoading(self)
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

// MARK: - Helper

private func makeValidator(
    statusCode: Int = 200,
    contentType: String = "video/mp4"
) -> URLValidator {
    MockURLProtocol.requestHandler = { _ in
        let response = HTTPURLResponse(
            url: URL(string: "https://stub")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: ["Content-Type": contentType]
        )!
        return (response, Data())
    }
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    return URLValidator(session: URLSession(configuration: config))
}

private func makeFailingValidator(error: any Error) -> URLValidator {
    MockURLProtocol.requestHandler = { _ in throw error }
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    return URLValidator(session: URLSession(configuration: config))
}

// MARK: - Tests

@Suite(.serialized)
@MainActor
struct URLValidatorTests {

    // MARK: - 사용자가 영상 URL을 입력했을 때

    @Test func MP4_영상_주소를_입력하면_재생할_수_있다() async throws {
        let sut = makeValidator(contentType: "video/mp4")

        let result = try await sut.isValidVideoURL("https://example.com/video.mp4")

        #expect(result.absoluteString == "https://example.com/video.mp4")
    }

    @Test func HLS_스트리밍_주소를_입력하면_재생할_수_있다() async throws {
        let sut = makeValidator(contentType: "application/vnd.apple.mpegurl")

        let result = try await sut.isValidVideoURL("https://example.com/stream.m3u8")

        #expect(result.absoluteString == "https://example.com/stream.m3u8")
    }

    @Test func MOV_영상_주소를_입력하면_재생할_수_있다() async throws {
        let sut = makeValidator(contentType: "video/quicktime")

        let result = try await sut.isValidVideoURL("https://example.com/movie.mov")

        #expect(result.absoluteString == "https://example.com/movie.mov")
    }

    // MARK: - 사용자가 잘못된 주소를 입력했을 때

    @Test func 빈_문자열을_입력하면_올바른_주소가_아니라고_알려준다() async {
        let sut = makeValidator()

        await #expect(throws: VideoURLValidationError.invalidURL) {
            try await sut.isValidVideoURL("")
        }
    }

    @Test func 웹페이지_주소를_입력하면_영상이_아니라고_알려준다() async {
        let sut = makeValidator(contentType: "text/html")

        await #expect(throws: VideoURLValidationError.notVideoContent) {
            try await sut.isValidVideoURL("https://example.com/page.html")
        }
    }

    @Test func JSON_API_주소를_입력하면_영상이_아니라고_알려준다() async {
        let sut = makeValidator(contentType: "application/json")

        await #expect(throws: VideoURLValidationError.notVideoContent) {
            try await sut.isValidVideoURL("https://example.com/api/data")
        }
    }

    // MARK: - 주소에 영상이 존재하지 않을 때

    @Test func 존재하지_않는_주소를_입력하면_불러올_수_없다고_알려준다() async {
        let sut = makeValidator(statusCode: 404)

        await #expect(throws: VideoURLValidationError.notFound) {
            try await sut.isValidVideoURL("https://example.com/deleted.mp4")
        }
    }

    @Test func 서버에_문제가_있으면_불러올_수_없다고_알려준다() async {
        let sut = makeValidator(statusCode: 500)

        await #expect(throws: VideoURLValidationError.notFound) {
            try await sut.isValidVideoURL("https://example.com/video.mp4")
        }
    }

    // MARK: - 네트워크 연결이 없을 때

    @Test func 인터넷이_끊기면_에러가_발생한다() async {
        let sut = makeFailingValidator(error: URLError(.notConnectedToInternet))

        await #expect(throws: (any Error).self) {
            try await sut.isValidVideoURL("https://example.com/video.mp4")
        }
    }

}
