//
//  ContentView.swift
//  GyozaMic
//
//  Created by Takamura Tatsuya on 2025/07/06.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var audioRecorder = AudioRecorder()
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 20) {
                    Text("GyozaMic")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    if audioRecorder.isRecording {
                        VStack(spacing: 10) {
                            Text("録音中...")
                                .foregroundColor(.red)
                                .font(.title2)
                            
                            Text(timeString(from: audioRecorder.recordingTime))
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                        }
                    } else {
                        Text("録音開始ボタンを押してください")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack(spacing: 20) {
                    Button(action: toggleRecording) {
                        HStack {
                            Image(systemName: audioRecorder.isRecording ? "stop.fill" : "mic.fill")
                                .font(.title2)
                            Text(audioRecorder.isRecording ? "録音停止" : "録音開始")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(width: 200, height: 60)
                        .background(audioRecorder.isRecording ? Color.red : Color.blue)
                        .cornerRadius(30)
                    }
                    
                    Button(action: audioRecorder.requestPermission) {
                        Text("マイク権限を要求")
                            .font(.callout)
                            .foregroundColor(.blue)
                    }
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("録音ファイル (\(audioRecorder.recordings.count))")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    List {
                        ForEach(audioRecorder.recordings, id: \.self) { recording in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(recording.lastPathComponent)
                                        .font(.callout)
                                        .lineLimit(1)
                                    Text(formatFileDate(recording))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Button(action: {
                                    audioRecorder.deleteRecording(recording)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("GyozaMic")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func toggleRecording() {
        if audioRecorder.isRecording {
            audioRecorder.stopRecording()
        } else {
            audioRecorder.startRecording()
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func formatFileDate(_ url: URL) -> String {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
              let date = attributes[.creationDate] as? Date else {
            return "Unknown"
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
