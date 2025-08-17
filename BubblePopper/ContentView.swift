//
//  ContentView.swift
//  BubblePopper
//
//  Created by Kamil Kohoutek on 13.08.2025.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    var scene: SKScene {
        let scene = GameScene()
        scene.size = CGSize(width: 400, height: 720)
        scene.scaleMode = .resizeFill
        return scene
    }
    
    var body: some View {
        SpriteView(scene: scene)
            // Utilize the entire screen
            .frame(minWidth: 0, maxWidth: .infinity)
            .edgesIgnoringSafeArea([.top, .bottom])
    }
}

#Preview {
    ContentView()
}
