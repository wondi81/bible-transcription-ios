import SwiftUI
import SwiftData

struct ProgressScreen: View {
    @Query(sort: \BookProgress.book) private var books: [BookProgress]

    private var overallPercent: Double {
        let total = books.reduce(0) { $0 + $1.totalVerses }
        let completed = books.reduce(0) { $0 + $1.completedVerses }
        guard total > 0 else { return 0 }
        return Double(completed) / Double(total)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ProgressView(value: overallPercent)
                        .tint(AppTheme.green)
                        .padding(.horizontal)
                    Text("\(Int(overallPercent * 100))% 완료")
                        .font(.appTitle(18))
                        .foregroundStyle(AppTheme.textPrimary)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 8) {
                        ForEach(books) { book in
                            VStack(spacing: 4) {
                                Text(book.book).font(.appBody(12)).lineLimit(1)
                                Text("\(book.completedVerses)/\(book.totalVerses)")
                                    .font(.appBody(11))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(AppTheme.textPrimary)
                            .background(book.completedVerses >= book.totalVerses ? AppTheme.green.opacity(0.25) : AppTheme.lavender.opacity(0.12))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(AppTheme.background)
            .navigationTitle("진행률")
        }
    }
}
