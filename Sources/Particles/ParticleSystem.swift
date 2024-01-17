//
//  ParticleSystem.swift
//
//
//  Created by Ben Myers on 1/17/24.
//

import SwiftUI
import Foundation

/// A view used to display particles.
public struct ParticleSystem: View {
  
  internal typealias EntityID = UInt8
  internal typealias ProxyID = UInt16
  internal typealias GroupID = UInt8
  
  // MARK: - Stored Properties
  
  internal var data: Self.Data
  
  // MARK: - Computed Properties
  
  public var body: some View {
    GeometryReader { proxy in
      TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: false)) { [self] t in
        Canvas(opaque: true, colorMode: .linear, rendersAsynchronously: true, renderer: renderer) {
          Text("❌").tag("NOT_FOUND")
          ForEach(Array(data.viewPairs()), id: \.1) { (pair: (AnyView, EntityID)) in
            pair.0.tag(pair.1)
          }
        }
        .border(data.debug ? Color.red.opacity(0.5) : Color.clear)
        .overlay {
          HStack {
            VStack {
              debugView
              Spacer()
            }
            Spacer()
          }
        }
      }
    }
  }
  
  private var debugView: some View {
    VStack(alignment: .leading, spacing: 2.0) {
      Text(data.memorySummary())
        .lineLimit(99)
        .fixedSize(horizontal: false, vertical: false)
        .multilineTextAlignment(.leading)
    }
    .font(.caption2)
    .opacity(0.5)
  }
  
  // MARK: - Initalizers
  
  public init<E>(@EntityBuilder entity: () -> E) where E: Entity {
    let e: E = entity()
    self.data = .init()
    self.data.createSingle(entity: e)
  }
  
  // MARK: - Methods
  
  /// Enables debug mode for this particle system.
  /// When enabled, a border is shown around the system's edges.
  /// - Returns: A modified `ParticleSystem`
  public func debug() -> ParticleSystem {
    self.data.debug = true
    return self
  }
  
  private func renderer(_ context: inout GraphicsContext, size: CGSize) {
    self.data.systemSize = size
    data.updatePhysics()
    data.updateRenders()
    data.advanceFrame()
    data.emitChildren()
    data.performRenders(&context)
  }
}
