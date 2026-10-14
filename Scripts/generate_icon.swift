import AppKit

func generateIcon() {
    let size = NSSize(width: 1024, height: 1024)
    let image = NSImage(size: size)

    image.lockFocus()

    guard let ctx = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return
    }

    // 1. Background Squircle (macOS Big Sur+ icon shape)
    let rect = CGRect(x: 100, y: 100, width: 824, height: 824)
    let path = CGPath(roundedRect: rect, cornerWidth: 180, cornerHeight: 180, transform: nil)

    // Shadow
    ctx.setShadow(offset: CGSize(width: 0, height: -30), blur: 50, color: NSColor.black.withAlphaComponent(0.35).cgColor)

    // Gradient Background
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let colors = [
        NSColor(calibratedRed: 0.08, green: 0.12, blue: 0.24, alpha: 1.0).cgColor,
        NSColor(calibratedRed: 0.12, green: 0.18, blue: 0.38, alpha: 1.0).cgColor,
        NSColor(calibratedRed: 0.18, green: 0.10, blue: 0.40, alpha: 1.0).cgColor
    ] as CFArray

    if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0.0, 0.5, 1.0]) {
        ctx.saveGState()
        ctx.addPath(path)
        ctx.clip()
        ctx.drawLinearGradient(gradient, start: CGPoint(x: 100, y: 924), end: CGPoint(x: 924, y: 100), options: [])

        // Inner glowing ring
        let innerRect = rect.insetBy(dx: 40, dy: 40)
        let innerPath = CGPath(roundedRect: innerRect, cornerWidth: 150, cornerHeight: 150, transform: nil)
        ctx.setStrokeColor(NSColor(calibratedRed: 0.3, green: 0.7, blue: 1.0, alpha: 0.4).cgColor)
        ctx.setLineWidth(14)
        ctx.addPath(innerPath)
        ctx.strokePath()

        // Circular hard disk platter
        let diskRect = CGRect(x: 230, y: 230, width: 564, height: 564)
        ctx.setFillColor(NSColor(calibratedRed: 0.05, green: 0.08, blue: 0.18, alpha: 0.9).cgColor)
        ctx.fillEllipse(in: diskRect)

        ctx.setStrokeColor(NSColor(calibratedRed: 0.0, green: 0.8, blue: 1.0, alpha: 0.8).cgColor)
        ctx.setLineWidth(16)
        ctx.strokeEllipse(in: diskRect)

        // Sweeping Speed Arc
        let arcColors = [
            NSColor(calibratedRed: 0.0, green: 0.9, blue: 0.8, alpha: 0.9).cgColor,
            NSColor(calibratedRed: 0.5, green: 0.2, blue: 1.0, alpha: 0.9).cgColor
        ] as CFArray
        if let arcGrad = CGGradient(colorsSpace: colorSpace, colors: arcColors, locations: [0.0, 1.0]) {
            let diskInner = diskRect.insetBy(dx: 50, dy: 50)
            ctx.setStrokeColor(NSColor.cyan.cgColor)
            ctx.setLineWidth(24)
            ctx.strokeEllipse(in: diskInner)
        }

        // Center Sparkle / Lightning Icon
        let centerPoint = CGPoint(x: 512, y: 512)
        ctx.setFillColor(NSColor(calibratedRed: 0.2, green: 0.9, blue: 1.0, alpha: 1.0).cgColor)
        
        let starPath = CGMutablePath()
        starPath.move(to: CGPoint(x: 512, y: 670))
        starPath.addLine(to: CGPoint(x: 545, y: 545))
        starPath.addLine(to: CGPoint(x: 670, y: 512))
        starPath.addLine(to: CGPoint(x: 545, y: 479))
        starPath.addLine(to: CGPoint(x: 512, y: 354))
        starPath.addLine(to: CGPoint(x: 479, y: 479))
        starPath.addLine(to: CGPoint(x: 354, y: 512))
        starPath.addLine(to: CGPoint(x: 479, y: 545))
        starPath.closeSubpath()

        ctx.addPath(starPath)
        ctx.fillPath()

        ctx.restoreGState()
    }

    image.unlockFocus()

    // Save 1024x1024 png
    if let tiff = image.tiffRepresentation,
       let rep = NSBitmapImageRep(data: tiff),
       let png = rep.representation(using: .png, properties: [:]) {
        let outURL = URL(fileURLWithPath: "Resources/AppIcon_1024.png")
        try? png.write(to: outURL)
        print("Generated AppIcon_1024.png successfully")
    }
}

generateIcon()
