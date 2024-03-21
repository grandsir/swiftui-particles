//
//  ContentView.swift
//  ParticlesExample
//
//  Created by Ben Myers on 6/26/23.
//

import SwiftUI
import Particles
import ParticlesPresets

struct ContentView: View {
  
  var body: some View {
    ZStack {
      ParticleSystem {
        Burst(pixelDensity: 4) {
          v
        } withBehavior: { p in
          p
        } customView: {
          Circle().frame(width: 4.0, height: 4.0)
        }
        .initialOffset(y: 50.0)
      }
      .debug()
      ZStack(alignment: .topLeading) {
        Color.clear
        v.offset(y: 100.0)
      }
    }
    .frame(width: 400.0, height: 300.0)
  }
  
  var v: some View {
    Text("Hi, Ben!")
      .font(.system(size: 48))
      .fontWeight(.black)
      .foregroundStyle(LinearGradient(colors: [.red, .yellow, .teal], startPoint: .topLeading, endPoint: .bottomTrailing))
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
