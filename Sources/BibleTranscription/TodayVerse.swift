import Foundation

// ponytail: 성경 전체 31,102절 본문 데이터베이스는 저작권 확인+입력 스코프가 커서 별도 후속 작업.
// 우선 유명 구절 후보 리스트를 날짜 기반으로 순환시켜 "오늘의 구절" 메커니즘만 검증.

struct TodayVerseCandidate {
    let book: String
    let chapter: Int
    let verseNumber: Int

    var ref: String {
        "\(book) \(chapter):\(verseNumber)"
    }
}

enum TodayVerse {
    static let candidates: [TodayVerseCandidate] = [
        .init(book: "요한복음", chapter: 3, verseNumber: 16),
        .init(book: "시편", chapter: 23, verseNumber: 1),
        .init(book: "빌립보서", chapter: 4, verseNumber: 13),
        .init(book: "잠언", chapter: 3, verseNumber: 5),
        .init(book: "로마서", chapter: 8, verseNumber: 28),
        .init(book: "이사야", chapter: 41, verseNumber: 10),
        .init(book: "마태복음", chapter: 6, verseNumber: 33),
        .init(book: "여호수아", chapter: 1, verseNumber: 9),
        .init(book: "고린도전서", chapter: 13, verseNumber: 4),
        .init(book: "에베소서", chapter: 2, verseNumber: 8),
    ]

    static var today: TodayVerseCandidate {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return candidates[dayOfYear % candidates.count]
    }
}
