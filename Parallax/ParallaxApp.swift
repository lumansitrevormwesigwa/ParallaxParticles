//
//  ParallaxApp.swift
//  Parallax
//
//  Created by pa.alekseev on 25.11.2025.
//

import SwiftUI
import Combine

struct Particle {
    var x: Double
    var y: Double
    var z: Double
    var size: Double
    var opacity: Double
    var wiggleAmount: Double
    var wiggleSpeed: Double

    static func random() -> Particle {
        let theta = Double.random(in: -Double.pi...Double.pi)
        let phi = Double.random(in: -Double.pi...Double.pi)
        let distance = Double.random(in: 0.3...0.8)

        return Particle(
            x: sin(theta) * cos(phi) * distance,
            y: sin(theta) * sin(phi) * distance,
            z: cos(theta) * distance,
            size: Double.random(in: 2...15),
            opacity: Double.random(in: 0.5...1),
            wiggleAmount: Double.random(in: 0.01...0.2),
            wiggleSpeed: Double.random(in: 0.0...0.2)
        )
    }
}

struct ParticlesView: View {
    let yaw: Double
    let pitch: Double

    @State private var points = (0...1000).map { _ in Particle.random() }

    var body: some View {
        TimelineView(.animation) { timeline in
            let points = points
            let time = timeline.date.timeIntervalSinceReferenceDate

            Canvas { context, size in
                for index in 0..<points.count {
                    let point = points[index]

                    // yaw
                    let x1 = cos(yaw) * point.x + sin(yaw) * point.z
                    let y1 = point.y
                    let z1 = -sin(yaw) * point.x + cos(yaw) * point.z

                    // pitch
                    var x = x1
                    var y = cos(pitch) * y1 - sin(pitch) * z1
                    var z = sin(pitch) * y1 + cos(pitch) * z1

                    // wiggle
                    let offset = time * point.wiggleSpeed + Double(index)
                    x += sin(offset) * point.wiggleAmount
                    y += cos(offset) * point.wiggleAmount
                    z += cos(offset) * point.wiggleAmount

                    let particleSize: Double = point.size + z

                    let rect = CGRect(
                        origin: CGPoint(
                            x: (x + 1.0)/2.0 * size.width - particleSize/2.0,
                            y: (y + 1.0)/2.0 * size.height - particleSize/2.0
                        ),
                        size: CGSize(
                            width: particleSize,
                            height: particleSize
                        ))
                    let opacity = point.opacity * (z + 1.0)/2.0
                    context.fill(Circle().path(in: rect), with: .color(.white.opacity(opacity)))
                }
            }
        }
    }
}

struct ContentView: View {
    @State private var yaw = 0.0
    @State private var pitch = 0.0

    var body: some View {
        VStack {
            ParticlesView(yaw: yaw, pitch: pitch)
                .ignoresSafeArea()
                .aspectRatio(1, contentMode: .fill)

            Slider(value: $yaw, in: -Double.pi...Double.pi).padding(.horizontal)
            Slider(value: $pitch, in: -Double.pi...Double.pi).padding(.horizontal)
        }
        .background(.black)
    }
}


@main
struct ParallaxApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

#Preview {
    ContentView()
}
