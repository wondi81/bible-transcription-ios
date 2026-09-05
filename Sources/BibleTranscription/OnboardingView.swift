import SwiftUI
import SwiftData

struct OnboardingView: View {
    @AppStorage("selectedTranslation") private var selectedTranslation = ""
    @Environment(\.modelContext) private var modelContext
    @Query private var bookProgresses: [BookProgress]

    private let translations = ["개역개정", "새번역", "쉬운성경"]

    var body: some View {
        VStack(spacing: 24) {
            Text("번역본을 선택하세요")
                .font(.title2.bold())
            ForEach(translations, id: \.self) { translation in
                Button(translation) {
                    selectedTranslation = translation
                    seedBookProgressIfNeeded()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }

    private func seedBookProgressIfNeeded() {
        guard bookProgresses.isEmpty else { return }
        for book in BibleBooks.all {
            modelContext.insert(BookProgress(book: book.name, totalVerses: book.totalVerses))
        }
    }
}
