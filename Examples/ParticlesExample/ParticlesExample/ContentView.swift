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
    ParticleSystem {
      Preset.Snow()
      Preset.Fire()
    }
    .debug()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
