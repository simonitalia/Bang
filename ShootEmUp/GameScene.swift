//
//  GameScene.swift
//  ShootingGallery
//
//  Created by Simon Italia on 2/11/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // X axis off screen position properties
    let leftEdge = 0 - 64
    let rightEdge = 1024 + 64
    
    // Y axis off screen position properties
    let bottomEdge = 0 - 22
    let topEdge = 768 + 22
    
    //Track active targets
    var activeTargets = [SKSpriteNode]()
    
    //Property handling display of targets on UI
    var scheduledTimer: Timer!
    var gameTimer: Timer!
    
    //Game time left properties
    var timeRemainingLabel: SKLabelNode!
    var timeRemaining = 60 {
        didSet {
            timeRemainingLabel.text = "Seconds left: \(timeRemaining)"
        }
    }
    
    //Game scoring properties
    var playerScoreLabel: SKLabelNode!
    var playerScore = 0 {
        didSet {
            playerScoreLabel.text = "Score: \(playerScore)"
        }
    }
    
    //Relaod bullets properties
    var reloadLabel: SKLabelNode!
    
    //Bullets available properties
    var bulletsLabel: SKLabelNode!
    var bulletsImages = [SKSpriteNode]()
    var bullets = 6 {
        
        didSet {
            
            //Update bullets label color
            bulletsLabel.text = "Bullets: \(bullets)"
            
            if bullets > 0 && bullets < 6 {
               reloadLabel.fontColor = UIColor.orange
            }
            
            if bullets == 0 {
                reloadLabel.fontColor = UIColor.red
                bulletsLabel.fontColor = UIColor.gray
            }
            
            if bullets == 6 {
                reloadLabel.fontColor = UIColor.gray
                bulletsLabel.fontColor = UIColor.black
            }
        }
    }
    
    //Game over properties
    var gameEnded = false
    
    override func didMove(to view: SKView) {
        
        //Set scheduled timer to show targets on interval
        scheduledTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(showTargets), userInfo: nil, repeats: true)
        
        //Track game time remaining
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(setGameTimer), userInfo: nil, repeats: true)
        
        //Add background image node to scene
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        background.name = "background"
        addChild(background)
        
        //Create score label node and add to scene
        playerScoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        playerScoreLabel.text = "Score: 0"
        playerScoreLabel.position = CGPoint(x: 8, y: 8)
        playerScoreLabel.horizontalAlignmentMode = .left
        playerScoreLabel.fontSize = 48
        addChild(playerScoreLabel)
        
        //Create Time remaining label node and add to scene
        timeRemainingLabel = SKLabelNode(fontNamed: "Chalkduster")
        timeRemainingLabel.fontColor = UIColor.black
        timeRemainingLabel.text = "Seconds remaining: 60"
        timeRemainingLabel.position = CGPoint(x: 8, y: 760)
        timeRemainingLabel.horizontalAlignmentMode = .left
        timeRemainingLabel.verticalAlignmentMode = .top
        timeRemainingLabel.fontSize = 24
        addChild(timeRemainingLabel)
        
        //Create bullets node and add to scene
        bulletsLabel = SKLabelNode(fontNamed: "Chalkduster")
        bulletsLabel.fontColor = UIColor.black
        bulletsLabel.text = "Bullets: 6"
        bulletsLabel.position = CGPoint(x: 1016, y: 760)
        bulletsLabel.horizontalAlignmentMode = .right
        bulletsLabel.verticalAlignmentMode = .top
        bulletsLabel.fontSize = 24
        addChild(bulletsLabel)
        
        //Create reload label node and add to scene
        reloadLabel = SKLabelNode(fontNamed: "Chalkduster")
        reloadLabel.fontColor = UIColor.gray
        reloadLabel.text = "RELOAD"
        reloadLabel.color = .green
        reloadLabel.position = CGPoint(x: 512, y: 760)
        reloadLabel.horizontalAlignmentMode = .center
        reloadLabel.verticalAlignmentMode = .top
        reloadLabel.fontSize = 36
        reloadLabel.name = "reload"
        addChild(reloadLabel)
        
        //Display bullets
        showBullets()
    }
    
    //Update frame
    override func update(_ currentTime: TimeInterval) {
        
        //Handle new game
        if gameEnded {
            
            //Display alert with score
            let alertController = UIAlertController(title: "Game Over", message: "Your score: \(playerScore)", preferredStyle: .alert)
            
            //Display Play again button
            alertController.addAction(UIAlertAction(title: "Play again?", style: .default, handler: {
                action in self.restartGame()
            }))
            
            self.view?.window?.rootViewController?.present(alertController, animated: true)
            
            gameEnded = false
            
            return
        }
        
        //Remove nodes no longer on screen
        if activeTargets.count > 0 {

            for target in activeTargets {
                if Int(target.position.x) < leftEdge || Int(target.position.x) > rightEdge {
                    
                    target.removeAllActions()
                }
            }
        }
        
    } //End update()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //Defend against game over
        if gameEnded {
            return
        }
        
        //Determine if player tapped a node
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            let touchedNodes = nodes(at: touchLocation)
            
            //Take action depending on type of node player touched
            for touchedNode in touchedNodes {
                
                //Gun empty scenarios
                if bullets == 0 {
                    
                    //Reload tapped
                    if touchedNode.name == "reload" {
                        
                        reload()
                    
                    //Reload not tapped
                    } else {
                        
                        //Play dryFire sound
                        run(SKAction.playSoundFileNamed("dryFire.mp3", waitForCompletion: false))
                    }
                
                //Gun not empty scenarios
                } else {
                    
                    switch touchedNode.name {
                        
                    //goodTarget node tapped actions
                    case "goodTarget":
                        
                        //Deduct points from player score for hitting goodTarget
                        playerScore -= 5
                        
                        //Play wrong target sound
                        run(SKAction.playSoundFileNamed("wrongTarget.mp3", waitForCompletion: false))
                        
                        //Clear node name so it can't be touched again
                        touchedNode.name = ""
                     
                    //badTarget node tapped actions
                    case "badTarget":
                        
                        //Add points
                        playerScore += 5
                        
                        //Deduct bullets left
                        bulletUsed()
                        
                        //Set particle emitter for when node is touched
                        let emitter = SKEmitterNode(fileNamed: "smoke")!
                        emitter.position = touchedNode.position
                        emitter.name = "smoke"
                        addChild(emitter)
                        
                        //Clear node name so it can't be touched again
                        touchedNode.name = ""
                        
                        //Stop node from moving
                        touchedNode.physicsBody?.isDynamic = false
                        
                        //Scale and fade node out simultaneously
                        let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                        let group = SKAction.group([scaleOut, fadeOut])
                        
                        //Remove node from scene, using group object above
                        let actionSequence = SKAction.sequence([group, SKAction.removeFromParent()])
                        touchedNode.run(actionSequence)
                        
                        //Remove node from activeTargets array
                        let index = activeTargets.index(of: touchedNode as! SKSpriteNode)!
                        activeTargets.remove(at: index)
                    
                    //bonusTarget node tapped actions
                    case "bonusTarget":
                        
                        //Add bonus points
                        playerScore += 10
                        
                        //Deduct bullets left
                        bulletUsed()
                        
                        //Set particle emitter for when node is touched
                        let emitter = SKEmitterNode(fileNamed: "smoke")!
                        emitter.position = touchedNode.position
                        emitter.name = "smoke"
                        addChild(emitter)
                        
                        //Clear node name so it can't be touched again
                        touchedNode.name = ""
                        
                        //Stop node from moving
                        touchedNode.physicsBody?.isDynamic = false
                        
                        //Scale and fade node out simultaneously
                        let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                        let group = SKAction.group([scaleOut, fadeOut])
                        
                        //Remove node from scene, using group object above
                        let actionSequence = SKAction.sequence([group, SKAction.removeFromParent()])
                        touchedNode.run(actionSequence)
                        
                        //Remove node from activeTargets array
                        let index = activeTargets.index(of: touchedNode as! SKSpriteNode)!
                        activeTargets.remove(at: index)
                        
                    //reload node tapped actions
                    case "reload":
                            
                            reload()
                        
                    default:
                       break
                        
                    } //End switch touchedNode.name
                
                } // End If, Else
                
            } //End forLoop

        }
 
    } //End of touchesBegan() method
    
    //1. Create target and add to Scene
    func createTarget(x: Int, xMovement: CGFloat, y: Int, yMovement: CGFloat) {
        
        //Determine good or bad target
        var target: SKSpriteNode!
        
        let targetType = Int.random(in: 0...7)
        
        //Create bad (banditTarget) node and add to scene
        if targetType <= 5 && targetType != 3 {
            
            //Create bad (banditTarget) node and add to scene
            target = SKSpriteNode(imageNamed: "bandit")
            target.name = "badTarget"
            
        //Create good (sheriff) node and add to scene
        } else if targetType > 5 {
            
            target = SKSpriteNode(imageNamed: "sheriff")
            target.name = "goodTarget"
            
        //Create bonus (moneyBag) node and add to scene
        } else {
            target = SKSpriteNode(imageNamed: "moneyBag")
            target.name = "bonusTarget"

        }
        
        //Position created target on screen
        target.zPosition = 1
        target.position = CGPoint(x: x, y: y)
        
        //Create a path for target to move along
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 0, y: 0))
        bezierPath.addLine(to: CGPoint(x: xMovement, y: yMovement))
        
        //Set target to follow UIBezierPath and set target speed
        var targetMove: SKAction
        
        //Speed for goodTarget and badTarget
        if targetType != 3 {
            targetMove = SKAction.follow(bezierPath.cgPath, asOffset: true, orientToPath: false, speed: 300)
            //asOffset means path coordinates are either absolute (false), or relative (true) to nodes's position
        
        //Speed for bonusTarget
        } else {
            targetMove = SKAction.follow(bezierPath.cgPath, asOffset: true, orientToPath: false, speed: 400)
        }
        
//        //Rotate targets
//        //Create random angular velocity (spinning speed)
//        target.physicsBody = SKPhysicsBody(circleOfRadius: 10)
//
//        let randomAngularVelocity = CGFloat.random(in: -6...6) / 2.0
//        target.physicsBody?.angularVelocity = randomAngularVelocity
//        target.physicsBody = SKPhysicsBody(circleOfRadius: 64)
        
        //Set movement type
        targetMove.timingMode = .linear
        
        //Run the move action
        target.run(targetMove)
        
        //Add target to activeTargets array() and to scene
        activeTargets.append(target)
        addChild(target)

    }//End createTarget() method
    
    @objc func showTargets() {
        
        //Defend against game over
        if gameEnded {
            return
        }
        
        //Show targets code block
        let xAmount: CGFloat = 1800

        //Top row
        createTarget(x: leftEdge, xMovement: xAmount, y: 576, yMovement: 0)
        
        //Middle row
        createTarget(x: rightEdge, xMovement: -xAmount, y: 384, yMovement: 0)
        
        //Bottom row
        createTarget(x: leftEdge, xMovement: xAmount, y: 192, yMovement: 0)
    
    }
    
    //Decrement game time remaining each second
    @objc func setGameTimer() {
        
        //Update timer remaining
        timeRemaining -= 1
        
        if timeRemaining == 0 {
            
            //Cancel schedule timer
            scheduledTimer.invalidate()
            
            //Cancel game timer
            gameTimer.invalidate()
            
            //End gamne
            gameOver()
        }
        
    }
    
    func showBullets() {
        for i in 0 ..< 6 {
            let bulletImage = SKSpriteNode(imageNamed: "bullet")
            bulletImage.position = CGPoint(x: CGFloat(800 + (i * 40)), y: 690)
            bulletImage.name = "bullet"
            addChild(bulletImage)
            
            //Add bulletNode object to array object
            bulletsImages.append(bulletImage)
        }
        
    }//End showBullets() method
    
    func bulletUsed() {
        
        //Deduct bullet
        bullets -= 1
        
        //Play gunshot sound
        run(SKAction.playSoundFileNamed("fire.mp3", waitForCompletion: false))
        
        print("Bullets: \(bullets)")
        
        //Replace bullet image with usedBullet image
        var bulletImage = SKSpriteNode()
        
        switch bullets {
            
        //0 bullets used, nothing to do
        case 6:
            break
         
        //1 bullet used
        case 5:
            bulletImage = bulletsImages[0]
        
        //2 bullets used
        case 4:
            bulletImage = bulletsImages[1]
        
        //3 bullets used
        case 3:
            bulletImage = bulletsImages[2]
        
        //4 bullets used
        case 2:
            bulletImage = bulletsImages[3]
        
        //5 bullets used
        case 1:
            bulletImage = bulletsImages[4]
        
        //All 6 bullets used
        case 0:
            bulletImage = bulletsImages[5]

        default:
            break
        
        }//End switch
        
       //Set bulletUsed Image
        bulletImage.texture = SKTexture(imageNamed: "bulletUsed")
        bulletImage.name = "bulletUsed"
        bulletImage.xScale = 1.3
        bulletImage.yScale = 1.3
        bulletImage.run(SKAction.scale(to: 1, duration: 0.1))
        
    }//End bulletUsed()
    
    func reload() {
        
        //Check gun isn't already full
        if bullets < 6 {
            
            //Play reload sound
            run(SKAction.playSoundFileNamed("reload.wav", waitForCompletion: false))
    
            //Replace usedBullet image with bullet image
            for bulletImage in bulletsImages {
                
                if bulletImage.name == "bulletUsed" {
                    
                    //Set bullet Image
                    bulletImage.texture = SKTexture(imageNamed: "bullet")
                    bulletImage.name = "bullet"
                    bulletImage.xScale = 1.3
                    bulletImage.yScale = 1.3
                    bulletImage.run(SKAction.scale(to: 1, duration: 0.1))
                }

            }//End for loop

            //Refill maximum bullets
            bullets = 6
    
        } //End If block
    
    }//Reload()
    
    //Game Over
    func gameOver() {
    
        //Ensure game has ended
        if gameEnded {
        return
        
        }
        
        //Set gameEnded falg to true
        gameEnded = true
        
        //Stop screen animations and disable user interaction
        physicsWorld.speed = 0
        isUserInteractionEnabled = false
        
        if activeTargets.count > 0 {
            
            for target in activeTargets {
                    
                target.removeAllActions()
                target.zPosition = 0
            }
        }
        
        //Display Game Over image and play sound
        let gameOverImage = SKSpriteNode(imageNamed: "gameOver")
        gameOverImage.name = "gameOver"
        gameOverImage.position = CGPoint(x: 512, y: 576)
        gameOverImage.zPosition = 1
        addChild(gameOverImage)
//        run(SKAction.playSoundFileNamed("gameOver.caf", waitForCompletion: true))
        
    }
    
    //Start new game
    func restartGame() {
        
        gameEnded = false
        
        let nextScene = GameScene(size: self.scene!.size)
        nextScene.scaleMode = self.scaleMode
        nextScene.backgroundColor = UIColor.black
        self.view?.presentScene(nextScene, transition: SKTransition.fade(with: UIColor.black, duration: 1.5))
    }
}

