//
//  Builder.swift
//  
//
//  Created by Ben Myers on 6/26/23.
//

import SwiftUI

@resultBuilder
public struct Builder<Block> {
  
  public static func buildBlock(_ parts: Block...) -> [Block] {
    return parts
  }
  
  static func buildEither(first component: Block) -> [Block] {
    return [component]
  }
  
  static func buildEither(second component: Block) -> [Block] {
    return [component]
  }
  
  static func buildArray(_ components: [Block]) -> [Block] {
    return components
  }
}
