//
//  ParticleSystem.swift
//
//
//  Created by Ben Myers on 10/2/23.
//

import SwiftUI
import Dispatch
import Foundation

/// A particle system declaration.
///
/// This creates a `Canvas`, with a greedy size, displaying a system of configurable particles and other entities.
/// To add entities to the system, declare them within ``ParticleSystem`` inside a `View`:
///
/// ```swift
/// var body: some View {
///   Text("Here's a particle system:")
///   ParticleSystem {
///     Emitter {
///       Particle(color: .green)
///     }
///   }
/// }
/// ```
public struct ParticleSystem: View {
  
  // MARK: - Properties
  
  private var colorMode: ColorRenderingMode = .nonLinear
  private var async: Bool = true
  
  private var data: Self.Data
  
  // MARK: - Body View
  
  public var body: some View {
    GeometryReader { proxy in
      TimelineView(.animation(paused: false)) { [self] t in
        Canvas(opaque: true, colorMode: colorMode, rendersAsynchronously: async, renderer: renderer) {
          Text("❌").tag("NOT_FOUND")
          ForEach(Array(data.views), id: \.tag) { taggedView in
            taggedView.view.tag(taggedView.tag)
          }
        }
        .border(Color.red.opacity(data.debug ? 1.0 : 0.1))
        .onChange(of: t.date) { _ in
          destroyExpired()
        }
      }
      .task {
        data.systemSize = proxy.size
      }
    }
  }
  
  // MARK: - Initalizers
  
  /// Creates a particle system using the declared entities.
  /// - Parameters:
  ///   - data: The particle system's data. Provide your own to enable state updates.
  ///   - entities: Any number of ``Entity``s, such as ``Particle``s or ``Emitter``s.
  public init(data: Self.Data = .init(), @Builder<Entity> entities: @escaping () -> [Entity]) {
    self.data = data
    self.data.refresh(entities())
  }
  
  // MARK: - Methods
  
  func renderer(context: inout GraphicsContext, size: CGSize) {
//    self.data.systemSize = size
    for proxy in data.proxies {
      proxy.onUpdate(&context)
    }
  }
  
  func destroyExpired() {
    data.proxies.removeAll { proxy in
      let kill = Date() >= proxy.expiration
      if kill {
        proxy.onDeath()
      }
      return kill
    }
  }
  
  // MARK: - Subtypes
  
  public class Data {
    
    // MARK: - Properties
    
    var prepared: Bool = false
    var views: Set<AnyTaggedView> = .init()
    var proxies: [Entity.Proxy] = []
    var debug: Bool = false
    
    private var rootEntities: [Entity] = []
    
    private var entityStructure: [EntityStructure] {
      return transform(rootEntities)
    }
    
    public internal(set) var systemSize: CGSize = .zero
    
    // MARK: - Initalizers
    
    public init() {}
    
    // MARK: - Methods
    
    func addProxy(_ proxy: Entity.Proxy) {
      Task {
        self.proxies.append(proxy)
      }
    }
    
    func refresh(_ entities: [Entity]) {
      if prepared {
        update(rootEntities, with: entities)
      } else {
        prepare(entities)
      }
    }
    
    private func prepare(_ entities: [Entity]) {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [self] in
        self.proxies = entities.map({ $0.makeProxy(source: nil, data: self) })
        self.rootEntities = entities
        self.prepared = true
        for proxy in self.proxies {
          proxy.onBirth(nil)
        }
      }
    }
    
    private func update(_ entities: [Entity], with new: [Entity]) {
      guard entities.count == new.count else {
        // FIXME: Improve
        fatalError("Something went wrong.")
      }
      for (current, new) in zip(entities, new) {
        current.updateBehaviors(from: new)
        if let currentEmitter = current as? Emitter, let newEmitter = new as? Emitter {
          update(currentEmitter.prototypes, with: newEmitter.prototypes)
        }
      }
    }
    
    private func transform(_ entities: [Entity]) -> [EntityStructure] {
      var result: [EntityStructure] = []
      for entity in entities {
        if let emitter = entity as? Emitter {
          result.append(.parent(emitter, transform(emitter.prototypes)))
        } else {
          result.append(.simple(entity))
        }
      }
      return result
    }
    
    // MARK: - Subtypes
    
    indirect enum EntityStructure {
      case simple(Entity)
      case parent(Entity, [EntityStructure])
    }
  }
}