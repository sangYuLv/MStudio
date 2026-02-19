//
//  HomeViewModelTests.swift
//  HomeTests
//
//  Created by 이상유 on 2026-02-20.
//

import Testing
import Combine
import Foundation
@testable import MStudio

// MARK: - Mock

private struct StubURLValidator: URLValidating {

    var result: Result<URL, any Error>

    func isValidVideoURL(_ str: String) async throws -> URL {
        try result.get()
    }
}

// MARK: - Helper

private let dummyURL = URL(string: "https://example.com/video.mp4")!

/// 디바운스(500ms) + 여유 시간을 기다린다.
private func waitForDebounce() async {
    try? await Task.sleep(nanoseconds: 600_000_000)
}

// MARK: - Tests

@MainActor
struct HomeViewModelTests {

    // MARK: - 사용자가 유효한 영상 주소를 입력했을 때

    @Test func 유효한_주소를_입력하면_재생_버튼이_활성화된다() async {
        let sut = HomeViewModel(urlValidator: StubURLValidator(result: .success(dummyURL)))

        sut.updateURL("https://example.com/video.mp4")
        await waitForDebounce()

        #expect(sut.enablePlayButton == true)
    }

    @Test func 유효한_주소를_입력하면_경고_메시지가_없다() async {
        let sut = HomeViewModel(urlValidator: StubURLValidator(result: .success(dummyURL)))

        sut.updateURL("https://example.com/video.mp4")
        await waitForDebounce()

        #expect(sut.warningNote == "")
    }

    @Test func 유효한_주소를_입력하면_validURL이_설정된다() async {
        let sut = HomeViewModel(urlValidator: StubURLValidator(result: .success(dummyURL)))

        sut.updateURL("https://example.com/video.mp4")
        await waitForDebounce()

        #expect(sut.validURL == dummyURL)
    }

    // MARK: - 사용자가 잘못된 주소를 입력했을 때

    @Test func 잘못된_주소를_입력하면_재생_버튼이_비활성화된다() async {
        let sut = HomeViewModel(
            urlValidator: StubURLValidator(result: .failure(VideoURLValidationError.invalidURL))
        )

        sut.updateURL("not-a-url")
        await waitForDebounce()

        #expect(sut.enablePlayButton == false)
    }

    @Test func 잘못된_주소를_입력하면_경고_메시지가_표시된다() async {
        let sut = HomeViewModel(
            urlValidator: StubURLValidator(result: .failure(VideoURLValidationError.invalidURL))
        )

        sut.updateURL("not-a-url")
        await waitForDebounce()

        #expect(sut.warningNote == VideoURLValidationError.invalidURL.message)
    }

    @Test func 영상이_아닌_주소를_입력하면_안내_메시지가_표시된다() async {
        let sut = HomeViewModel(
            urlValidator: StubURLValidator(result: .failure(VideoURLValidationError.notVideoContent))
        )

        sut.updateURL("https://example.com/page.html")
        await waitForDebounce()

        #expect(sut.warningNote == VideoURLValidationError.notVideoContent.message)
    }

    // MARK: - 사용자가 입력을 비웠을 때

    @Test func 입력을_비우면_재생_버튼이_비활성화된다() async {
        let sut = HomeViewModel(urlValidator: StubURLValidator(result: .success(dummyURL)))

        sut.updateURL("https://example.com/video.mp4")
        await waitForDebounce()
        sut.updateURL("")
        await waitForDebounce()

        #expect(sut.enablePlayButton == false)
    }

    @Test func 입력을_비우면_경고_메시지가_사라진다() async {
        let sut = HomeViewModel(
            urlValidator: StubURLValidator(result: .failure(VideoURLValidationError.invalidURL))
        )

        sut.updateURL("bad")
        await waitForDebounce()
        sut.updateURL("")
        await waitForDebounce()

        #expect(sut.warningNote == "")
    }

    @Test func nil을_입력하면_재생_버튼이_비활성화된다() async {
        let sut = HomeViewModel(urlValidator: StubURLValidator(result: .success(dummyURL)))

        sut.updateURL("https://example.com/video.mp4")
        await waitForDebounce()
        sut.updateURL(nil)
        await waitForDebounce()

        #expect(sut.enablePlayButton == false)
    }

    // MARK: - 네트워크 에러가 발생했을 때

    @Test func 네트워크_에러가_발생하면_안내_메시지가_표시된다() async {
        let sut = HomeViewModel(
            urlValidator: StubURLValidator(result: .failure(VideoURLValidationError.networkError))
        )

        sut.updateURL("https://example.com/video.mp4")
        await waitForDebounce()

        #expect(sut.warningNote == VideoURLValidationError.networkError.message)
    }

    @Test func 알_수_없는_에러가_발생하면_기본_메시지가_표시된다() async {
        let sut = HomeViewModel(
            urlValidator: StubURLValidator(result: .failure(URLError(.unknown)))
        )

        sut.updateURL("https://example.com/video.mp4")
        await waitForDebounce()

        #expect(sut.warningNote == "알 수 없는 오류가 발생했습니다.")
    }

    // MARK: - 사용자가 빠르게 주소를 바꿀 때 (디바운스)

    @Test func 빠르게_여러번_입력하면_마지막_결과만_반영된다() async {
        let sut = HomeViewModel(urlValidator: StubURLValidator(result: .success(dummyURL)))

        sut.updateURL("https://a.com")
        sut.updateURL("https://b.com")
        sut.updateURL("https://c.com")
        await waitForDebounce()

        #expect(sut.enablePlayButton == true)
        #expect(sut.validURL == dummyURL)
    }

}
