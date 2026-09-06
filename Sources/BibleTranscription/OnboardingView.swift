import SwiftUI
import SwiftData

struct OnboardingView: View {
    @AppStorage("selectedTranslation") private var selectedTranslation = ""
    @Environment(\.modelContext) private var modelContext
    @Query private var bookProgresses: [BookProgress]

    // 저작권 재검증(2026-09-06) 결과 개역개정/새번역/쉬운성경은 유료 라이선스 필요 —
    // 저작권 만료(2011년)된 개역한글판 단일로 확정.
    private let translations = ["개역한글판"]

    var body: some View {
        VStack(spacing: 24) {
            Text("번역본을 선택하세요")
                .font(.appTitle(22))
                .foregroundStyle(AppTheme.textPrimary)
            ForEach(translations, id: \.self) { translation in
                Button(translation) {
                    selectedTranslation = translation
                    seedBookProgressIfNeeded()
                }
                .buttonStyle(NeumorphicButtonStyle())
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background)
    }

    private func seedBookProgressIfNeeded() {
        guard bookProgresses.isEmpty else { return }
        for book in BibleBooks.all {
            modelContext.insert(BookProgress(book: book.name, totalVerses: book.totalVerses))
        }
    }
}
