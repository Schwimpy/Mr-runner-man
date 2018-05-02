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
   static let playerPhysics : UInt32 = 0x1 << 0
   static let groundPhysics : UInt32 = 0x1 << 1
   static let enemyPhysics  : UInt32 = 0x1 << 2
//   static let scorePhysics  : UInt32 = 0x1 << 3
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var ground     = SKSpriteNode()
    var background = SKSpriteNode()
    var grass      = SKSpriteNode()
    
    var player     = SKSpriteNode()
    var enemy      = SKSpriteNode()
    
//    var scoreNode  = SKSpriteNode()
    var score      = Int()
    var scoreLabel = SKLabelNode()
    var timer      = Int()
    var restartButton = SKSpriteNode()
    
    var canJump    = false
    var playerDied = Bool()
    
    var moveAndRemove = SKAction()
    
    var playerAtlas = SKTextureAtlas()
    var enemyAtlas  = SKTextureAtlas()
    var playerArray = [SKTexture]()
    var gameOverAtlas = SKTextureAtlas()
    
    var gameStarted = Bool()
    
    
    override func didMove(to view: SKView) {
        
       createGame()
    
    }
    
    func createGame(){
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.physicsWorld.contactDelegate = self
        
        scoreLabel.position = CGPoint(x: 0, y: 120)
        scoreLabel.text = "Press To Start"
        scoreLabel.name = "Scorelabel"
        scoreLabel.fontColor = SKColor.white
        scoreLabel.fontSize = 70
        scoreLabel.zPosition = 5
        addChild(scoreLabel)
        
        createGroundAndGrass()
        createBackground()
        playerRun()
            }

    func restartGame(){
    
        self.removeAllChildren()
        self.removeAllActions()
        playerDied = false
        gameStarted = false
        score = 0
        createGame()
    
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameStarted == false {
            
            gameStarted = true
            scoreLabel.text = "Seconds Survived \(score)"
            moveEnemiesAndScoreNodes()
            timertimer()

        
            
        }
        
        if canJump {
            jump()
            canJump = false
        }
        
        for touch in touches {
            
            let location = touch.location(in: self)
            
            if playerDied == true {
                if restartButton.contains(location) {
                    restartGame()
                }
                
                
            }
        }
    }
    
    func timertimer() {
        let wait = SKAction.wait(forDuration:1)
        let action = SKAction.run {
            self.score += 1
            self.updateScore()
        }
        run(SKAction.repeatForever(SKAction.sequence([wait,action])))
    }
    
    func updateScore() {
        scoreLabel.removeFromParent()
        scoreLabel.text = "Seconds Survived \(score)"
        addChild(scoreLabel)
    }
    
    func jump() {
        if playerDied == true {
            
        } else {
        player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 500))
        }
    
    }

//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//    }
//
//    func touchUp(atPoint pos: CGPoint) {
//
//    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        moveGround()
        moveBackground()
    }
    
    func createRestartButton() {
        
        var gameOverArray  = [SKTexture]()
        
        gameOverAtlas = SKTextureAtlas(named: "gameover")
        
        for i in 1...gameOverAtlas.textureNames.count {
            
            let gameOverName = "gameover\(i).png"
            gameOverArray.append(SKTexture(imageNamed: gameOverName))
        }
        restartButton = SKSpriteNode(imageNamed: gameOverAtlas.textureNames[0])
        restartButton.run(SKAction.repeatForever(SKAction.animate(with: gameOverArray, timePerFrame: 0.5)))
        restartButton.position = CGPoint(x: 0, y: -50)
        restartButton.zPosition = 6
        restartButton.setScale(0)
        addChild(restartButton)
        
        restartButton.run(SKAction.scale(to: 1.0, duration: 2))
        
    }
    
    
    
                                            //Creates contact
    
    func didBegin(_ contact: SKPhysicsContact) {
        
//        let scoreCollision:UInt32 = contact.bodyA.contactTestBitMask | contact.bodyB.contactTestBitMask
//
//        if scoreCollision == physicsCategory.playerPhysics | physicsCategory.scorePhysics {
//            score += 1
//            print("score ")
//        }
        
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        //print("\(firstBody.node?.name) vs \(secondBody.node?.name)")
//        if firstBody.node?.name == "Player" && secondBody.node?.name == "ScoreNode" ||
//           firstBody.node?.name == "ScoreNode" && secondBody.node?.name == "Player" {
//
//            score += 1
//            scoreLabel.text = String(score)
//            print("ScoreNode hit")
//        }
        
        if firstBody.node?.name == "Player" && secondBody.node?.name == "Ground" ||
           firstBody.node?.name == "Ground" && secondBody.node?.name == "Player" {
            
            canJump = true
            print("Jumped")
        }
        
        if firstBody.node?.name == "Player" && secondBody.node?.name == "Enemy" ||
           firstBody.node?.name == "Enemy" && secondBody.node?.name == "Player" {
            
            
            enumerateChildNodes(withName: "Enemy", using: ({
                (node, error) in
                node.speed = 0
                self.removeAllActions()
            }))
            enumerateChildNodes(withName: "Player", using: ({
                (node, error) in
                node.speed = 0
                self.removeAllActions()
            }))
          
            if playerDied == false {
                print("died")
                playerDied = true
                createRestartButton()
            }
            
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
        player.name = "Player"
        player.setScale(0.7)
        player.position = CGPoint(x: size.width * -0.2, y: size.height * -0.33)
        player.run(SKAction.repeatForever(SKAction.animate(with: playerArray, timePerFrame: 0.15)))
        
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.categoryBitMask = physicsCategory.playerPhysics
        player.physicsBody?.collisionBitMask = physicsCategory.groundPhysics | physicsCategory.enemyPhysics
        player.physicsBody?.contactTestBitMask = physicsCategory.groundPhysics | physicsCategory.enemyPhysics
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.isDynamic = true
        player.zPosition = 1
        
        self.addChild(player)
        
    }
    
                                //Creates and moves enemies and scorenodes
    
    func createEnemiesAndScoreNodes() {
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
        
//        scoreNode = SKSpriteNode(imageNamed: "playerJump")
//        scoreNode.name = "ScoreNode"
//        scoreNode.size = CGSize(width: 500, height: 500)
//        scoreNode.position = CGPoint(x: enemy.size.width, y: size.height * 0.4)
//        scoreNode.physicsBody? = SKPhysicsBody(rectangleOf: scoreNode.size)
//        scoreNode.physicsBody?.categoryBitMask = physicsCategory.scorePhysics
//        scoreNode.physicsBody?.affectedByGravity = false
//        scoreNode.physicsBody?.isDynamic = false
//        scoreNode.color = SKColor.blue
        
        
        enemy = SKSpriteNode(imageNamed: enemyAtlas.textureNames[0])
        enemy.name = "Enemy"
        enemy.setScale(0.7)
        enemy.run(SKAction.repeatForever(SKAction.animate(with: enemyArray, timePerFrame: 0.15)))
        enemy.position = CGPoint(x: size.width * 0.7, y: size.height * -0.25)
        
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.categoryBitMask = physicsCategory.enemyPhysics
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.isDynamic = false
        
        enemy.run(moveAndRemove)
        enemy.zPosition = 1
        
//        enemy.addChild(scoreNode)
        self.addChild(enemy)
        
    }
    
    func moveEnemiesAndScoreNodes() {
        let spawn = SKAction.run ({
            () in
            
            self.createEnemiesAndScoreNodes()
        })
        
        let delay = SKAction.wait(forDuration: 4.0)
        let spawnDelay = SKAction.sequence([spawn, delay])
        let spawnDelayForever = SKAction.repeatForever(spawnDelay)
        self.run(spawnDelayForever)
        
        let distance = CGFloat(self.frame.width)
        let moveEnemies = SKAction.moveBy(x: -distance, y: 0, duration: (TimeInterval(0.003 * distance)))
        let removeEnemies = SKAction.removeFromParent()
            
        
        moveAndRemove = SKAction.sequence([moveEnemies, removeEnemies])
    }
    
                                     //Creates and moves ground & grass
    
    func createGroundAndGrass() {
        for i in 0...3 {
            
            ground = SKSpriteNode(imageNamed: "ground")
            ground.name = "Ground"
            ground.size = CGSize(width: (self.scene?.size.width)!, height: 80)
            ground.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            ground.position = CGPoint(x: CGFloat(i) * ground.size.width, y: -(self.frame.size.height / 2))
            
            ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
            ground.physicsBody?.categoryBitMask = physicsCategory.groundPhysics
            ground.physicsBody?.collisionBitMask = physicsCategory.playerPhysics
            ground.physicsBody?.contactTestBitMask = physicsCategory.playerPhysics
            ground.physicsBody?.affectedByGravity = false
            ground.physicsBody?.isDynamic = false
            ground.zPosition = 1
            
            grass = SKSpriteNode(imageNamed: "grass")
            grass.name = "Grass"
            grass.size = CGSize(width: (self.scene?.size.width)!, height: 100)
            grass.anchorPoint = CGPoint(x: 0.5, y: 0.2)
            grass.position = CGPoint(x: CGFloat(i) * grass.size.width, y: -(self.frame.size.height / 2))
            grass.zPosition = 4
            //grass.speed
            
            self.addChild(ground)
            self.addChild(grass)
        }
    }
    
    
    func moveGround() {
        
        self.enumerateChildNodes(withName: "Grass", using: ({
            (node, error) in
            
            let bg = node as! SKSpriteNode
            
            bg.position = CGPoint(x: bg.position.x - 20, y: bg.position.y)
            
            if bg.position.x < -((self.scene?.size.width)!){
                bg.position.x += (self.scene?.size.width)! * 3
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

            let bg = node as! SKSpriteNode
            
            bg.position = CGPoint(x: bg.position.x - 10, y: bg.position.y)
            
            if bg.position.x < -((self.scene?.size.width)!){
                bg.position.x += (self.scene?.size.width)! * 3
            }
//            node.position.x -= 2
//
//            if node.position.x < -((self.scene?.size.width)!) {
//
//                node.position.x += (self.scene?.size.width)! * 3
//            }
        }))
    }
}


























