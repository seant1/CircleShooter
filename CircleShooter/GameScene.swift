//
//  GameScene.swift
//  CircleShooter
//
//  Created by Lai Phong Tran on 9/5/17.
//  Copyright © 2017 Lai Phong Tran. All rights reserved.
//

import SpriteKit
import GameplayKit


struct PhysicsCategory {
    static let none      : UInt32 = 0
    static let all       : UInt32 = UInt32.max
    static let monster   : UInt32 = 0b1       // 1
    static let bullet    : UInt32 = 0b10      // 2
    static let bigBullet    : UInt32 = 0b11      // 2
}

var hueWheel = 0.00
var score = 0


class GameScene: SKScene {
    
    let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
    var shooter = SKSpriteNode(imageNamed: "boost_0")
    
    override func didMove(to view: SKView) {
        
        backgroundColor = SKColor(hue: 0.6, saturation: 0.2, brightness: 0.1, alpha: 1)
        
        shooter.size = CGSize(width: 100,height: 100)
        shooter.position = CGPoint(x: frame.width / 2, y: frame.height * 0.25)
        //shooter.color = UIColor.green
        //shooter.colorBlendFactor = 1
        addChild(shooter)

        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        border.friction = 0
        border.restitution = 0.5//1.75//0.5
        self.physicsBody = border
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(gesture:)))
        downSwipe.direction = .down
        view.addGestureRecognizer(downSwipe)
        
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(gesture:)))
        upSwipe.direction = .up
        view.addGestureRecognizer(upSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(gesture:)))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(gesture:)))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
        
        let touchHold = UILongPressGestureRecognizer(target: self, action: #selector(holdAction(gesture:)))
        view.addGestureRecognizer(touchHold)
        
        // monster repeater
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addMonster),
                SKAction.wait(forDuration: 0.02),
                ])
        ))
        
        score = 0
        scoreLabel.text = String(score)
        scoreLabel.fontSize = 40
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(scoreLabel)
        
        // game end timer
        run(SKAction.sequence([SKAction.wait(forDuration: 6),
                               SKAction.run() { [weak self] in
                                guard let `self` = self else { return }
                                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                                let gameOverScene = MenuScene(size: self.size)
                                self.view?.presentScene(gameOverScene, transition: reveal)
            }]))
        
        // music
        let backgroundMusic = SKAudioNode(fileNamed: "lofi test v02.wav")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
    }
    
    @objc func swipeAction(gesture:UISwipeGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.down:
                self.physicsWorld.gravity = CGVector(dx: 0, dy: -5)
                print("down")
            case UISwipeGestureRecognizer.Direction.up:
                self.physicsWorld.gravity = CGVector(dx: 0, dy: 5)
                print("up")
            case UISwipeGestureRecognizer.Direction.left:
                self.physicsWorld.gravity = CGVector(dx: -5, dy: 0)
                print("left")
            case UISwipeGestureRecognizer.Direction.right:
                self.physicsWorld.gravity = CGVector(dx: 5, dy: 0)
                print("right")
            default: break
            }
        }
    }
    
    @objc func holdAction(gesture:UILongPressGestureRecognizer) {
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        print("hold")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let bigBullet = SKSpriteNode(imageNamed: "boost_0")
            let moveToTouch = SKAction.moveTo(x: location.x, duration: 0.2)
            moveToTouch.timingMode = SKActionTimingMode.easeInEaseOut
            shooter.run(moveToTouch)
            //shooter.position.x = location.x
            
            bigBullet.position = shooter.position
            bigBullet.size = CGSize(width: 30, height: 30)
            bigBullet.physicsBody = SKPhysicsBody(circleOfRadius: bigBullet.size.width * 0.4)
            bigBullet.physicsBody?.affectedByGravity = true
            //bigBullet.physicsBody?.friction = 0
            bigBullet.physicsBody?.restitution = 1.25
            bigBullet.physicsBody?.isDynamic = true
            bigBullet.physicsBody?.categoryBitMask = PhysicsCategory.bigBullet
            bigBullet.physicsBody?.contactTestBitMask = PhysicsCategory.monster
            bigBullet.physicsBody?.collisionBitMask = PhysicsCategory.all
            bigBullet.physicsBody?.usesPreciseCollisionDetection = true
            
            addChild(bigBullet)
            
            var dx = CGFloat(location.x - shooter.position.x)
            var dy = CGFloat(location.y - shooter.position.y)
            
            let magnitude = sqrt(dx * dx + dy * dy)
            
            dx /= magnitude
            dy /= magnitude
            
            let vector = CGVector(dx: 30 * dx, dy: 30 * dy)
            
            bigBullet.physicsBody?.applyImpulse(vector)
            

        }
    }
    

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let bullet = SKSpriteNode(imageNamed: "square")

            bullet.position = shooter.position
            bullet.size = CGSize(width: 20, height: 20)
            bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)//circleOfRadius: bullet.size.width * 0.4)
            bullet.physicsBody?.affectedByGravity = true
            bullet.physicsBody?.isDynamic = true
            bullet.physicsBody?.categoryBitMask = PhysicsCategory.bullet
            bullet.physicsBody?.contactTestBitMask = PhysicsCategory.monster
            //bullet.physicsBody?.collisionBitMask = PhysicsCategory.none
            bullet.physicsBody?.usesPreciseCollisionDetection = true
            bullet.color = SKColor(hue: CGFloat(hueWheel), saturation: 1, brightness: 1, alpha: 1)
            bullet.colorBlendFactor = 1
            addChild(bullet)
            
            var dx = CGFloat(location.x - shooter.position.x)
            var dy = CGFloat(location.y - shooter.position.y)
            let magnitude = sqrt(dx * dx + dy * dy)
            dx /= magnitude
            dy /= magnitude
            let vector = CGVector(dx: bullet.size.width * dx, dy: bullet.size.height * dy)
            bullet.physicsBody?.applyImpulse(vector)
            
        }
    }
    
    // raywenderlich
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func addMonster() {
        
        // Create sprite (moved)
        let monster = SKSpriteNode(imageNamed: "boost_0")

        monster.physicsBody = SKPhysicsBody(circleOfRadius: monster.size.width * 0.4) // 1
        monster.physicsBody?.isDynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.bullet // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.none // 5
        monster.physicsBody?.usesPreciseCollisionDetection = true
        monster.color = SKColor(hue: random(min: 0.3, max: 0.75), saturation: 1, brightness: 1, alpha: 1)
        monster.colorBlendFactor = 1

        // Determine where to spawn the monster along the Y axis
        let actualX = random(min: monster.size.width/2, max: size.width - monster.size.width/2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        monster.position = CGPoint(x: actualX, y: size.height + monster.size.height/2)
        

        // Add the monster to the scene
        addChild(monster)
        
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        // Create the actions
        let actionMove = SKAction.move(to: CGPoint(x: actualX, y: -monster.size.width/2),
                                       duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        monster.run(SKAction.sequence([actionMove, actionMoveDone]))
    }

    func bulletDidCollideWithMonster(bullet: SKSpriteNode, monster: SKSpriteNode) {
        print("Hit")
        //shoot sfx
        run(SKAction.playSoundFileNamed("click.m4a", waitForCompletion: false))
        score += 1
        scoreLabel.text = String(score)

        bullet.removeFromParent()
        monster.removeFromParent()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        hueWheel += 0.01
        //print("hue:", hueWheel)
        shooter.color = SKColor(hue: CGFloat(hueWheel), saturation: 1, brightness: 1, alpha: 1)
        shooter.colorBlendFactor = 1
        
    }
}


extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 2
        if ((firstBody.categoryBitMask & PhysicsCategory.monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.bullet != 0)) {
            if let monster = firstBody.node as? SKSpriteNode,
                let bullet = secondBody.node as? SKSpriteNode {
                bulletDidCollideWithMonster(bullet: bullet, monster: monster)
            }
        }
    }

}
