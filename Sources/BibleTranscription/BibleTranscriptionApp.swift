import SwiftUI
import SwiftData

@main
struct BibleTranscriptionApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Verse.self, Transcription.self, BookProgress.self])
    }
}
