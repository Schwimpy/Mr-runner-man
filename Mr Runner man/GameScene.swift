//
//  GameScene.swift
//  Mr Runner man
//
//  Created by Simon Winther on 2018-04-16.
//  Copyright © 2018 Simon Winther. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

struct physicsCategory {
   static let playerPhysics : UInt32 = 0x1 << 0
   static let groundPhysics : UInt32 = 0x1 << 1
   static let enemyPhysics  : UInt32 = 0x1 << 2
//   static let scorePhysics  : UInt32 = 0x1 << 3
}

class GameScene: SKScene, SKPhysicsContactDelegate, AVAudioPlayerDelegate {
    
    var ground     = SKSpriteNode()
    var background = SKSpriteNode()
    var grass      = SKSpriteNode()
    
    var player     = SKSpriteNode()
    var enemy      = SKSpriteNode()
    
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
    
    var dancer1      = SKSpriteNode()
    var dancer1Atlas = SKTextureAtlas()
    
    var dancer2      = SKSpriteNode()
    var dancer2Atlas = SKTextureAtlas()
    
    var dancer3      = SKSpriteNode()
    var dancer3Atlas = SKTextureAtlas()
    
    var dancer4      = SKSpriteNode()
    var dancer4Atlas = SKTextureAtlas()
    
    var dancer5      = SKSpriteNode()
    var dancer5Atlas = SKTextureAtlas()
    
    var dancer6      = SKSpriteNode()
    var dancer6Atlas = SKTextureAtlas()
    
    var dancer7      = SKSpriteNode()
    var dancer7Atlas = SKTextureAtlas()
    
    var dancer8      = SKSpriteNode()
    var dancer8Atlas = SKTextureAtlas()
    
    var disco        = SKSpriteNode()
    var discoAtlas   = SKTextureAtlas()
    
    var gameStarted = Bool()
    
    var backgroundMusic = SKAction.playSoundFileNamed("backgroundmusic.mp3", waitForCompletion: false)
    var jumpSound       = SKAction.playSoundFileNamed("jump.mp3", waitForCompletion: false)
    var deathSound      = SKAction.playSoundFileNamed("death.mp3", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
       playBackgroundMusic(backgroundmusic: backgroundMusic)
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
        scoreLabel.zPosition = 15
        addChild(scoreLabel)
        createDisco()
        createDancers()
       
        
        
            }

    func restartGame(){
    
        self.removeAllChildren()
        self.removeAllActions()
        playerDied = false
        gameStarted = false
        score = 0
        createGame()
    
    }
    
    func playBackgroundMusic(backgroundmusic : SKAction) {
        run(backgroundmusic)
    }
    
    
    
    func playDeathSound(deathsound : SKAction) {
        run(deathsound)
    }
    
    func playJumpSound(jumpsound : SKAction) {
        run(jumpsound)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameStarted == false {
            
            self.removeAllChildren()
            self.removeAllActions()
            
            gameStarted = true
            createGroundAndGrass()
            createBackground()
            scoreLabel.text = "Seconds Survived \(score)"
            moveEnemies()
            timertimer()
            playerRun()

        
            
        }
        
        if canJump {
            
            jump()
            playJumpSound(jumpsound: jumpSound)
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
        restartButton.zPosition = 10
        restartButton.setScale(0)
        addChild(restartButton)
        
        restartButton.run(SKAction.scale(to: 1.0, duration: 2))
        
    }
    
    
    
                                            //Creates contact
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
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
                playDeathSound(deathsound: deathSound)
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
                                    //Creates dancers.
            //hade säkert gått att lägga i en loop som gjort mindre kod men hade brottom innan redovisningen
    
    func createDancers() {
        
        var dancer1Array = [SKTexture]()
        dancer1Atlas = SKTextureAtlas(named: "bat")
        for i in 1...dancer1Atlas.textureNames.count {
            let dancer1 = "bat\(i).png"
            dancer1Array.append(SKTexture(imageNamed: dancer1))
        }
        dancer1 = SKSpriteNode(imageNamed: dancer1Atlas.textureNames[0])
        dancer1.setScale(2)
        dancer1.run(SKAction.repeatForever(SKAction.animate(with: dancer1Array, timePerFrame: 0.15)))
        dancer1.position = CGPoint(x: -100, y: -100)
        dancer1.zPosition = 14
        addChild(dancer1)
        
        var dancer2Array = [SKTexture]()
        dancer2Atlas = SKTextureAtlas(named: "davis")
        for i in 1...dancer2Atlas.textureNames.count {
            let dancer2 = "davis\(i).png"
            dancer2Array.append(SKTexture(imageNamed: dancer2))
        }
        dancer2 = SKSpriteNode(imageNamed: dancer2Atlas.textureNames[0])
        dancer2.setScale(1.2)
        dancer2.run(SKAction.repeatForever(SKAction.animate(with: dancer2Array, timePerFrame: 0.10)))
        dancer2.position = CGPoint(x: 70, y: 50)
        dancer2.zPosition = 14
        addChild(dancer2)
        
        var dancer3Array = [SKTexture]()
        dancer3Atlas = SKTextureAtlas(named: "dennis")
        for i in 1...dancer3Atlas.textureNames.count {
            let dancer3 = "dennis\(i).png"
            dancer3Array.append(SKTexture(imageNamed: dancer3))
        }
        dancer3 = SKSpriteNode(imageNamed: dancer3Atlas.textureNames[0])
        dancer3.setScale(1.2)
        dancer3.run(SKAction.repeatForever(SKAction.animate(with: dancer3Array, timePerFrame: 0.10)))
        dancer3.position = CGPoint(x: -200, y: 20)
        dancer3.zPosition = 14
        addChild(dancer3)
        
        var dancer4Array = [SKTexture]()
        dancer4Atlas = SKTextureAtlas(named: "firen")
        for i in 1...dancer4Atlas.textureNames.count {
            let dancer4 = "firen\(i).png"
            dancer4Array.append(SKTexture(imageNamed: dancer4))
        }
        dancer4 = SKSpriteNode(imageNamed: dancer4Atlas.textureNames[0])
        dancer4.setScale(1.7)
        dancer4.run(SKAction.repeatForever(SKAction.animate(with: dancer4Array, timePerFrame: 0.10)))
        dancer4.position = CGPoint(x: -270, y: -70)
        dancer4.zPosition = 14
        addChild(dancer4)
        
        var dancer5Array = [SKTexture]()
        dancer5Atlas = SKTextureAtlas(named: "firzen")
        for i in 1...dancer5Atlas.textureNames.count {
            let dancer5 = "firzen\(i).png"
            dancer5Array.append(SKTexture(imageNamed: dancer5))
        }
        dancer5 = SKSpriteNode(imageNamed: dancer5Atlas.textureNames[0])
        dancer5.setScale(1.8)
        dancer5.run(SKAction.repeatForever(SKAction.animate(with: dancer5Array, timePerFrame: 0.10)))
        dancer5.position = CGPoint(x: 50, y: -80)
        dancer5.zPosition = 14
        addChild(dancer5)
        
        var dancer6Array = [SKTexture]()
        dancer6Atlas = SKTextureAtlas(named: "freeze")
        for i in 1...dancer6Atlas.textureNames.count {
            let dancer6 = "freeze\(i).png"
            dancer6Array.append(SKTexture(imageNamed: dancer6))
        }
        dancer6 = SKSpriteNode(imageNamed: dancer6Atlas.textureNames[0])
        dancer6.setScale(1.9)
        dancer6.run(SKAction.repeatForever(SKAction.animate(with: dancer6Array, timePerFrame: 0.10)))
        dancer6.position = CGPoint(x: 250, y: -100)
        dancer6.zPosition = 14
        addChild(dancer6)
        
        var dancer7Array = [SKTexture]()
        dancer7Atlas = SKTextureAtlas(named: "rudolf")
        for i in 1...dancer7Atlas.textureNames.count {
            let dancer7 = "rudolf\(i).png"
            dancer7Array.append(SKTexture(imageNamed: dancer7))
        }
        dancer7 = SKSpriteNode(imageNamed: dancer7Atlas.textureNames[0])
        dancer7.setScale(1.2)
        dancer7.run(SKAction.repeatForever(SKAction.animate(with: dancer7Array, timePerFrame: 0.10)))
        dancer7.position = CGPoint(x: -70, y: 40)
        dancer7.zPosition = 14
        addChild(dancer7)
        
        var dancer8Array = [SKTexture]()
        dancer8Atlas = SKTextureAtlas(named: "woody")
        for i in 1...dancer8Atlas.textureNames.count {
            let dancer8 = "woody\(i).png"
            dancer8Array.append(SKTexture(imageNamed: dancer8))
        }
        dancer8 = SKSpriteNode(imageNamed: dancer8Atlas.textureNames[0])
        dancer8.setScale(1.4)
        dancer8.run(SKAction.repeatForever(SKAction.animate(with: dancer8Array, timePerFrame: 0.10)))
        dancer8.position = CGPoint(x: 200, y: 30)
        dancer8.zPosition = 14
        addChild(dancer8)
    }
    
                                //Creates disco
    func createDisco() {
        
        var discoArray = [SKTexture]()
        discoAtlas = SKTextureAtlas(named: "disco")
        for i in 1...discoAtlas.textureNames.count {
            let discoRoom = "disco\(i).png"
            discoArray.append(SKTexture(imageNamed: discoRoom))
        }
        disco = SKSpriteNode(imageNamed: discoAtlas.textureNames[0])
        disco.run(SKAction.repeatForever(SKAction.animate(with: discoArray, timePerFrame: 0.10)))
        disco.size = CGSize(width: 800, height: 500)
        disco.position = CGPoint(x: 0, y: 0)
        disco.zPosition = 13
        addChild(disco)
    }
    
                                //Creates and moves enemies
    
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
        
        self.addChild(enemy)
        
    }
    
    func moveEnemies() {
        let spawn = SKAction.run ({
            () in
            
            self.createEnemies()
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
            grass.zPosition = 9
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
        }))
    }
}


























