import AVFoundation
import SwiftUI

class AudioRecorder: ObservableObject {
    @Published var isRecording = false
    @Published var recordingTime: TimeInterval = 0
    @Published var recordings: [URL] = []
    @Published var isPlaying = false
    @Published var currentPlayingURL: URL?
    @Published var playbackTime: TimeInterval = 0
    @Published var playbackDuration: TimeInterval = 0
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private var playbackTimer: Timer?
    private var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    init() {
        setupAudioSession()
        loadRecordings()
    }
    
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func requestPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    print("Recording permission granted")
                } else {
                    print("Recording permission denied")
                }
            }
        }
    }
    
    func startRecording() {
        guard !isRecording else { return }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("recording_\(Date().timeIntervalSince1970).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            
            isRecording = true
            recordingTime = 0
            
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                self.recordingTime += 1
            }
        } catch {
            print("Failed to start recording: \(error)")
        }
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        audioRecorder?.stop()
        timer?.invalidate()
        
        isRecording = false
        
        if let url = audioRecorder?.url {
            recordings.append(url)
        }
    }
    
    private func loadRecordings() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let files = try FileManager.default.contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: nil)
            recordings = files.filter { $0.pathExtension == "m4a" }
        } catch {
            print("Failed to load recordings: \(error)")
        }
    }
    
    func deleteRecording(_ url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
            recordings.removeAll { $0 == url }
        } catch {
            print("Failed to delete recording: \(error)")
        }
    }
    
    func playRecording(_ url: URL) {
        if isPlaying && currentPlayingURL == url {
            pausePlayback()
            return
        }
        
        stopPlayback()
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            isPlaying = true
            currentPlayingURL = url
            playbackTime = 0
            playbackDuration = audioPlayer?.duration ?? 0
            
            playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                self.playbackTime = self.audioPlayer?.currentTime ?? 0
                
                if self.audioPlayer?.isPlaying == false {
                    self.stopPlayback()
                }
            }
        } catch {
            print("Failed to play recording: \(error)")
        }
    }
    
    func pausePlayback() {
        audioPlayer?.pause()
        isPlaying = false
        playbackTimer?.invalidate()
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        playbackTimer?.invalidate()
        isPlaying = false
        currentPlayingURL = nil
        playbackTime = 0
        playbackDuration = 0
    }
    
    func seekTo(_ time: TimeInterval) {
        audioPlayer?.currentTime = time
        playbackTime = time
    }
}
