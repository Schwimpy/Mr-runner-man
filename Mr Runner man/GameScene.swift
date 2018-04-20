//
//  GameScene.swift
//  Mr Runner man
//
//  Created by Simon Winther on 2018-04-16.
//  Copyright © 2018 Simon Winther. All rights reserved.
//

import SpriteKit
import GameplayKit

struct physicsCategory {
    static let playerPhysics : UInt32 = 0x1 << 1
    static let groundPhysics : UInt32 = 0x1 << 2
    static let enemyPhysics  : UInt32 = 0x1 << 3
    static let scorePhysics  : UInt32 = 0x1 << 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var ground     = SKSpriteNode()
    var background = SKSpriteNode()
    
    var player     = SKSpriteNode()
    var enemy      = SKSpriteNode()
    
    var scoreNode  = SKSpriteNode()
    var score      = Int()
    
    var canJump = false
    
    var moveAndRemove = SKAction()
    
    var playerAtlas = SKTextureAtlas()
    var enemyAtlas  = SKTextureAtlas()
    var playerArray = [SKTexture]()
    
    var gameStarted = Bool()
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        
        createGround()
        createBackground()
        playerRun()
        

    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameStarted == false {
            
            gameStarted = true
            
            moveEnemies()
            
            
        } else  {
           
            
        }
        
        if canJump {
            jump()
            canJump = false
        }
        
    }
    
    func jump() {
        player = SKSpriteNode(imageNamed: "playerGround")
        player = SKSpriteNode(imageNamed: "playerJump")
        player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 500))
    }

//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
//    }
//
//    func touchUp(atPoint pos: CGPoint) {
//        player = SKSpriteNode(imageNamed: "playerGround")
//        player = SKSpriteNode(imageNamed: playerAtlas.textureNames[0])
//    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        moveGround()
        moveBackground()
        
    }
    
                                            //Creates contact
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == physicsCategory.scorePhysics && secondBody.contactTestBitMask == physicsCategory.playerPhysics ||
           firstBody.categoryBitMask == physicsCategory.playerPhysics && secondBody.contactTestBitMask == physicsCategory.scorePhysics{
            
            score += 1
            print(score)
        }
        
        if firstBody.categoryBitMask == physicsCategory.playerPhysics && secondBody.contactTestBitMask == physicsCategory.groundPhysics ||
            firstBody.categoryBitMask == physicsCategory.groundPhysics && secondBody.contactTestBitMask == physicsCategory.playerPhysics{
            canJump = true
        }
    }
    
                                            //Creates player
    func playerRun() {
        playerAtlas = SKTextureAtlas(named: "player")
        
        for i in 1...playerAtlas.textureNames.count {
            
            let playerName = "playerRun\(i).png"
            playerArray.append(SKTexture(imageNamed: playerName))
        }
        
        player = SKSpriteNode(imageNamed: playerAtlas.textureNames[0])
        player.setScale(0.7)
        player.position = CGPoint(x: size.width * -0.2, y: size.height * -0.33)
        player.run(SKAction.repeatForever(SKAction.animate(with: playerArray, timePerFrame: 0.15)))
        
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.categoryBitMask = physicsCategory.playerPhysics
        player.physicsBody?.collisionBitMask = physicsCategory.groundPhysics | physicsCategory.enemyPhysics
        player.physicsBody?.contactTestBitMask = physicsCategory.groundPhysics | physicsCategory.enemyPhysics | physicsCategory.scorePhysics
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.isDynamic = true
        player.zPosition = 1
       // player = (self.childNode(withName: "player") as? SKSpriteNode)!
        
        self.addChild(player)
        
    }
    
                                //Creates and moves enemies and scoreNodes
    
    func createEnemies() {
        var whichEnemy : String
        let randomNr = Int(arc4random_uniform(3))
        var enemyArray  = [SKTexture]()
        
        if randomNr == 0 {
            whichEnemy = "enemy1"
        } else if randomNr == 1 {
            whichEnemy = "enemy2"
        } else {
            whichEnemy = "enemy3"
        }
        
        enemyAtlas = SKTextureAtlas(named: whichEnemy)
        
        for i in 1...enemyAtlas.textureNames.count {
            
            let enemyName = "enemy\(i).png"
            enemyArray.append(SKTexture(imageNamed: enemyName))
        }
        
        scoreNode = SKSpriteNode()
        scoreNode.size = CGSize(width: 1, height: 500)
        scoreNode.position = CGPoint(x: enemy.size.width, y: size.height * 0.4)
        scoreNode.physicsBody? = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.categoryBitMask = physicsCategory.scorePhysics
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = physicsCategory.playerPhysics
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.color = SKColor.blue
        
        
        enemy = SKSpriteNode(imageNamed: enemyAtlas.textureNames[0])
        enemy.setScale(0.7)
        enemy.run(SKAction.repeatForever(SKAction.animate(with: enemyArray, timePerFrame: 0.15)))
        enemy.position = CGPoint(x: size.width * 0.7, y: size.height * -0.21)
        
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.categoryBitMask = physicsCategory.enemyPhysics
        enemy.physicsBody?.collisionBitMask = physicsCategory.playerPhysics
        enemy.physicsBody?.contactTestBitMask = physicsCategory.playerPhysics
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.isDynamic = false
        
        enemy.addChild(scoreNode)
        enemy.run(moveAndRemove)
        enemy.zPosition = 1
        
        self.addChild(enemy)
        
    }
    
    func moveEnemies() {
        let spawn = SKAction.run ({
            () in
            
            self.createEnemies()
        })
        
        let delay = SKAction.wait(forDuration: 4.0)
        let spawnDelay = SKAction.sequence([spawn, delay])
        let spawnDelayForever =  SKAction.repeatForever(spawnDelay)
        self.run(spawnDelayForever)
        
        let distance = CGFloat(self.frame.width + enemy.frame.width)
        let moveEnemies = SKAction.moveBy(x: -distance, y: 0, duration: (TimeInterval(0.005 * distance)))
        let removeEnemies = SKAction.removeFromParent()
        
        moveAndRemove = SKAction.sequence([moveEnemies, removeEnemies])
    }
    
                                     //Creates and moves ground
    
    func createGround() {
        for i in 0...3 {
            
            ground = SKSpriteNode(imageNamed: "ground")
            ground.name = "Ground"
            ground.size = CGSize(width: (self.scene?.size.width)!, height: 100)
            ground.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            ground.position = CGPoint(x: CGFloat(i) * ground.size.width, y: -(self.frame.size.height / 2))
            
            ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
            ground.physicsBody?.categoryBitMask = physicsCategory.groundPhysics
            ground.physicsBody?.collisionBitMask = physicsCategory.playerPhysics
            ground.physicsBody?.contactTestBitMask = physicsCategory.playerPhysics
            ground.physicsBody?.affectedByGravity = false
            ground.physicsBody?.isDynamic = false
            ground.zPosition = 1
            
            self.addChild(ground)
        }
    }
    
    
    func moveGround() {
        
        self.enumerateChildNodes(withName: "Ground", using: ({
            (node, error) in
            
            node.position.x -= 2
            
            if node.position.x < -((self.scene?.size.width)!) {
                
                node.position.x += (self.scene?.size.width)! * 3
            }
        }))
    }
                                    //Creates and moves background
    
    func createBackground() {
        for i in 0...3 {
            background = SKSpriteNode(imageNamed: "background")
            background.name = "Background"
            background.size = CGSize(width: self.size.width * 8, height: (self.scene?.size.height)!)
            background.anchorPoint = CGPoint(x: 1.0, y: 0.0)
            background.position = CGPoint(x: CGFloat(i) * background.size.width, y: -(self.frame.size.height / 2))
            background.zPosition = 0
            self.addChild(background)
       }
    }

    func moveBackground() {
        self.enumerateChildNodes(withName: "Background", using: ({
            (node, error) in

            node.position.x -= 2

            if node.position.x < -((self.scene?.size.width)!) {

                node.position.x += (self.scene?.size.width)! * 3
            }
        }))
    }
}


























