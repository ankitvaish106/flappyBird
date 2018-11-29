//
//  GameScene.swift
//  flappy bird
//
//  Created by NTGMM-02 on 26/11/18.
//  Copyright © 2018 NTGMM-02. All rights reserved.
//

import SpriteKit
import GameplayKit
enum colliderType:UInt32{
    case bird = 1
    case object = 2
    case gap = 4
}
class GameScene: SKScene,SKPhysicsContactDelegate{
    var bird = SKSpriteNode()
    var background = SKSpriteNode()
    var pipe1 = SKSpriteNode()
    var pipe2 = SKSpriteNode()
    var score = 0
    var scoreLabel = SKLabelNode()
    var gameOverLabel = SKLabelNode()
    var gameOver = false
    var timer = Timer()
    @objc func moveAnimationInPipe(){
        
        let MovePipe = SKAction.move(by: CGVector(dx: -2 * self.frame.width, dy: 0), duration: TimeInterval(self.frame.width / 100 ))
        let gapHeight = bird.size.height * 4
        let movementAmount = arc4random() % UInt32(self.frame.height / 2)
        let pipeOffSet = CGFloat(movementAmount) - self.frame.height / 4
        
        
        let pipeTexture = SKTexture(image: #imageLiteral(resourceName: "pipe1"))
        pipe1 = SKSpriteNode(texture: pipeTexture)
        pipe1.position = CGPoint(x: self.frame.midX+self.frame.size.width, y: self.frame.midY + pipeTexture.size().height/2+gapHeight/2+pipeOffSet)
        pipe1.run(MovePipe)
        pipe1.zPosition = -1
        pipe1.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture.size())
        pipe1.physicsBody!.isDynamic = false
        pipe1.physicsBody!.collisionBitMask = colliderType.object.rawValue
        pipe1.physicsBody!.categoryBitMask = colliderType.object.rawValue
        pipe1.physicsBody!.contactTestBitMask = colliderType.bird.rawValue
        self.addChild(pipe1)
        
        let pipe2Texture = SKTexture(image: #imageLiteral(resourceName: "pipe2"))
        pipe2 = SKSpriteNode(texture: pipe2Texture)
        pipe2.position = CGPoint(x: self.frame.midX+self.frame.size.width, y: self.frame.midY - pipe2Texture.size().height/2-gapHeight/2+pipeOffSet)
        pipe2.run(MovePipe)
        pipe2.physicsBody = SKPhysicsBody(rectangleOf: pipe2Texture.size())
        pipe2.physicsBody!.isDynamic = false
        pipe2.zPosition = -1
        pipe2.physicsBody!.collisionBitMask = colliderType.object.rawValue
        pipe2.physicsBody!.categoryBitMask = colliderType.object.rawValue
        pipe2.physicsBody!.contactTestBitMask = colliderType.bird.rawValue
        self.addChild(pipe2)
        
        let gap = SKNode()
        gap.position = CGPoint(x: self.frame.midX+self.frame.width, y: self.frame.midY + pipeOffSet)
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeTexture.size().width, height: gapHeight))
        gap.physicsBody?.isDynamic = false
        gap.run(MovePipe)
        gap.physicsBody!.collisionBitMask = colliderType.gap.rawValue
        gap.physicsBody!.categoryBitMask = colliderType.gap.rawValue
        gap.physicsBody!.contactTestBitMask = colliderType.bird.rawValue
        self.addChild(gap)
        
    }
    func didBegin(_ contact: SKPhysicsContact) {
        if gameOver == false{
            if contact.bodyA.categoryBitMask == colliderType.gap.rawValue || contact.bodyB.categoryBitMask == colliderType.gap.rawValue{
                score += 1
                scoreLabel.text = String(score)
            }else{
                print("we collide")
               if let maxScore = UserDefaults.standard.value(forKey: "maxScore") as? Int{
                if score > maxScore{
                    UserDefaults.standard.set(score, forKey: "maxScore")
                  }
                }
               self.speed = 0
                gameOver = true
                timer.invalidate()
                gameOverLabel.fontName = "Helvetica"
                gameOverLabel.fontSize = 30
                gameOverLabel.text = "Game Over! tap to play again"
                gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                self.addChild(gameOverLabel)
            }
        }
 
        
    }
    override func didMove(to view: SKView){
        self.physicsWorld.contactDelegate = self
setupGame()
    }
    func setupGame(){
        timer =  Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(moveAnimationInPipe), userInfo: nil, repeats: true)
        let backGroundImages = SKTexture(image: #imageLiteral(resourceName: "bg"))
        let moveBGAnimation = SKAction.move(by: CGVector(dx: -backGroundImages.size().width, dy: 0), duration: 5)
        let ShiftBGAnimation = SKAction.move(by: CGVector(dx: backGroundImages.size().width, dy: 0), duration: 0)
        let makeBGRight = SKAction.repeatForever(SKAction.sequence([moveBGAnimation,ShiftBGAnimation]))
        var i:CGFloat = 0
        while i<3 {
            background = SKSpriteNode(texture:backGroundImages)
            background.position = CGPoint(x:backGroundImages.size().width * i, y: self.frame.midY)
            background.zPosition = -2
            background.size.height = self.frame.height
            background.run(makeBGRight)
            self.addChild(background)
            i += 1
        }
        let birdTexture = SKTexture(image: #imageLiteral(resourceName: "flappy1"))
        let birdTexture1 = SKTexture(image: #imageLiteral(resourceName: "flappy2"))
        let animation = SKAction.animate(with: [birdTexture,birdTexture1], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatForever(animation)
        bird = SKSpriteNode(texture: birdTexture)
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height / 2)
        bird.physicsBody!.isDynamic = false
        bird.physicsBody!.collisionBitMask = colliderType.bird.rawValue
        bird.physicsBody!.categoryBitMask = colliderType.bird.rawValue
        bird.physicsBody!.contactTestBitMask = colliderType.object.rawValue
        bird.run(makeBirdFlap)
        
        self.addChild(bird)
        
        let ground = SKNode()
        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height / 2)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        ground.physicsBody!.isDynamic = false
        self.addChild(ground)
        
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height/2 - 90)
        self.addChild(scoreLabel)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        if gameOver == false{
            bird.physicsBody!.isDynamic = true
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 80))
        }else{
            gameOver = false
            score = 0
            self.speed = 1
            self.removeAllChildren()
            setupGame()
        }
       
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
