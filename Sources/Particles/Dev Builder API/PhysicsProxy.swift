//
//  PhysicsProxy.swift
//
//
//  Created by Ben Myers on 1/17/24.
//

import SwiftUI
import Foundation

/// A proxy representing a single spawned entity's physics data within a ``ParticleSystem``.
public struct PhysicsProxy {
  
  // MARK: - Properties
  
  private var _x: UInt16
  private var _y: UInt16
  private var _inception: UInt16
  private var _rotation: UInt8
  private var _torque: Int8
  private var _randomSeed : SIMD4<UInt8>
  #if arch(arm64)
  private var _velX: Float16
  private var _velY: Float16
  private var _accX: Float16
  private var _accY: Float16
  private var _lifetime: Float16
  #else
  private var _velX: Float32
  private var _velY: Float32
  private var _accX: Float32
  private var _accY: Float32
  private var _lifetime: Float32
  #endif
  
  // MARK: - Initalizers
  init(currentFrame: Int) {
    _x = .zero
    _y = .zero
    _velX = .zero
    _velY = .zero
    _accX = .zero
    _accY = .zero
    _rotation = .zero
    _torque = .zero
    _inception = UInt16(currentFrame % Int(UInt16.max))
    _lifetime = 5.0
    _randomSeed = .random(in: .min ... .max)
  }
  
  // MARK: - Subtypes
  
  /// Context used to assist in updating the **physical properties** of a spawned entity.
  /// Every ``Context`` model carries properties that may be helpful in the creation of unique particle systems.
  public struct Context {
    
    // MARK: - Stored Properties
    
    public internal(set) var physics: PhysicsProxy
    
    public private(set) weak var system: ParticleSystem.Data!
    
    // MARK: - Computed Properties
    
    public var timeAlive: TimeInterval {
      return (Double(system.currentFrame) - Double(physics.inception)) / Double(system.averageFrameRate)
    }
    
    // MARK: - Initalizers
    
    init(physics: PhysicsProxy, system: ParticleSystem.Data) {
      self.physics = physics
      self.system = system
    }
  }
}

public extension PhysicsProxy {
  
  /// The position of the entity, in pixels.
  var position: CGPoint { get {
    CGPoint(x: (CGFloat(_x) - 250.0) / 10.0, y: (CGFloat(_y) - 250.0) / 10.0)
  } set {
    _x = UInt16(clamping: Int(newValue.x * 10.0) + 250)
    _y = UInt16(clamping: Int(newValue.y * 10.0) + 250)
  }}
  
  /// The velocity of the entity, in pixels **per frame**.
  var velocity: CGVector { get {
    CGVector(dx: CGFloat(_velX), dy: CGFloat(_velY))
  } set {
    _velX = .init(newValue.dx)
    _velY = .init(newValue.dy)
  }}
  
  /// The acceleration of the entity, in pixels **per frame per frame**.
  var acceleration: CGVector { get {
    CGVector(dx: CGFloat(_accX), dy: CGFloat(_accY))
  } set {
    _accX = .init(newValue.dx)
    _accY = .init(newValue.dy)
  }}
  
  /// The rotation angle of the entity.
  var rotation: Angle { get {
    Angle(degrees: Double(_rotation) * 1.41176)
  } set {
    let normalizedAngle = (newValue.degrees + 360.0).truncatingRemainder(dividingBy: 360.0)
    let angleRatio = normalizedAngle / 360.0
    _rotation = UInt8(angleRatio * 255)
//    _rotation = UInt8(Int(ceil((newValue.degrees.truncatingRemainder(dividingBy: 360.0) * 0.7083))) % Int(UInt8.max))
  }}
  
  /// The rotational torque angle of the entity **per frame**.
  var torque: Angle { get {
    Angle(degrees: Double(_torque) * 1.41176)
  } set {
    _torque = Int8(floor((newValue.degrees.truncatingRemainder(dividingBy: 360.0) * 0.7083)))
  }}
  
  /// The frame number upon which the entity was created.
  var inception: Int {
    Int(_inception)
  }
  
  /// The lifetime, in seconds, of the entity.
  var lifetime: Double { get {
    Double(_lifetime)
  } set {
    _lifetime = .init(newValue)
  }}
  
  /// Four random seeds that can be used to customize the behavior of spawned particles.
  /// Each of the integer values contains a value 0-255.
  var seed: (Int, Int, Int, Int) {
    (Int(_randomSeed.x), Int(_randomSeed.y), Int(_randomSeed.z), Int(_randomSeed.w))
  }
}
