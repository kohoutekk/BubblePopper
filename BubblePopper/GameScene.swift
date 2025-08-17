//
//  GameScene.swift
//  BubblePopper
//
//  Created by Kamil Kohoutek on 13.08.2025.
//

import SpriteKit

class GameScene: SKScene {
    
    private enum GameState {
        case playing
        case gameOver
    }
    
    private static let colors: [SKColor] = [
        .red, .blue, .green, .orange, .purple, .cyan, .yellow
    ]
    
    private static let popAction: SKAction = {
        let shrink = SKAction.scale(to: 0.1, duration: 0.16)
        shrink.timingMode = .easeInEaseOut
        let remove = SKAction.removeFromParent()
        return SKAction.sequence([shrink, remove])
    }()
    
    private let gameOverLabel: SKLabelNode = SKLabelNode(fontNamed: "Chalkduster")
    private let scoreLabel: SKLabelNode = SKLabelNode(fontNamed: "Chalkduster")
    
    private var score: Int = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }
    
    private var state: GameState = .playing
      
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = CGVector(dx: 0, dy: 3.5)
        backgroundColor = .white
        
        // Left edge
        let leftEdge = SKNode()
        leftEdge.physicsBody = SKPhysicsBody(
            edgeFrom: CGPoint(x: frame.minX, y: frame.minY),
            to: CGPoint(x: frame.minX, y: frame.maxY)
        )
        leftEdge.physicsBody?.isDynamic = false
        addChild(leftEdge)

        // Right edge
        let rightEdge = SKNode()
        rightEdge.physicsBody = SKPhysicsBody(
            edgeFrom: CGPoint(x: frame.maxX, y: frame.minY),
            to: CGPoint(x: frame.maxX, y: frame.maxY)
        )
        rightEdge.physicsBody?.isDynamic = false
        addChild(rightEdge)
        
        gameOverLabel.text = "Restart?"
        gameOverLabel.fontSize = 64
        gameOverLabel.fontColor = SKColor.black
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOverLabel.zPosition = .infinity
        gameOverLabel.isHidden = true
           
        addChild(gameOverLabel)
        
        scoreLabel.text = ""
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.fontSize = 27
        scoreLabel.fontColor = SKColor.black
        scoreLabel.position = CGPoint(x: 32, y: frame.maxY - 72)
        scoreLabel.zPosition = .infinity
        scoreLabel.isHidden = false
        
        addChild(scoreLabel)
        
        startBubbleSpawner()
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in self.children {
            if node.name != "Bubble" { continue }
            let isWithinBounds = node.position.y > self.frame.maxY + 72 && node.position.x > 0 && node.position.x < self.frame.maxX
            if isWithinBounds {
                // Remove bubble that crossed screen bounds from the scene
                node.removeFromParent()
                // During gameplay, this means a game over
                if state == .playing {
                    endGame()
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let node = atPoint(touch.location(in: self))
        guard node != self else { return }
        
        switch state {
        case .playing:
            if node.name == "Bubble" {
                // Bubble popping logic
                node.run(Self.popAction)
                if let worth = node.userData?["worth"] as? Int {
                    score += worth
                }
            }
        case .gameOver:
            if node == gameOverLabel {
                restartGame()
            }
        }
    }

    private func startBubbleSpawner() {
        let spawnAction = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: 0.25),
                SKAction.run { [weak self] in
                    self?.spawnBubble()
                }
            ])
        )
        run(spawnAction)
    }
    
    private func spawnBubble() {
        let radius = CGFloat.random(in: 24...72)
        
        let body = SKPhysicsBody(circleOfRadius: radius)
        body.affectedByGravity = true
        body.angularDamping = 2.0           // Slow rotation
        body.restitution = 0.9              // Soft bounce
        body.friction = 0.0                 // No sliding resistance
        body.linearDamping = radius / 20.0  // Larger radius → more damping
        body.velocity = (CGVector(dx: CGFloat.random(in: -80...80), dy: 0))
        
        let bubble = SKShapeNode(circleOfRadius: radius)
        bubble.name = "Bubble"
        bubble.userData = ["worth": Int(radius)]
        bubble.fillColor = Self.colors.randomElement() ?? .red
        bubble.strokeColor = .clear
        bubble.position = CGPoint(
            x: CGFloat.random(in: frame.minX + radius...frame.maxX - radius),
            y: -46
        )
        bubble.physicsBody = body

        addChild(bubble)
    }
    
    private func endGame() {
        state = .gameOver
        gameOverLabel.isHidden = false
    }
    
    private func restartGame() {
        state = .playing
        isPaused = false
        score = 0
        gameOverLabel.isHidden = true
        
        // Remove all bubbles
        for child in children {
            if child.name == "Bubble" {
                child.removeFromParent()
            }
        }
    }
}
