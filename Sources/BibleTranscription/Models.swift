import Foundation
import SwiftData

@Model
final class Verse {
    var book: String
    var chapter: Int
    var verseNumber: Int
    var translation: String
    var text: String

    init(book: String, chapter: Int, verseNumber: Int, translation: String, text: String) {
        self.book = book
        self.chapter = chapter
        self.verseNumber = verseNumber
        self.translation = translation
        self.text = text
    }
}

@Model
final class Transcription {
    var verseRef: String
    var date: Date
    var drawingData: Data
    var isCompleted: Bool
    var durationSeconds: Int

    init(verseRef: String, date: Date = .now, drawingData: Data = Data(), isCompleted: Bool = false, durationSeconds: Int = 0) {
        self.verseRef = verseRef
        self.date = date
        self.drawingData = drawingData
        self.isCompleted = isCompleted
        self.durationSeconds = durationSeconds
    }
}

@Model
final class BookProgress {
    var book: String
    var totalVerses: Int
    var completedVerses: Int

    init(book: String, totalVerses: Int, completedVerses: Int = 0) {
        self.book = book
        self.totalVerses = totalVerses
        self.completedVerses = completedVerses
    }
}

struct VerseSeed: Codable {
    let book: String
    let chapter: Int
    let verseNumber: Int
    let translation: String
    let text: String
}

// 31,102개 Verse를 메인 액터에서 동기 insert하면 최초 실행 시 UI가 몇 초간 멈춘다.
// ModelActor는 별도 백그라운드 컨텍스트에서 돌아 메인 스레드를 막지 않고,
// 같은 ModelContainer를 쓰는 다른 @Query들은 저장 완료 후 자동으로 갱신된다.
@ModelActor
actor BibleSeeder {
    func seedIfNeeded() {
        var descriptor = FetchDescriptor<Verse>()
        descriptor.fetchLimit = 1
        if let existing = try? modelContext.fetch(descriptor), !existing.isEmpty {
            return
        }

        guard let url = Bundle.main.url(forResource: "bible_krv", withExtension: "json") else {
            print("[SEED] JSON 파일을 찾을 수 없음")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let seeds = try JSONDecoder().decode([VerseSeed].self, from: data)
            for seed in seeds {
                modelContext.insert(Verse(
                    book: seed.book,
                    chapter: seed.chapter,
                    verseNumber: seed.verseNumber,
                    translation: seed.translation,
                    text: seed.text
                ))
            }
            try modelContext.save()
            print("[SEED] inserted \(seeds.count) verses")
        } catch {
            print("[SEED] Error: \(error)")
        }
    }
}
