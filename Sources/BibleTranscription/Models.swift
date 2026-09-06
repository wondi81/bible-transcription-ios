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
