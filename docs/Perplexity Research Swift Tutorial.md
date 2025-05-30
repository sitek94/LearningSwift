# Modern Swift Concurrency and State Management: A Beginner's Guide for macOS Development

As a Swift and SwiftUI developer transitioning from web technologies, understanding concurrency patterns and state management can be challenging. This comprehensive guide will demystify these concepts through building components for a macOS speech-to-text application, helping you make informed decisions about which patterns to use in your projects.

## Introduction to Swift Concurrency and State Management

Swift concurrency refers to how your application handles multiple operations simultaneously, while state management determines how your app stores and updates data. For those coming from web development, you might recognize similarities to JavaScript's asynchronous programming models, but Swift's approach is more sophisticated and type-safe.

### Understanding Thread Management in Swift

In any application, there's a special thread called the "main thread" that handles UI updates and user interactions. When you perform time-consuming operations on this thread, your app becomes unresponsive. The solution is to move intensive operations to background threads, but with a crucial rule: **UI updates must always happen on the main thread**.

Let's examine a simple example that demonstrates the problem and solution:

```swift
import SwiftUI

struct ConcurrencyBasicsView: View {
    @State private var message = "Press the button to start"
    
    var body: some View {
        VStack(spacing: 20) {
            Text(message)
                .padding()
            
            Button("Problematic Task") {
                // BAD: Long operation on main thread
                message = "Starting task..."
                
                // Simulate a time-consuming operation
                let startTime = Date()
                for _ in 1...10_000_000 {
                    _ = sin(Double.random(in: 0...1))
                }
                
                message = "Completed in \(Date().timeIntervalSince(startTime)) seconds"
                // During this operation, the UI is completely frozen!
            }
            
            Button("Correct Approach") {
                message = "Starting task..."
                
                // GOOD: Move intensive work to background thread
                Task {
                    // Background work
                    let startTime = Date()
                    for _ in 1...10_000_000 {
                        _ = sin(Double.random(in: 0...1))
                    }
                    let timeElapsed = Date().timeIntervalSince(startTime)
                    
                    // Update UI on main thread
                    await MainActor.run {
                        message = "Completed in \(String(format: "%.2f", timeElapsed)) seconds"
                    }
                }
                // UI remains responsive during processing
            }
        }
        .padding()
    }
}
```


## Observable Patterns in Swift: @Observable vs ObservableObject

Swift offers two main patterns for making objects observable by SwiftUI views:

### The ObservableObject Protocol (Traditional Approach)

```swift
import SwiftUI
import Combine

class RecordingViewModel: ObservableObject {
    @Published var isRecording = false
    @Published var transcribedText = ""
    
    func toggleRecording() {
        // When this changes, SwiftUI will update views
        isRecording.toggle()
        
        if isRecording {
            // Start recording logic...
        } else {
            // Stop recording logic...
        }
    }
}

struct RecordingView: View {
    // @StateObject creates and owns the view model
    @StateObject private var viewModel = RecordingViewModel()
    
    var body: some View {
        VStack {
            Text(viewModel.transcribedText.isEmpty ? 
                "Press record to start" : viewModel.transcribedText)
                .padding()
                .frame(height: 100)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            Button(viewModel.isRecording ? "Stop Recording" : "Start Recording") {
                viewModel.toggleRecording()
            }
            .buttonStyle(.borderedProminent)
            .tint(viewModel.isRecording ? .red : .blue)
        }
        .padding()
    }
}
```


### The @Observable Macro (Modern Approach)

```swift
import SwiftUI
import Observation

@Observable // New in Swift 6
class RecordingModel {
    var isRecording = false
    var transcribedText = ""
    
    func toggleRecording() {
        isRecording.toggle()
        
        if isRecording {
            // Start recording logic...
        } else {
            // Stop recording logic...
        }
    }
}

struct ModernRecordingView: View {
    // No property wrapper needed - just a regular property
    let model = RecordingModel()
    
    var body: some View {
        VStack {
            Text(model.transcribedText.isEmpty ? 
                "Press record to start" : model.transcribedText)
                .padding()
                .frame(height: 100)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            Button(model.isRecording ? "Stop Recording" : "Start Recording") {
                model.toggleRecording()
            }
            .buttonStyle(.borderedProminent)
            .tint(model.isRecording ? .red : .blue)
        }
        .padding()
    }
}
```


### Key Differences Between @Observable and ObservableObject

| Feature | @Observable | ObservableObject |
| :-- | :-- | :-- |
| Syntax | Simpler - no property wrappers needed | Requires @Published for tracked properties |
| Performance | More efficient - only updates for changed properties | Updates entire object when any @Published property changes |
| View Usage | Uses regular properties | Requires @ObservedObject, @StateObject, or @EnvironmentObject |
| Compatibility | Requires Swift 6, macOS 14+ | Works on older Swift and macOS versions |
| Concurrency | Stricter thread safety requirements | More forgiving with thread boundaries |

## @MainActor and UI Updates in Swift

### What is @MainActor?

`@MainActor` is an attribute that ensures code runs on the main thread. It's part of Swift's actor system introduced in Swift 5.5, providing a safer alternative to `DispatchQueue.main.async`.

```swift
// Without @MainActor - Must manually dispatch to main thread
func updateUIManually(with text: String) {
    // This is error-prone - easy to forget
    DispatchQueue.main.async {
        self.transcribedText = text
    }
}

// With @MainActor - Automatically runs on main thread
@MainActor
func updateUI(with text: String) {
    // Guaranteed to run on main thread
    transcribedText = text
}
```


### Class-Level @MainActor

You can apply `@MainActor` to an entire class to ensure all its methods run on the main thread:

```swift
@MainActor
class SpeechRecognitionViewModel: ObservableObject {
    @Published var transcribedText = ""
    @Published var isRecording = false
    
    func startRecording() {
        // This code runs on the main thread
        isRecording = true
        
        // Start speech recognition in background
        Task.detached {
            // Background work...
            
            // Update UI safely
            await MainActor.run {
                self.transcribedText = "Transcribed text..."
                self.isRecording = false
            }
        }
    }
}
```


### Combining @Observable and @MainActor

In Swift 6, you can combine these patterns, but the order matters:

```swift
// Correct order
@Observable @MainActor
class SpeechRecognizer {
    var transcribedText = ""
    var isRecording = false
    
    // Methods automatically run on main thread
}
```


## Building a Speech-to-Text Component

Let's implement a speech recognition component using both approaches to compare them:

### Using ObservableObject and Manual Thread Management

```swift
import SwiftUI
import AVFoundation
import Speech

class SpeechRecognizerViewModel: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var transcribedText = ""
    @Published var isRecording = false
    @Published var errorMessage: String?
    
    private var audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    
    override init() {
        super.init()
        requestPermissions()
    }
    
    private func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { status in
            // IMPORTANT: Update UI on main thread
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    self.errorMessage = nil
                case .denied:
                    self.errorMessage = "Speech recognition permission denied"
                case .restricted, .notDetermined:
                    self.errorMessage = "Speech recognition not available"
                @unknown default:
                    self.errorMessage = "Unknown error with speech recognition"
                }
            }
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            // IMPORTANT: Update UI on main thread
            DispatchQueue.main.async {
                if !granted {
                    self.errorMessage = "Microphone permission denied"
                }
            }
        }
    }
    
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        // Reset previous task
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Could not set up audio session: \(error.localizedDescription)"
            }
            return
        }
        
        // Set up recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode,
              let recognitionRequest = recognitionRequest else {
            DispatchQueue.main.async {
                self.errorMessage = "Recognition request setup failed"
            }
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Start recognition
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            var isFinal = false
            
            if let result = result {
                // IMPORTANT: Update UI on main thread
                DispatchQueue.main.async {
                    self.transcribedText = result.bestTranscription.formattedString
                }
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                // IMPORTANT: Update UI on main thread
                DispatchQueue.main.async {
                    self.isRecording = false
                }
            }
        }
        
        // Configure microphone input
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        // Start audio engine
        do {
            audioEngine.prepare()
            try audioEngine.start()
            DispatchQueue.main.async {
                self.isRecording = true
                self.errorMessage = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Could not start audio engine: \(error.localizedDescription)"
            }
        }
    }
    
    private func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        
        if let inputNode = audioEngine.inputNode {
            inputNode.removeTap(onBus: 0)
        }
        
        DispatchQueue.main.async {
            self.isRecording = false
        }
    }
}
```


### Using @Observable and @MainActor

```swift
import SwiftUI
import AVFoundation
import Speech
import Observation

@Observable
@MainActor // All UI updates will automatically happen on main thread
final class ModernSpeechRecognizer: NSObject, AVAudioRecorderDelegate {
    var transcribedText = ""
    var isRecording = false
    var errorMessage: String?
    
    private var audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    
    override init() {
        super.init()
        Task {
            await requestPermissions()
        }
    }
    
    private func requestPermissions() async {
        // Request speech recognition permission using structured concurrency
        let status = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        
        // No need for DispatchQueue.main.async because of @MainActor
        switch status {
        case .authorized:
            errorMessage = nil
        case .denied:
            errorMessage = "Speech recognition permission denied"
        case .restricted, .notDetermined:
            errorMessage = "Speech recognition not available"
        @unknown default:
            errorMessage = "Unknown error with speech recognition"
        }
        
        // Request microphone permission
        let granted = await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
        
        // No need for DispatchQueue.main.async because of @MainActor
        if !granted {
            errorMessage = "Microphone permission denied"
        }
    }
    
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        // Reset previous task
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            // No need for DispatchQueue.main.async because of @MainActor
            errorMessage = "Could not set up audio session: \(error.localizedDescription)"
            return
        }
        
        // Rest of implementation similar to previous example, but without DispatchQueue.main.async
        // due to @MainActor annotation...
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode,
              let recognitionRequest = recognitionRequest else {
            errorMessage = "Recognition request setup failed"
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Start recognition
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            var isFinal = false
            
            if let result = result {
                // Need to explicitly use MainActor since this is a callback
                Task { @MainActor in
                    self.transcribedText = result.bestTranscription.formattedString
                }
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                // Need to explicitly use MainActor since this is a callback
                Task { @MainActor in
                    self.isRecording = false
                }
            }
        }
        
        // Configure microphone input
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        // Start audio engine
        do {
            audioEngine.prepare()
            try audioEngine.start()
            // No need for DispatchQueue.main.async because of @MainActor
            isRecording = true
            errorMessage = nil
        } catch {
            // No need for DispatchQueue.main.async because of @MainActor
            errorMessage = "Could not start audio engine: \(error.localizedDescription)"
        }
    }
    
    private func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        
        if let inputNode = audioEngine.inputNode {
            inputNode.removeTap(onBus: 0)
        }
        
        // No need for DispatchQueue.main.async because of @MainActor
        isRecording = false
    }
}
```


## Delegation Patterns in Swift

Delegation is a design pattern that enables one object to send messages to another object when specific events occur. It's heavily used in Apple's frameworks.

### Basic Delegation Implementation

```swift
// 1. Define a protocol for the delegate
protocol AudioRecorderDelegate: AnyObject {
    func audioRecorderDidStartRecording()
    func audioRecorderDidFinishRecording(successfully: Bool)
    func audioRecorderDidEncounterError(_ error: Error)
}

// 2. Create a class that will have delegates
class BasicAudioRecorder {
    private var audioRecorder: AVAudioRecorder?
    weak var delegate: AudioRecorderDelegate? // Always use weak to avoid retain cycles
    
    func startRecording() {
        // Implementation details...
        
        // Notify delegate
        delegate?.audioRecorderDidStartRecording()
    }
    
    func stopRecording() {
        // Implementation details...
        
        // Notify delegate
        delegate?.audioRecorderDidFinishRecording(successfully: true)
    }
}

// 3. Create a class that implements the delegate
class AudioManager: ObservableObject, AudioRecorderDelegate {
    @Published var isRecording = false
    @Published var recordingFinished = false
    
    private let recorder = BasicAudioRecorder()
    
    init() {
        recorder.delegate = self // Set self as the delegate
    }
    
    // Implement delegate methods
    func audioRecorderDidStartRecording() {
        DispatchQueue.main.async {
            self.isRecording = true
        }
    }
    
    func audioRecorderDidFinishRecording(successfully: Bool) {
        DispatchQueue.main.async {
            self.isRecording = false
            self.recordingFinished = successfully
        }
    }
    
    func audioRecorderDidEncounterError(_ error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}
```


## Modern Swift Concurrency with async/await

Swift 5.5 introduced the async/await pattern, which provides a more elegant way to write asynchronous code compared to completion handlers.

### Basic async/await Usage

```swift
// Traditional completion handler approach
func fetchTranscription(completion: @escaping (Result<String, Error>) -> Void) {
    // Asynchronous work...
    completion(.success("Transcription result"))
}

// Modern async/await approach
func fetchTranscription() async throws -> String {
    // Asynchronous work...
    return "Transcription result"
}
```


### Structured Concurrency with Task Groups

Task groups allow you to run multiple asynchronous operations in parallel and combine their results:

```swift
func processMultipleAudioFiles(urls: [URL]) async throws -> [String] {
    try await withThrowingTaskGroup(of: (Int, String).self) { group in
        // Add a task for each audio file
        for (index, url) in urls.enumerated() {
            group.addTask {
                let transcription = try await transcribeAudioFile(url)
                return (index, transcription) // Keep track of original order
            }
        }
        
        // Collect results in correct order
        var results = Array(repeating: "", count: urls.count)
        for try await (index, transcription) in group {
            results[index] = transcription
        }
        
        return results
    }
}
```


## Common Pitfalls and Solutions

### 1. Race Conditions

**Problem:** Multiple threads accessing and modifying the same data simultaneously.

```swift
// BAD: Race condition
class UnsafeCounter {
    var count = 0
    
    func increment() {
        // Multiple threads might read the same value and increment
        // resulting in lost increments
        count += 1
    }
}
```

**Solution:** Use actors or synchronized access

```swift
// GOOD: Thread-safe with actor
actor SafeCounter {
    private var count = 0
    
    func increment() -> Int {
        count += 1
        return count
    }
    
    func getCount() -> Int {
        return count
    }
}
```


### 2. UI Updates from Background Threads

**Problem:** Updating UI from background threads can cause crashes.

```swift
// BAD: Updating UI from background thread
Task.detached {
    // Background work...
    self.statusLabel = "Completed" // Will cause problems
}
```

**Solution:** Use MainActor or dispatch to main thread

```swift
// GOOD: Using MainActor
Task.detached {
    // Background work...
    await MainActor.run {
        self.statusLabel = "Completed" // Safe
    }
}
```


### 3. Callback Hell

**Problem:** Nested completion handlers make code hard to read and maintain.

```swift
// BAD: Callback hell
fetchUserData { result in
    switch result {
    case .success(let user):
        self.fetchUserPreferences(for: user) { preferencesResult in
            switch preferencesResult {
            case .success(let preferences):
                self.fetchRecommendations(matching: preferences) { recommendationsResult in
                    // Even more nesting...
                }
            case .failure(let error):
                // Handle error
            }
        }
    case .failure(let error):
        // Handle error
    }
}
```

**Solution:** Use async/await for sequential asynchronous operations

```swift
// GOOD: Clean async/await code
Task {
    do {
        let user = try await fetchUserData()
        let preferences = try await fetchUserPreferences(for: user)
        let recommendations = try await fetchRecommendations(matching: preferences)
        // Use the results...
    } catch {
        // Handle all errors in one place
    }
}
```


## Making the Right Choice for Your App

### When to Use @Observable with @MainActor:

- For new projects targeting macOS 14+/Swift 6
- When performance is critical
- For cleaner, more maintainable code
- When you want automatic main thread safety


### When to Use ObservableObject with DispatchQueue:

- For backward compatibility with older macOS versions
- When migrating existing code gradually
- When interoperating with older frameworks
- When you need more control over thread management


### Migration Path: ObservableObject to @Observable

If you're starting with ObservableObject but plan to migrate to @Observable:

1. Start with ObservableObject and consistent DispatchQueue.main.async use
2. Add @MainActor to your class to consolidate thread management
3. When ready to require Swift 6, replace ObservableObject with @Observable
4. Remove @Published property wrappers
5. Update view declarations to use regular properties instead of @ObservedObject

## Conclusion

Understanding Swift's concurrency patterns and state management approaches is crucial for building robust macOS applications. The changes in the code snippets you mentioned were all about handling these patterns correctly:

- Removing @MainActor and @Observable in favor of ObservableObject provides better backward compatibility
- Wrapping UI updates in DispatchQueue.main.async ensures thread safety
- Adding proper delegation by inheriting from NSObject is necessary for AVAudioRecorderDelegate
- Changing from @Environment to @ObservedObject ensures a predictable data flow

For your speech-to-text application:

1. Start with what's comfortable - ObservableObject is more forgiving
2. Ensure all UI updates happen on the main thread
3. Use async/await for cleaner asynchronous code
4. As you gain confidence, consider migrating to @Observable with @MainActor for better performance

Remember that Swift's concurrency system is still evolving, and mastering these patterns will make your code more maintainable and efficient in the long run.

## Further Resources

1. [Swift Concurrency Documentation](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
2. [MainActor usage in Swift explained](https://www.avanderlee.com/swift/mainactor-dispatch-main-thread/)[^1]
3. [Dispatching to the Main thread with MainActor](https://www.donnywals.com/dispatching-to-the-main-thread-with-mainactor-in-swift/)[^2]
4. [What is Structured Concurrency?](https://www.avanderlee.com/swift/what-is-structured-concurrency/)[^5]
5. [Task Groups in Swift explained](https://www.avanderlee.com/concurrency/task-groups-in-swift/)[^6]
6. [Thread Safety in Swift](https://swiftrocks.com/thread-safety-in-swift)[^10]

<div style="text-align: center">⁂</div>

[^1]: https://www.avanderlee.com/swift/mainactor-dispatch-main-thread/

[^2]: https://www.donnywals.com/dispatching-to-the-main-thread-with-mainactor-in-swift/

[^3]: https://forums.swift.org/t/dispatchqueue-asyncafter-deadline-in-structured-concurrency/69006

[^4]: https://www.avanderlee.com/swift/async-await/

[^5]: https://www.avanderlee.com/swift/what-is-structured-concurrency/

[^6]: https://www.avanderlee.com/concurrency/task-groups-in-swift/

[^7]: https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro

[^8]: https://matteomanferdini.com/swiftui-data-flow/

[^9]: https://www.swiftbysundell.com/articles/delegation-in-swift/

[^10]: https://swiftrocks.com/thread-safety-in-swift

[^11]: https://www.youtube.com/watch?v=4dQOnNYjO58

[^12]: https://mobile.blog/2022/03/28/swift-why-is-my-mainactor-code-running-in-the-background/

[^13]: https://www.dhiwise.com/post/swift-async-await-explained-simplifying-asynchronous

[^14]: https://www.donnywals.com/the-basics-of-structured-concurrency-in-swift-explained/

[^15]: https://swiftwithmajid.com/2025/02/04/mastering-task-groups-in-swift/

[^16]: https://www.avanderlee.com/swiftui/observable-macro-performance-increase-observableobject/

[^17]: https://fatbobman.com/en/posts/swiftui-views-and-mainactor/

[^18]: https://matteomanferdini.com/swift-async-await/

[^19]: https://itnext.io/mainactor-in-swift-detailed-walkthrough-94044c83118b

[^20]: https://www.youtube.com/watch?v=2xA9RvLlit8

[^21]: https://www.swiftwithvincent.com/blog/discover-how-main-actor-works-in-swift

[^22]: https://www.reddit.com/r/swift/comments/u7svwi/is_it_bad_practice_to_use_dispatchqueuemainasync/

[^23]: https://www.youtube.com/watch?v=XRulkUR1O5Q

[^24]: https://www.kodeco.com/books/modern-concurrency-in-swift/v1.0/chapters/2-getting-started-with-async-await

[^25]: https://developer.apple.com/videos/play/wwdc2021/10132/

[^26]: https://www.reddit.com/r/SwiftUI/comments/1cxlsw3/is_it_me_or_is_the_new_observable_not_that_great/

[^27]: https://forums.swift.org/t/lifecycle-of-swiftui-view-observable-vs-observableobject/69842

[^28]: https://developer.apple.com/tutorials/app-dev-training/managing-data-flow-between-views

[^29]: https://www.reddit.com/r/swift/comments/l0kew5/the_strategic_swiftui_data_flow_guide_infographic/

[^30]: https://www.reddit.com/r/swift/comments/yy5x15/delegate_pattern/

[^31]: https://developer.apple.com/documentation/swift/using-delegates-to-customize-object-behavior

[^32]: https://www.youtube.com/watch?v=qiOKO8ta1n4

[^33]: https://dilloncodes.hashnode.dev/delegate-pattern-in-swift

[^34]: https://www.donnywals.com/comparing-observable-to-observableobjects/

[^35]: https://developer.apple.com/videos/play/wwdc2023/10149/

[^36]: https://nilcoalescing.com/blog/ObservableInSwiftUI

[^37]: https://www.reddit.com/r/swift/comments/1ikpomt/how_are_we_combining_observable_and_sendable/

[^38]: https://www.jessesquires.com/blog/2024/09/09/swift-observable-macro/

[^39]: https://www.donnywals.com/observing-properties-on-an-observable-class-outside-of-swiftui-views/

[^40]: https://namitgupta.com/5-essential-elements-to-understanding-data-flow-in-swiftui

[^41]: https://www.youtube.com/watch?v=yvfv6N60-vY

[^42]: https://www.reddit.com/r/SwiftUI/comments/13a5fbk/swiftuis_stateobject_and_observedobject_the_key/

[^43]: https://swiftwithmajid.com/2020/07/02/the-difference-between-stateobject-environmentobject-and-observedobject-in-swiftui/

[^44]: https://www.avanderlee.com/swiftui/mvvm-architectural-coding-pattern-to-structure-views/

[^45]: https://bugfender.com/blog/swiftui-navigation/

[^46]: https://fatbobman.com/en/posts/exploring-key-property-wrappers-in-swiftui/

[^47]: https://www.dhiwise.com/post/swift-delegate-in-depth-guide-for-structured-ios-programming

[^48]: https://stackoverflow.com/questions/36131765/delegates-of-avaudiorecorderdelegate-are-not-calling

[^49]: https://gist.github.com/fbeb73f6113e7c05eb9d

[^50]: https://www.linkedin.com/pulse/mastering-thread-safety-concurrency-ios-development-swift-solanki-1qn8f

