import AVFoundation
import SwiftUI
import UIKit

/// Owns the capture session: permissions, preview, recording each shot to a file.
/// Session work runs on a private serial queue; published state is updated on the main actor.
@MainActor
final class CameraService: NSObject, ObservableObject {
    enum Access: Equatable { case unknown, granted, denied }
    enum Position { case back, front }

    @Published private(set) var access: Access = .unknown
    @Published private(set) var isRunning = false
    @Published private(set) var isRecording = false
    @Published private(set) var recordedSeconds: Double = 0
    @Published var flashOn = false

    /// True on the Simulator or any device without a camera; the UI shows a sample frame instead.
    let isAvailable: Bool

    let session = AVCaptureSession()
    private let queue = DispatchQueue(label: "space.playlocal.mova.camera")
    private let movieOutput = AVCaptureMovieFileOutput()
    private var videoInput: AVCaptureDeviceInput?
    private var position: Position = .back
    private var timer: Timer?
    private var finish: ((URL?) -> Void)?

    override init() {
        isAvailable = AVCaptureDevice.default(for: .video) != nil
        super.init()
    }

    // MARK: Permissions

    func refreshAccess() {
        let video = AVCaptureDevice.authorizationStatus(for: .video)
        switch video {
        case .authorized: access = .granted
        case .notDetermined: access = .unknown
        default: access = .denied
        }
    }

    /// Asks for camera, then microphone. Returns whether the camera is usable.
    @discardableResult
    func requestAccess() async -> Bool {
        let cam = await AVCaptureDevice.requestAccess(for: .video)
        _ = await AVCaptureDevice.requestAccess(for: .audio)   // audio is optional; video still records without it
        access = cam ? .granted : .denied
        return cam
    }

    /// Opens the app's page in Settings (used when access was denied earlier).
    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: Session

    func start() {
        guard isAvailable, access == .granted, !isRunning else { return }
        let session = self.session, output = movieOutput
        let pos = position
        queue.async { [weak self] in
            session.beginConfiguration()
            session.sessionPreset = .high
            if session.inputs.isEmpty {
                if let device = Self.device(for: pos), let input = try? AVCaptureDeviceInput(device: device), session.canAddInput(input) {
                    session.addInput(input)
                    Task { @MainActor in self?.videoInput = input }
                }
                if let mic = AVCaptureDevice.default(for: .audio), let input = try? AVCaptureDeviceInput(device: mic), session.canAddInput(input) {
                    session.addInput(input)
                }
            }
            if session.canAddOutput(output) { session.addOutput(output) }
            session.commitConfiguration()
            session.startRunning()
            Task { @MainActor in self?.isRunning = session.isRunning }
        }
    }

    func stop() {
        let session = self.session
        queue.async { [weak self] in
            session.stopRunning()
            Task { @MainActor in self?.isRunning = false }
        }
    }

    func flip() {
        guard isAvailable else { return }
        position = position == .back ? .front : .back
        let session = self.session, pos = position, old = videoInput
        queue.async { [weak self] in
            guard let device = Self.device(for: pos), let input = try? AVCaptureDeviceInput(device: device) else { return }
            session.beginConfiguration()
            if let old { session.removeInput(old) }
            if session.canAddInput(input) { session.addInput(input) }
            session.commitConfiguration()
            Task { @MainActor in self?.videoInput = input }
        }
    }

    nonisolated private static func device(for position: Position) -> AVCaptureDevice? {
        let pos: AVCaptureDevice.Position = position == .back ? .back : .front
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: pos)
    }

    // MARK: Recording

    /// Records until `stopRecording()` is called or `maxSeconds` passes, then calls `completion` with the file
    /// (nil when no camera is available — the UI still advances so the flow can be tried on the Simulator).
    func startRecording(maxSeconds: Double, completion: @escaping (URL?) -> Void) {
        guard !isRecording else { return }
        finish = completion
        isRecording = true
        recordedSeconds = 0
        let start = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.recordedSeconds = Date().timeIntervalSince(start)
                if self.recordedSeconds >= maxSeconds { self.stopRecording() }
            }
        }
        guard isAvailable, access == .granted else { return }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("take-\(UUID().uuidString).mov")
        let output = movieOutput
        queue.async { [weak self] in
            guard let self else { return }
            output.startRecording(to: url, recordingDelegate: self)
        }
    }

    func stopRecording() {
        guard isRecording else { return }
        timer?.invalidate()
        timer = nil
        isRecording = false
        if isAvailable, access == .granted {
            let output = movieOutput
            queue.async { output.stopRecording() }   // delegate delivers the file
        } else {
            deliver(nil)
        }
    }

    private func deliver(_ url: URL?) {
        let done = finish
        finish = nil
        done?(url)
    }
}

extension CameraService: AVCaptureFileOutputRecordingDelegate {
    nonisolated func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL,
                                from connections: [AVCaptureConnection], error: Error?) {
        Task { @MainActor in
            self.deliver(error == nil ? outputFileURL : nil)
        }
    }
}

/// Live camera preview layer.
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    final class PreviewView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }

    func makeUIView(context: Context) -> PreviewView {
        let v = PreviewView()
        v.previewLayer.session = session
        v.previewLayer.videoGravity = .resizeAspectFill
        v.backgroundColor = .black
        return v
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {}
}
