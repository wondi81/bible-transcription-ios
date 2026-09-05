import Foundation

// ponytail: 성경 전체 31,102절 본문 데이터베이스는 저작권 확인+입력 스코프가 커서 별도 후속 작업.
// 우선 유명 구절 후보 리스트를 날짜 기반으로 순환시켜 "오늘의 구절" 메커니즘만 검증.
enum TodayVerse {
    static let candidates: [(book: String, ref: String)] = [
        ("요한복음", "요한복음 3:16"),
        ("시편", "시편 23:1"),
        ("빌립보서", "빌립보서 4:13"),
        ("잠언", "잠언 3:5"),
        ("로마서", "로마서 8:28"),
        ("이사야", "이사야 41:10"),
        ("마태복음", "마태복음 6:33"),
        ("여호수아", "여호수아 1:9"),
        ("고린도전서", "고린도전서 13:4"),
        ("에베소서", "에베소서 2:8"),
    ]

    static var today: (book: String, ref: String) {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return candidates[dayOfYear % candidates.count]
    }
}
