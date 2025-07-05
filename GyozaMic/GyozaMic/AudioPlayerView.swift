import SwiftUI
import AVFoundation

struct AudioPlayerView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    let recordingURL: URL
    
    var body: some View {
        VStack(spacing: 15) {
            VStack(spacing: 8) {
                Text(recordingURL.lastPathComponent)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(formatFileDate(recordingURL))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 10) {
                if audioRecorder.currentPlayingURL == recordingURL {
                    ProgressView(value: audioRecorder.playbackTime, total: audioRecorder.playbackDuration)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    
                    HStack {
                        Text(timeString(from: audioRecorder.playbackTime))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(timeString(from: audioRecorder.playbackDuration))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    ProgressView(value: 0, total: 1)
                        .progressViewStyle(LinearProgressViewStyle(tint: .gray))
                    
                    HStack {
                        Text("00:00")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(getDurationString(for: recordingURL))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            HStack(spacing: 20) {
                Button(action: {
                    audioRecorder.playRecording(recordingURL)
                }) {
                    Image(systemName: isCurrentlyPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                
                Button(action: {
                    audioRecorder.stopPlayback()
                }) {
                    Image(systemName: "stop.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.gray)
                        .clipShape(Circle())
                }
                .disabled(!isCurrentlyPlaying)
                
                Button(action: {
                    audioRecorder.deleteRecording(recordingURL)
                }) {
                    Image(systemName: "trash")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.red)
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var isCurrentlyPlaying: Bool {
        audioRecorder.isPlaying && audioRecorder.currentPlayingURL == recordingURL
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
    
    private func getDurationString(for url: URL) -> String {
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            let duration = audioPlayer.duration
            let minutes = Int(duration) / 60
            let seconds = Int(duration) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        } catch {
            return "00:00"
        }
    }
}