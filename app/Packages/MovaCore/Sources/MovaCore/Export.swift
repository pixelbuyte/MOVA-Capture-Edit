import Foundation

public enum ExportResolution: String, CaseIterable, Codable, Sendable {
    case hd1080 = "1080p", uhd4k = "4K"

    /// Portrait pixel size.
    public var size: (width: Int, height: Int) {
        switch self {
        case .hd1080: (1080, 1920)
        case .uhd4k: (2160, 3840)
        }
    }

    /// HEVC bitrate we export at, in megabits per second, at 30 fps.
    var baseMbps: Double {
        switch self {
        case .hd1080: 12
        case .uhd4k: 40
        }
    }
}

public enum ExportFrameRate: Int, CaseIterable, Codable, Sendable {
    case fps24 = 24, fps30 = 30, fps60 = 60
}

public struct ExportSettings: Codable, Hashable, Sendable {
    public var resolution: ExportResolution
    public var frameRate: ExportFrameRate

    public init(resolution: ExportResolution = .uhd4k, frameRate: ExportFrameRate = .fps30) {
        self.resolution = resolution
        self.frameRate = frameRate
    }

    /// Estimated file size in megabytes for a clip of `duration` seconds (video + 256 kbps AAC audio).
    public func estimatedMegabytes(duration: Double) -> Int {
        let videoMbps = resolution.baseMbps * (Double(frameRate.rawValue) / 30).squareRoot()
        let totalMbps = videoMbps + 0.256
        return max(1, Int((totalMbps * duration / 8).rounded()))
    }

    /// "HEVC · 2160 × 3840 · 30 fps"
    public var summary: String {
        let s = resolution.size
        return "HEVC · \(s.width) × \(s.height) · \(frameRate.rawValue) fps"
    }
}

/// Steps of an on-device export, in order.
public enum ExportStep: String, CaseIterable, Sendable {
    case renderingClips = "Rendering clips"
    case applyingLook = "Applying look"
    case mixingAudio = "Mixing audio"
    case saving = "Saving"

    /// Share of total export time each step takes.
    var weight: Double {
        switch self {
        case .renderingClips: 0.5
        case .applyingLook: 0.2
        case .mixingAudio: 0.2
        case .saving: 0.1
        }
    }

    /// Which step is running at overall progress `p` (0…1).
    public static func current(at p: Double) -> ExportStep {
        var acc = 0.0
        for step in allCases {
            acc += step.weight
            if p < acc { return step }
        }
        return .saving
    }
}

/// Formats seconds as "0:05.8".
public func timecode(_ seconds: Double) -> String {
    let s = max(0, seconds)
    let m = Int(s) / 60
    let rem = s - Double(m * 60)
    return String(format: "%d:%04.1f", m, rem)
}
