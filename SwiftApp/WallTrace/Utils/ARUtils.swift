import ARKit

func selectBest16x9VideoFormat() -> ARConfiguration.VideoFormat? {
    let formats = ARWorldTrackingConfiguration.supportedVideoFormats

    // Filter formats with ~16:9 aspect ratio
    let sixteenByNineFormats = formats.filter { format in
        let width = Float(format.imageResolution.width)
        let height = Float(format.imageResolution.height)
        let aspect = width / height
        return abs(aspect - (16.0 / 9.0)) < 0.01
    }

    if sixteenByNineFormats.isEmpty {
        print("⚠️ No native 16:9 video formats available on this device.")
        return nil
    }

    // Choose highest resolution among 16:9 formats
    let best = sixteenByNineFormats.max(by: {
        $0.imageResolution.width * $0.imageResolution.height <
        $1.imageResolution.width * $1.imageResolution.height
    })

    if let best = best {
        print("✅ Selected 16:9 video format: \(best.imageResolution.width)x\(best.imageResolution.height) @ \(best.framesPerSecond)fps")
    }

    return best
}

