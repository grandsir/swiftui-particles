//
//  Fire.swift
//
//
//  Created by Ben Myers on 1/21/24.
//

import SwiftUI
import Particles
import Foundation

public extension Preset {
  
  struct Fire: Entity, PresetEntry {
    
    var metadata: PresetMetadata {
      .init(
        name: "Fire",
        target: "ParticlesPresets",
        description: "Heat up your SwiftUI views with fire particles.",
        author: "benlmyers",
        version: 1
      )
    }
    
    var color: Color
    var spawnPoint: UnitPoint
    var spawnRadius: CGSize
    var flameSize: CGFloat = 1.0
    var flameLifetime: TimeInterval = 1
    
    public var body: some Entity {
      Emitter(interval: 0.01) {
        Particle {
          RadialGradient(colors: [color, .clear], center: .center, startRadius: 2.0, endRadius: 25.0)
            .clipShape(Circle())
            .frame(width: 50.0 * flameSize, height: 50.0 * flameSize)
        }
        .initialOffset(xIn: -spawnRadius.width/2 ... spawnRadius.width/2, yIn: -spawnRadius.height/2 ... spawnRadius.height/2)
        .initialPosition(.center)
        .hueRotation(angleIn: .degrees(0.0) ... .degrees(50.0))
        .initialTorque(angleIn: .degrees(0.0) ... .degrees(8))
        .initialOffset(xIn: -spawnRadius.width/2 ... spawnRadius.width/2, yIn: -spawnRadius.height/2 ... spawnRadius.height/2)
        .initialVelocity(xIn: -0.2 ... 0.2, yIn: -0.3 ... 0.3)
        .fixAcceleration(y: -0.01)
        .lifetime(in: 1 +/- 0.2)
        .glow(.yellow.opacity(0.5), radius: 18.0)
        .blendMode(.plusLighter)
        .transition(.scale, on: .death, duration: 0.5)
      }
    }
    
    public init(color: Color = .red, spawnPoint: UnitPoint = .center, spawnRadius: CGSize = .init(width: 50.0, height: 4.0)) {
      self.color = color
      self.spawnPoint = spawnPoint
      self.spawnRadius = spawnRadius
    }
  }
}
