import SwiftUI
@preconcurrency import AVFoundation
import Combine

// MARK: - Audio Manager (Global Singleton)
/// Manages calm background music across the entire app.
/// Uses AVAudioEngine for lightweight procedural ambient tone generation.
/// Persists user preferences via @AppStorage.
@MainActor
final class AudioManager: ObservableObject {
    
    static let shared = AudioManager()
    
    // MARK: - Sound Themes
    enum SoundTheme: String, CaseIterable, Identifiable {
        case silence = "Silence"
        case ambientPad = "Ambient Pad"
        case gentleRain = "Gentle Rain"
        case meditationTone = "Meditation"
        case softLofi = "Soft Lo-fi"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .silence: return "speaker.slash.fill"
            case .ambientPad: return "waveform"
            case .gentleRain: return "cloud.rain.fill"
            case .meditationTone: return "leaf.fill"
            case .softLofi: return "headphones"
            }
        }
    }
    
    // MARK: - Published State
    @Published var isPlaying: Bool = false
    @Published var currentTheme: SoundTheme = .silence {
        didSet { UserDefaults.standard.set(currentTheme.rawValue, forKey: "audio_theme") }
    }
    @Published var volume: Float = 0.3 {
        didSet {
            UserDefaults.standard.set(volume, forKey: "audio_volume")
            applyVolume()
        }
    }
    @Published var isMusicEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(isMusicEnabled, forKey: "audio_enabled")
            if isMusicEnabled {
                play()
            } else {
                stop()
            }
        }
    }
    
    // MARK: - Audio Engine
    private var audioEngine: AVAudioEngine?
    private var toneNodes: [AVAudioSourceNode] = []
    private var mixerNode: AVAudioMixerNode?
    private var noiseNode: AVAudioSourceNode?
    private var phase: [Double] = [0, 0, 0, 0]
    private var lfoPhase: Double = 0
    private var fadeTask: Task<Void, Never>?
    private var currentVolume: Float = 0
    private var targetVolume: Float = 0
    
    // MARK: - Init
    private init() {
        // Restore preferences
        if let themeRaw = UserDefaults.standard.string(forKey: "audio_theme"),
           let theme = SoundTheme(rawValue: themeRaw) {
            currentTheme = theme
        }
        volume = UserDefaults.standard.object(forKey: "audio_volume") as? Float ?? 0.3
        isMusicEnabled = UserDefaults.standard.bool(forKey: "audio_enabled")
        
        setupNotifications()
        
        if isMusicEnabled && currentTheme != .silence {
            play()
        }
    }
    
    // MARK: - Background/Foreground Handling
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.pause()
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.resumeIfNeeded()
            }
        }
    }
    
    // MARK: - Public API
    
    func play() {
        guard isMusicEnabled, currentTheme != .silence else {
            stop()
            return
        }
        
        // If already playing the same theme, just adjust volume
        if isPlaying {
            stop()
        }
        
        configureAudioSession()
        startEngine(for: currentTheme)
        fadeIn()
        isPlaying = true
    }
    
    func stop() {
        fadeOut { [weak self] in
            await MainActor.run {
                self?.stopEngine()
                self?.isPlaying = false
            }
        }
    }
    
    func switchTheme(to theme: SoundTheme) {
        let wasPlaying = isPlaying
        currentTheme = theme
        
        if wasPlaying || isMusicEnabled {
            if theme == .silence {
                stop()
            } else {
                stop()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.play()
                }
            }
        }
    }
    
    private func pause() {
        audioEngine?.pause()
    }
    
    private func resumeIfNeeded() {
        guard isMusicEnabled, currentTheme != .silence, isPlaying else { return }
        try? audioEngine?.start()
    }
    
    // MARK: - Audio Session
    
    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            // Silently fail — ambient audio is non-critical
        }
    }
    
    // MARK: - Engine Setup
    
    private func startEngine(for theme: SoundTheme) {
        let engine = AVAudioEngine()
        let mixer = AVAudioMixerNode()
        engine.attach(mixer)
        
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        
        switch theme {
        case .ambientPad:
            setupAmbientPad(engine: engine, mixer: mixer, format: format)
        case .gentleRain:
            setupRainNoise(engine: engine, mixer: mixer, format: format)
        case .meditationTone:
            setupMeditationTone(engine: engine, mixer: mixer, format: format)
        case .softLofi:
            setupSoftLofi(engine: engine, mixer: mixer, format: format)
        case .silence:
            return
        }
        
        engine.connect(mixer, to: engine.mainMixerNode, format: format)
        mixer.outputVolume = 0 // Start silent for fade-in
        
        do {
            try engine.start()
            self.audioEngine = engine
            self.mixerNode = mixer
        } catch {
            // Silently fail
        }
    }
    
    private func stopEngine() {
        fadeTask?.cancel()
        fadeTask = nil
        audioEngine?.stop()
        toneNodes.removeAll()
        audioEngine = nil
        mixerNode = nil
    }
    
    // MARK: - Sound Generators
    
    /// Warm ambient pad — two detuned sine waves with slow LFO
    private func setupAmbientPad(engine: AVAudioEngine, mixer: AVAudioMixerNode, format: AVAudioFormat) {
        let sampleRate = format.sampleRate
        var localPhase1: Double = 0
        var localPhase2: Double = 0
        var localLFO: Double = 0
        
        let freq1 = 174.0  // F3 — healing frequency
        let freq2 = 176.5  // Slightly detuned for warmth
        let lfoRate = 0.15  // Very slow modulation
        
        let node = AVAudioSourceNode { _, _, frameCount, bufferList -> OSStatus in
            let buffer = UnsafeMutableBufferPointer<Float>(
                start: bufferList.pointee.mBuffers.mData?.assumingMemoryBound(to: Float.self),
                count: Int(frameCount)
            )
            
            for i in 0..<Int(frameCount) {
                let lfoVal = 0.5 + 0.5 * sin(2.0 * .pi * lfoRate * localLFO / sampleRate)
                let sample1 = sin(2.0 * .pi * freq1 * localPhase1 / sampleRate)
                let sample2 = sin(2.0 * .pi * freq2 * localPhase2 / sampleRate)
                
                let mixed = Float((sample1 * 0.4 + sample2 * 0.3) * lfoVal * 0.3)
                buffer[i] = mixed
                
                localPhase1 += 1
                localPhase2 += 1
                localLFO += 1
            }
            return noErr
        }
        
        engine.attach(node)
        engine.connect(node, to: mixer, format: format)
        toneNodes.append(node)
    }
    
    /// Filtered white noise for rain ambience
    private func setupRainNoise(engine: AVAudioEngine, mixer: AVAudioMixerNode, format: AVAudioFormat) {
        var lastSample: Float = 0
        let smoothing: Float = 0.985  // Heavy smoothing for soft rain
        
        let node = AVAudioSourceNode { _, _, frameCount, bufferList -> OSStatus in
            let buffer = UnsafeMutableBufferPointer<Float>(
                start: bufferList.pointee.mBuffers.mData?.assumingMemoryBound(to: Float.self),
                count: Int(frameCount)
            )
            
            for i in 0..<Int(frameCount) {
                let white = Float.random(in: -1.0...1.0)
                lastSample = smoothing * lastSample + (1 - smoothing) * white
                buffer[i] = lastSample * 0.25
            }
            return noErr
        }
        
        engine.attach(node)
        engine.connect(node, to: mixer, format: format)
        toneNodes.append(node)
    }
    
    /// Gentle layered sine tones — meditation bowl
    private func setupMeditationTone(engine: AVAudioEngine, mixer: AVAudioMixerNode, format: AVAudioFormat) {
        let sampleRate = format.sampleRate
        var p1: Double = 0
        var p2: Double = 0
        var p3: Double = 0
        var pLfo: Double = 0
        
        let f1 = 256.0   // C4
        let f2 = 384.0   // G4 (perfect fifth)
        let f3 = 512.0   // C5 (octave)
        
        let node = AVAudioSourceNode { _, _, frameCount, bufferList -> OSStatus in
            let buffer = UnsafeMutableBufferPointer<Float>(
                start: bufferList.pointee.mBuffers.mData?.assumingMemoryBound(to: Float.self),
                count: Int(frameCount)
            )
            
            for i in 0..<Int(frameCount) {
                let lfo = 0.4 + 0.6 * sin(2.0 * .pi * 0.08 * pLfo / sampleRate)
                let s1 = sin(2.0 * .pi * f1 * p1 / sampleRate) * 0.3
                let s2 = sin(2.0 * .pi * f2 * p2 / sampleRate) * 0.2
                let s3 = sin(2.0 * .pi * f3 * p3 / sampleRate) * 0.1
                
                buffer[i] = Float((s1 + s2 + s3) * lfo * 0.3)
                
                p1 += 1; p2 += 1; p3 += 1; pLfo += 1
            }
            return noErr
        }
        
        engine.attach(node)
        engine.connect(node, to: mixer, format: format)
        toneNodes.append(node)
    }
    
    /// Minimal lo-fi — low chord with gentle noise texture
    private func setupSoftLofi(engine: AVAudioEngine, mixer: AVAudioMixerNode, format: AVAudioFormat) {
        let sampleRate = format.sampleRate
        var p1: Double = 0
        var p2: Double = 0
        var p3: Double = 0
        var pLfo: Double = 0
        var lastNoise: Float = 0
        
        let f1 = 130.8   // C3
        let f2 = 164.8   // E3
        let f3 = 196.0   // G3
        
        let node = AVAudioSourceNode { _, _, frameCount, bufferList -> OSStatus in
            let buffer = UnsafeMutableBufferPointer<Float>(
                start: bufferList.pointee.mBuffers.mData?.assumingMemoryBound(to: Float.self),
                count: Int(frameCount)
            )
            
            for i in 0..<Int(frameCount) {
                let lfo = 0.5 + 0.5 * sin(2.0 * .pi * 0.12 * pLfo / sampleRate)
                let s1 = sin(2.0 * .pi * f1 * p1 / sampleRate) * 0.25
                let s2 = sin(2.0 * .pi * f2 * p2 / sampleRate) * 0.2
                let s3 = sin(2.0 * .pi * f3 * p3 / sampleRate) * 0.15
                
                // Soft noise texture
                let white = Float.random(in: -1.0...1.0)
                lastNoise = 0.99 * lastNoise + 0.01 * white
                
                let mixed = Float((s1 + s2 + s3) * lfo * 0.25) + lastNoise * 0.03
                buffer[i] = mixed
                
                p1 += 1; p2 += 1; p3 += 1; pLfo += 1
            }
            return noErr
        }
        
        engine.attach(node)
        engine.connect(node, to: mixer, format: format)
        toneNodes.append(node)
    }
    
    // MARK: - Fade In/Out
    
    private func fadeIn() {
        currentVolume = 0
        targetVolume = volume
        fadeTask?.cancel()
        
        let steps = 20
        let interval: UInt64 = UInt64(1_500_000_000 / steps) // 1.5 second fade
        let increment = targetVolume / Float(steps)
        
        fadeTask = Task { [weak self] in
            for _ in 0..<steps {
                guard !Task.isCancelled else { return }
                try? await Task.sleep(nanoseconds: interval)
                guard let self = self, !Task.isCancelled else { return }
                self.currentVolume = min(self.currentVolume + increment, self.targetVolume)
                self.mixerNode?.outputVolume = self.currentVolume
                if self.currentVolume >= self.targetVolume { break }
            }
        }
    }
    
    private func fadeOut(completion: (@Sendable () async -> Void)? = nil) {
        fadeTask?.cancel()
        
        guard let mixer = mixerNode else {
            Task { await completion?() }
            return
        }
        
        currentVolume = mixer.outputVolume
        let steps = 15
        let interval: UInt64 = UInt64(800_000_000 / steps) // 0.8 second fade out
        let decrement = currentVolume / Float(steps)
        
        fadeTask = Task { [weak self] in
            for _ in 0..<steps {
                guard !Task.isCancelled else { return }
                try? await Task.sleep(nanoseconds: interval)
                guard let self = self, !Task.isCancelled else { return }
                self.currentVolume = max(self.currentVolume - decrement, 0)
                self.mixerNode?.outputVolume = self.currentVolume
                if self.currentVolume <= 0 { break }
            }
            await completion?()
        }
    }
    
    private func applyVolume() {
        guard isPlaying else { return }
        mixerNode?.outputVolume = volume
        currentVolume = volume
    }
    
    /// Call before releasing to clean up audio resources.
    func cleanup() {
        fadeTask?.cancel()
        fadeTask = nil
        audioEngine?.stop()
        audioEngine = nil
    }
}
