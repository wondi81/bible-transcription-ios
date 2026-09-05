import SwiftUI
import SwiftData
import PencilKit

struct ArchiveScreen: View {
    @Query(sort: \Transcription.date, order: .reverse) private var transcriptions: [Transcription]
    @State private var selected: Transcription?

    var body: some View {
        NavigationStack {
            Group {
                if transcriptions.isEmpty {
                    Text("아직 필사 기록이 없습니다")
                        .foregroundStyle(.secondary)
                } else {
                    List(transcriptions) { t in
                        Button {
                            selected = t
                        } label: {
                            VStack(alignment: .leading) {
                                Text(t.verseRef).font(.headline)
                                Text(t.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .tint(.primary)
                    }
                }
            }
            .navigationTitle("필사 기록보관함")
            .sheet(item: $selected) { t in
                TranscriptionDetailView(transcription: t)
            }
        }
    }
}

struct TranscriptionDetailView: View {
    let transcription: Transcription

    var body: some View {
        VStack(spacing: 16) {
            Text(transcription.verseRef).font(.title2.bold())
            if let drawing = try? PKDrawing(data: transcription.drawingData) {
                Image(uiImage: drawing.image(from: drawing.bounds.isEmpty ? CGRect(x: 0, y: 0, width: 300, height: 300) : drawing.bounds, scale: 1))
                    .resizable()
                    .scaledToFit()
                    .padding()
            } else {
                Text("이미지를 불러올 수 없습니다")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}
