//
//  HeatmapOverlayView.swift
//  HaushaltsHero
//
//  Created by AI Agent on 2025-11-18.
//

import SwiftUI

/// View for displaying a heatmap overlay on a photo
struct HeatmapOverlayView: View {

    // MARK: - Properties

    let image: UIImage
    let heatmapData: HeatmapData?
    @State private var showHeatmap: Bool = false

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            // Toggle Control
            if heatmapData != nil {
                HStack {
                    Text("Heatmap")
                        .font(.headline)

                    Spacer()

                    Toggle("", isOn: $showHeatmap)
                        .labelsHidden()
                }
                .padding(.horizontal)
            }

            // Image with Heatmap Overlay
            ZStack {
                // Base Image
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(12)

                // Heatmap Overlay
                if showHeatmap, let data = heatmapData {
                    GeometryReader { geometry in
                        HeatmapCanvas(
                            heatmapData: data,
                            size: geometry.size
                        )
                        .opacity(0.5)
                        .blendMode(.multiply)
                    }
                    .cornerRadius(12)
                }
            }
            .shadow(color: Color.black.opacity(0.1), radius: 10)

            // Legend
            if showHeatmap {
                HeatmapLegend()
                    .transition(.opacity)
            }
        }
    }
}

// MARK: - Heatmap Canvas

struct HeatmapCanvas: View {
    let heatmapData: HeatmapData
    let size: CGSize

    var body: some View {
        Canvas { context, size in
            let cellWidth = size.width / CGFloat(heatmapData.width)
            let cellHeight = size.height / CGFloat(heatmapData.height)

            for (y, row) in heatmapData.intensityMap.enumerated() {
                for (x, intensity) in row.enumerated() {
                    let rect = CGRect(
                        x: CGFloat(x) * cellWidth,
                        y: CGFloat(y) * cellHeight,
                        width: cellWidth,
                        height: cellHeight
                    )

                    let color = intensityToColor(intensity)
                    context.fill(
                        Path(roundedRect: rect, cornerRadius: 0),
                        with: .color(color)
                    )
                }
            }
        }
    }

    /// Convert intensity value (0-1) to color (blue -> yellow -> red)
    private func intensityToColor(_ intensity: Double) -> Color {
        // Blue (cold) to Red (hot) gradient
        if intensity < 0.5 {
            // Blue to Yellow
            let t = intensity * 2 // 0...1
            return Color(
                red: t,
                green: t,
                blue: 1.0 - t
            )
        } else {
            // Yellow to Red
            let t = (intensity - 0.5) * 2 // 0...1
            return Color(
                red: 1.0,
                green: 1.0 - t,
                blue: 0.0
            )
        }
    }
}

// MARK: - Heatmap Legend

struct HeatmapLegend: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Heatmap-Legende")
                .font(.caption)
                .fontWeight(.semibold)

            HStack(spacing: 4) {
                ForEach(0..<10) { i in
                    Rectangle()
                        .fill(intensityToColor(Double(i) / 9.0))
                        .frame(height: 20)
                }
            }
            .cornerRadius(4)

            HStack {
                Text("Wenig Verbesserung")
                    .font(.caption2)
                Spacer()
                Text("Viel Verbesserung")
                    .font(.caption2)
            }
            .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
        .padding(.horizontal)
    }

    private func intensityToColor(_ intensity: Double) -> Color {
        if intensity < 0.5 {
            let t = intensity * 2
            return Color(red: t, green: t, blue: 1.0 - t)
        } else {
            let t = (intensity - 0.5) * 2
            return Color(red: 1.0, green: 1.0 - t, blue: 0.0)
        }
    }
}

// MARK: - Preview

#Preview {
    let mockHeatmap = HeatmapData(
        width: 10,
        height: 10,
        intensityMap: (0..<10).map { y in
            (0..<10).map { x in
                let centerX = 5.0
                let centerY = 5.0
                let distance = sqrt(pow(Double(x) - centerX, 2) + pow(Double(y) - centerY, 2))
                let maxDistance = sqrt(pow(centerX, 2) + pow(centerY, 2))
                return max(0.0, 1.0 - (distance / maxDistance))
            }
        }
    )

    HeatmapOverlayView(
        image: UIImage(systemName: "photo")!,
        heatmapData: mockHeatmap
    )
}
