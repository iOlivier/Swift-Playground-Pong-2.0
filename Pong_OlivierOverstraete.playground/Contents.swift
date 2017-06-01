//: Playground - noun: a place where people can play

import SpriteKit
import PlaygroundSupport
import AVFoundation

class Scene: SKScene, SKPhysicsContactDelegate {

    struct CategoryBitMask {
        static let Ball: UInt32 = 0b1 << 0
        static let Wall: UInt32 = 0b1 << 1
        static let PaletTop: UInt32 = 0b1 << 2
        static let PaletBottom: UInt32 = 0b1 << 3
        static let GoalTop: UInt32 = 0b1 << 4
        static let GoalBottom: UInt32 = 0b1 << 5
    }
    
    private var btnSinglePlayer = SKShapeNode()
    private var lblSinglePlayer = SKLabelNode()
    private var btnMultiPlayer = SKShapeNode()
    private var lblMultiPlayer = SKLabelNode()
    private var lblMultiPlayerInfo = SKLabelNode()
    private var btnRestart = SKShapeNode()
    private var lblRestart = SKLabelNode()
    
    private var ball = SKShapeNode()
    private var paletTop = SKSpriteNode()
    private var paletBottom = SKSpriteNode()
    private var score = SKLabelNode()
    private var paletTopInfo = SKLabelNode()
    private var paletBottomInfo = SKLabelNode()
    
    private var isSinglePlayerGame = false
    private var isMultiPlayerGame = false
    private var gamePaused: Bool = true
    private var paletTopActive: Bool = false
    private var paletBottomActive: Bool = false
    private var ballVelocity = CGVector(dx: -500, dy: -500)
    
    private var scoreTopPlayer = 0
    private var scoreBottomPlayer = 0
    
    private let wallColors: [UIColor] = [#colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1), #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1), #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 1, green: 0.2527923882, blue: 1, alpha: 1)]
    
    private var fireworksSound = AVAudioPlayer()
    private var bumpSound = AVAudioPlayer()
    
    override func didMove(to view: SKView) {
        
        self.view?.isMultipleTouchEnabled = true
        self.size = CGSize(width: 700, height: 1000)
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        ball = SKShapeNode(circleOfRadius: 20)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        ball.fillColor = SKColor.white
        ball.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        ball.physicsBody!.allowsRotation = false
        ball.physicsBody!.categoryBitMask = CategoryBitMask.Ball
        ball.physicsBody!.contactTestBitMask = CategoryBitMask.Wall | CategoryBitMask.GoalTop | CategoryBitMask.GoalBottom
        ball.physicsBody!.friction = 0
        ball.physicsBody!.linearDamping = 0
        ball.physicsBody!.restitution = 1
        self.addChild(ball)
        
        let walls: [[String: Any]] = [
            ["name": "WallLeftT", "width": 20, "height": (Int(self.frame.height)-200)/2, "x": 30, "y": 100 + (Int(self.frame.height)-200)/2 + 5],
            ["name": "WallRightT", "width": 20, "height": (Int(self.frame.height)-200)/2, "x": Int(self.size.width)-50, "y": 100 + (Int(self.frame.height)-200)/2 + 5],
            ["name": "WallLeftB", "width": 20, "height": (Int(self.frame.height)-200)/2, "x": 30, "y": 100-5],
            ["name": "WallRightB", "width": 20, "height": (Int(self.frame.height)-200)/2, "x": Int(self.size.width)-50, "y": 100-5],
            ["name": "WallTopLeft", "width": Int(self.size.width)/4, "height": 20, "x": 50, "y": Int(self.size.height)-90],
            ["name": "WallTopRight", "width": Int(self.size.width)/4, "height": 20, "x": Int(self.size.width)*3/4-50, "y": Int(self.size.height)-90],
            ["name": "WallBottomLeft", "width": Int(self.size.width)/4, "height": 20, "x": 50, "y": 70],
            ["name": "WallBottomRight", "width": Int(self.size.width)/4, "height": 20, "x": Int(self.size.width)*3/4-50, "y": 70]
        ]
        
        for w in walls {
            let wall = SKShapeNode(rect: CGRect(x: w["x"] as! Int, y: w["y"] as! Int, width: w["width"] as! Int, height: w["height"] as! Int), cornerRadius: 10)
            wall.lineWidth = 3
            wall.strokeColor = wallColors[Int(arc4random_uniform(UInt32(wallColors.count)))]
            wall.name = w["name"] as? String
            wall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: wall.frame.width, height: wall.frame.height), center: CGPoint(x: wall.frame.origin.x + wall.frame.width/2, y: wall.frame.origin.y + wall.frame.height/2))
            wall.physicsBody!.categoryBitMask = CategoryBitMask.Wall
            wall.physicsBody!.isDynamic = false
            wall.physicsBody!.friction = 0
            wall.physicsBody!.restitution = 1
            self.addChild(wall)
        }
        
        paletTop = SKSpriteNode(color: SKColor.white, size: CGSize(width: self.size.width/15, height: 10))
        paletTop.physicsBody = SKPhysicsBody(rectangleOf: paletTop.size)
        paletTop.physicsBody!.categoryBitMask = CategoryBitMask.PaletTop
        paletTop.physicsBody!.isDynamic = false
        paletTop.physicsBody!.friction = 0
        paletTop.physicsBody!.restitution = 1
        paletTop.physicsBody!.linearDamping = 0
        paletTop.position = CGPoint(x: self.size.width/2, y: self.size.height-150)
        self.addChild(paletTop)
        
        paletBottom = SKSpriteNode(color: SKColor.white, size: CGSize(width: self.size.width/15, height: 10))
        paletBottom.physicsBody = SKPhysicsBody(rectangleOf: paletBottom.size)
        paletBottom.physicsBody!.categoryBitMask = CategoryBitMask.PaletBottom
        paletBottom.physicsBody!.isDynamic = false
        paletBottom.physicsBody!.friction = 0
        paletBottom.physicsBody!.restitution = 1
        paletBottom.physicsBody!.linearDamping = 0
        paletBottom.position = CGPoint(x: self.size.width/2, y: 150)
        self.addChild(paletBottom)
        
        let goalTop = SKSpriteNode(color: SKColor.clear, size: CGSize(width: self.size.width, height: 1))
        goalTop.position = CGPoint(x: self.size.width/2, y: self.size.height)
        goalTop.physicsBody = SKPhysicsBody(rectangleOf: goalTop.size)
        goalTop.physicsBody!.isDynamic = false
        goalTop.physicsBody!.categoryBitMask = CategoryBitMask.GoalTop
        self.addChild(goalTop)
        
        let goalBottom = SKSpriteNode(color: SKColor.clear, size: CGSize(width: self.size.width, height: 1))
        goalBottom.position = CGPoint(x: self.size.width/2, y: 0)
        goalBottom.physicsBody = SKPhysicsBody(rectangleOf: goalBottom.size)
        goalBottom.physicsBody!.isDynamic = false
        goalBottom.name = "GoalBottom"
        goalBottom.physicsBody!.categoryBitMask = CategoryBitMask.GoalBottom
        self.addChild(goalBottom)
        
        score = SKLabelNode(text: "")
        score.position = CGPoint(x: self.frame.width/4, y: self.frame.height/2)
        score.fontSize = 80
        score.zRotation = CGFloat.pi/2
        self.addChild(score)
        
        paletTopInfo = SKLabelNode(text: "Touch and hold to play")
        paletTopInfo.position = CGPoint(x: self.frame.width/2, y: self.frame.height-260)
        paletTopInfo.fontSize = 26
        paletTopInfo.zRotation = CGFloat.pi
        self.addChild(paletTopInfo)
        
        paletBottomInfo = SKLabelNode(text: "Touch and hold to play")
        paletBottomInfo.position = CGPoint(x: self.frame.width/2, y: 260)
        paletBottomInfo.fontSize = 26
        self.addChild(paletBottomInfo)
        
        showStartMenu()
        
        do {
            let sound = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "Fireworks", ofType:"m4a")!))
            fireworksSound = sound
            fireworksSound.prepareToPlay()
        } catch {
            print("AVPlayer ERROR: Couldn't load file Fireworks.m4a")
        }
        
        do {
            let sound = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "Bump", ofType:"m4a")!))
            bumpSound = sound
            bumpSound.prepareToPlay()
        } catch {
            print("AVPlayer ERROR: Couldn't load file Bump.m4a")
        }
    }
    
    func showStartMenu() {
        btnSinglePlayer = SKShapeNode(rect: CGRect(x: self.frame.width/2-150, y: self.frame.height/2+15, width: 300, height: 40), cornerRadius: 20)
        btnSinglePlayer.lineWidth = 3
        btnSinglePlayer.strokeColor = wallColors[Int(arc4random_uniform(UInt32(wallColors.count)))]
        self.addChild(btnSinglePlayer)
        
        lblSinglePlayer = SKLabelNode(text: "Single player game")
        lblSinglePlayer.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2+26)
        lblSinglePlayer.fontName = "HelveticaNeue-Bold"
        lblSinglePlayer.fontSize = 22
        self.addChild(lblSinglePlayer)
        
        btnMultiPlayer = SKShapeNode(rect: CGRect(x: self.frame.width/2-150, y: self.frame.height/2-55, width: 300, height: 40), cornerRadius: 20)
        btnMultiPlayer.lineWidth = 3
        btnMultiPlayer.strokeColor = wallColors[Int(arc4random_uniform(UInt32(wallColors.count)))]
        self.addChild(btnMultiPlayer)
        
        lblMultiPlayer = SKLabelNode(text: "Multi player game")
        lblMultiPlayer.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2-44)
        lblMultiPlayer.fontName = "HelveticaNeue-Bold"
        lblMultiPlayer.fontSize = 22
        self.addChild(lblMultiPlayer)
        
        lblMultiPlayerInfo = SKLabelNode(text: "Multi player is only supported on the iPad playgrounds app")
        lblMultiPlayerInfo.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2-84)
        lblMultiPlayerInfo.fontName = "HelveticaNeue"
        lblMultiPlayerInfo.fontSize = 14
        self.addChild(lblMultiPlayerInfo)
        
        ball.isHidden = true
        paletTopInfo.isHidden = true
        paletBottomInfo.isHidden = true
    }
    
    func hideStartMenu() {
        btnSinglePlayer.removeFromParent()
        lblSinglePlayer.removeFromParent()
        btnMultiPlayer.removeFromParent()
        lblMultiPlayer.removeFromParent()
        lblMultiPlayerInfo.removeFromParent()
    }
    
    func startSinglePlayerGame() {
        hideStartMenu()
        isSinglePlayerGame = true
        paletTopActive = true
        ball.isHidden = false
        paletBottomInfo.isHidden = false
    }
    
    func startMultiPlayerGame() {
        hideStartMenu()
        isMultiPlayerGame = true
        paletTopActive = false
        ball.isHidden = false
        paletTopInfo.isHidden = false
        paletBottomInfo.isHidden = false
    }
    
    func startRound() {
        gamePaused = true
        ballVelocity = CGVector(dx: getRandomMinPlus() * 500, dy: getRandomMinPlus() * 500)
    }
    
    func showRestartButton() {
        btnRestart = SKShapeNode(rect: CGRect(x: self.frame.width-150, y: self.frame.height/2-75, width: 30, height: 150), cornerRadius: 15)
        btnRestart.strokeColor = wallColors[Int(arc4random_uniform(UInt32(wallColors.count)))]
        self.addChild(btnRestart)
        
        lblRestart = SKLabelNode(text: "RESET")
        lblRestart.position = CGPoint(x: self.frame.width-127, y: self.frame.height/2)
        lblRestart.fontName = "HelveticaNeue-Bold"
        lblRestart.fontSize = 20
        lblRestart.zRotation = CGFloat.pi/2
        self.addChild(lblRestart)
    }
    
    func hideRestartButton() {
        btnRestart.removeFromParent()
        lblRestart.removeFromParent()
    }
    
    func restartGame() {
        paletTop.position.x = self.frame.width/2
        paletBottom.position.x = self.frame.width/2
        scoreTopPlayer = 0
        scoreBottomPlayer = 0
        score.isHidden = true
        isSinglePlayerGame = false
        isMultiPlayerGame = false
        showStartMenu()
    }
    
    func userScoredGoal(player: String) {
        score.isHidden = false
        score.text = "\(scoreBottomPlayer) - \(scoreTopPlayer)"
        ball.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
        DispatchQueue.main.async {
            self.ball.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
            self.playFireworks(player: player)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
            self.startRound()
        }
    }
    
    func playFireworks(player: String) {
        var offset: CGFloat = 0
        if (player == "T") { offset = self.frame.height/2 }
        if let fireworksOrange = SKEmitterNode(fileNamed: "FireworksOrange.sks") {
            fireworksOrange.position = CGPoint(x: self.frame.width/2, y: offset + self.frame.height/4)
            self.addChild(fireworksOrange)
            DispatchQueue.global(qos: .userInitiated).async {
                self.fireworksSound.play()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
            if let fireworksGreen = SKEmitterNode(fileNamed: "FireworksGreen.sks") {
                fireworksGreen.position = CGPoint(x: self.frame.width/4, y: offset + self.frame.height*3/8)
                self.addChild(fireworksGreen)
                DispatchQueue.global(qos: .userInitiated).async {
                    self.fireworksSound.play()
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.8) {
            if let fireworksRed = SKEmitterNode(fileNamed: "FireworksRed.sks") {
                fireworksRed.position = CGPoint(x: self.frame.width*3/4, y: offset + self.frame.height*1/8)
                self.addChild(fireworksRed)
                DispatchQueue.global(qos: .userInitiated).async {
                    self.fireworksSound.play()
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.2) {
            if let fireworksYellow = SKEmitterNode(fileNamed: "FireworksYellow.sks") {
                fireworksYellow.position = CGPoint(x: self.frame.width/4, y: offset + self.frame.height*1/8)
                self.addChild(fireworksYellow)
                DispatchQueue.global(qos: .userInitiated).async {
                    self.fireworksSound.play()
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.6) {
            if let fireworksBlue = SKEmitterNode(fileNamed: "FireworksBlue.sks") {
                fireworksBlue.position = CGPoint(x: self.frame.width*3/4, y: offset + self.frame.height*3/8)
                self.addChild(fireworksBlue)
                DispatchQueue.global(qos: .userInitiated).async {
                    self.fireworksSound.play()
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
            if let fireworksOrange = SKEmitterNode(fileNamed: "FireworksOrange.sks") {
                fireworksOrange.position = CGPoint(x: self.frame.width/2, y: offset + self.frame.height/4)
                self.addChild(fireworksOrange)
                DispatchQueue.global(qos: .userInitiated).async {
                    self.fireworksSound.play()
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if (paletTopActive && paletBottomActive && gamePaused) { // start game
            ball.physicsBody!.velocity = ballVelocity
            gamePaused = false
            hideRestartButton()
        } else if ((!paletTopActive || !paletBottomActive) && !gamePaused) { // pause game
            gamePaused = true
            ballVelocity = ball.physicsBody!.velocity
            ball.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            showRestartButton()
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyB.categoryBitMask == CategoryBitMask.Ball) {
            switch contact.bodyA.categoryBitMask {
            case CategoryBitMask.GoalTop:
                scoreBottomPlayer = scoreBottomPlayer + 1
                userScoredGoal(player: "B")
            case CategoryBitMask.GoalBottom:
                scoreTopPlayer = scoreTopPlayer + 1
                userScoredGoal(player: "T")
            case CategoryBitMask.Wall:
                let wall = contact.bodyA.node as! SKShapeNode
                let randomColor = wallColors[Int(arc4random_uniform(UInt32(wallColors.count)))]
                wall.strokeColor = randomColor
                wall.fillColor = randomColor
                wall.run(SKAction.customAction(withDuration: 0.5, actionBlock: { (node: SKNode!, elapsedTime: CGFloat) -> Void in
                    wall.fillColor = randomColor.withAlphaComponent(1-elapsedTime*2)
                }))
                /*DispatchQueue.main.async {
                 if let bump = SKEmitterNode(fileNamed: "Bump") {
                 bump.position = contact.contactPoint
                 self.addChild(bump)
                 }
                 }*/
                DispatchQueue.global(qos: .userInitiated).async {
                    self.bumpSound.play()
                }
            default:
                print("Ball touched something else")
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if (btnSinglePlayer.contains(touch.location(in: self))) {
                startSinglePlayerGame()
            } else if (btnMultiPlayer.contains(touch.location(in: self))) {
                startMultiPlayerGame()
            } else if (btnRestart.contains(touch.location(in: self))) {
                hideRestartButton()
                restartGame()
                isSinglePlayerGame = false
                isMultiPlayerGame = false
            } else if (isMultiPlayerGame && touch.location(in: self).y > self.frame.size.height*3/4) {
                paletTopActive = true
                paletTopInfo.isHidden = true
            } else if ((isSinglePlayerGame || isMultiPlayerGame) && touch.location(in: self).y < self.frame.size.height/4) {
                paletBottomActive = true
                paletBottomInfo.isHidden = true
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if (isMultiPlayerGame && touch.location(in: self).y > self.frame.size.height*3/4) {
                paletTop.position.x = touch.location(in: self).x
            } else if ((isSinglePlayerGame || isMultiPlayerGame) && touch.location(in: self).y < self.frame.size.height/4) {
                paletBottom.position.x = touch.location(in: self).x
                if (isSinglePlayerGame) { paletTop.position.x = touch.location(in: self).x }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if (isMultiPlayerGame && touch.location(in: self).y > self.frame.size.height/2) {
                paletTopActive = false
                paletTopInfo.isHidden = false
            } else if ((isSinglePlayerGame || isMultiPlayerGame) && touch.location(in: self).y < self.frame.size.height/2) {
                paletBottomActive = false
                paletBottomInfo.isHidden = false
            }
        }
    }
    
    func getRandomMinPlus() -> Int {
        let rand = Int(arc4random_uniform(2))
        if (rand%2 == 1) { return -1 }
        else { return 1 }
    }
}


let scene = Scene()
scene.scaleMode = .aspectFit

let view = SKView(frame: CGRect(x: 0, y: 0, width: 700, height: 1000))
view.presentScene(scene)
PlaygroundPage.current.liveView = view
