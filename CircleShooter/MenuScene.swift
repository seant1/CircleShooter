//
//  MenuScene.swift
//  CircleShooter
//
//  Created by Lai Phong Tran on 21/12/18.
//  Copyright © 2018 Lai Phong Tran. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit


class FTButtonNode: SKSpriteNode {
    
    enum FTButtonActionType: Int {
        case TouchUpInside = 1,
        TouchDown, TouchUp
    }
    
    var isEnabled: Bool = true {
        didSet {
            if (disabledTexture != nil) {
                //            texture = isEnabled ? defaultTexture : disabledTexture
            }
        }
    }
    var isSelected: Bool = false {
        didSet {
            //        texture = isSelected ? selectedTexture : defaultTexture
        }
    }
    
    var defaultTexture: SKTexture
    var selectedTexture: SKTexture
    var label: SKLabelNode
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    init(normalTexture defaultTexture: SKTexture!, selectedTexture:SKTexture!, disabledTexture: SKTexture?) {
        
        self.defaultTexture = defaultTexture
        self.selectedTexture = selectedTexture
        self.disabledTexture = disabledTexture
        self.label = SKLabelNode(fontNamed: "Helvetica");
        
        super.init(texture: defaultTexture, color: UIColor.white, size: defaultTexture.size())
        isUserInteractionEnabled = true
        
        //Creating and adding a blank label, centered on the button
        self.label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center;
        self.label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center;
        addChild(self.label)
        
        // Adding this node as an empty layer. Without it the touch functions are not being called
        // The reason for this is unknown when this was implemented...?
        let bugFixLayerNode = SKSpriteNode(texture: nil, color: UIColor.clear, size: defaultTexture.size())
        bugFixLayerNode.position = self.position
        addChild(bugFixLayerNode)
        
    }
    
    /**
     * Taking a target object and adding an action that is triggered by a button event.
     */
    func setButtonAction(target: AnyObject, triggerEvent event:FTButtonActionType, action:Selector) {
        
        switch (event) {
        case .TouchUpInside:
            targetTouchUpInside = target
            actionTouchUpInside = action
        case .TouchDown:
            targetTouchDown = target
            actionTouchDown = action
        case .TouchUp:
            targetTouchUp = target
            actionTouchUp = action
        }
        
    }
    
    /*
     New function for setting text. Calling function multiple times does
     not create a ton of new labels, just updates existing label.
     You can set the title, font type and font size with this function
     */
    
    func setButtonLabel(title: NSString, font: String, fontSize: CGFloat) {
        self.label.text = title as String
        self.label.fontSize = fontSize
        self.label.fontName = font
        self.label.fontColor = SKColor.red
    }
    
    var disabledTexture: SKTexture?
    var actionTouchUpInside: Selector?
    var actionTouchUp: Selector?
    var actionTouchDown: Selector?
    weak var targetTouchUpInside: AnyObject?
    weak var targetTouchUp: AnyObject?
    weak var targetTouchDown: AnyObject?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!isEnabled) {
            return
        }
        isSelected = true
        if (targetTouchDown != nil && targetTouchDown!.responds(to: actionTouchDown)) {
            UIApplication.shared.sendAction(actionTouchDown!, to: targetTouchDown, from: self, for: nil)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (!isEnabled) {
            return
        }
        
        let touch: AnyObject! = touches.first
        let touchLocation = touch.location(in: parent!)
        
        if (frame.contains(touchLocation)) {
            isSelected = true
        } else {
            isSelected = false
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!isEnabled) {
            return
        }
        
        isSelected = false
        
        if (targetTouchUpInside != nil && targetTouchUpInside!.responds(to: actionTouchUpInside!)) {
            let touch: AnyObject! = touches.first
            let touchLocation = touch.location(in: parent!)
            
            if (frame.contains(touchLocation) ) {
                UIApplication.shared.sendAction(actionTouchUpInside!, to: targetTouchUpInside, from: self, for: nil)
            }
            
        }
        
        if (targetTouchUp != nil && targetTouchUp!.responds(to: actionTouchUp!)) {
            UIApplication.shared.sendAction(actionTouchUp!, to: targetTouchUp, from: self, for: nil)
        }
    }
    
}
class MenuScene: SKScene {
    
    
    init(size: CGSize, won:Bool) {
        super.init(size: size)
        
        // 1
        //backgroundColor = SKColor.white
        
        // 2
        let message = won ? "You Won!" : "You Winned :["
        
        // 3
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.black
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
        // 4
        run(SKAction.sequence([
            SKAction.wait(forDuration: 10.0),
            SKAction.run() { [weak self] in
                // 5
           /*     guard let `self` = self else { return }
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                let scene = GameScene(size: size)
                self.view?.presentScene(scene, transition:reveal)   */
            }
            ]))
    }
    
    // 6
    required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView)
    {
        backgroundColor = SKColor.white
        let buttonTexture: SKTexture! = SKTexture(imageNamed: "button_start")
        let buttonTextureSelected: SKTexture! = SKTexture(imageNamed: "button_start_pressed")
        let button = FTButtonNode(normalTexture: buttonTexture, selectedTexture: buttonTextureSelected, disabledTexture: buttonTexture)
        button.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(MenuScene.buttonTap))
        button.setButtonLabel(title: "", font: "Arial", fontSize: 12)
        button.position = CGPoint(x: self.frame.midX,y: self.frame.midY * 0.3)
        button.zPosition = 1
        button.size = CGSize(width: 300, height: 50)
        button.color = SKColor.red
        button.colorBlendFactor = 1
        button.name = "Button"
        self.addChild(button)
    }
    
    @objc func buttonTap() {
        print("Button pressed")
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let scene = GameScene(size: size)
        self.view?.presentScene(scene, transition:reveal)
    }
}
/*
 var button: SKNode! = nil
 
 override func didMove(to view: SKView) {
 // Create a simple red rectangle that's 100x44
 button = SKSpriteNode(color: SKColor.red, size: CGSize(width: 100, height: 44))
 // Put it in the center of the scene
 button.position = CGPoint(x: frame.width / 2, y: frame.height * 0.25)
 
 self.addChild(button)
 }
 
 override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
 // Loop over all the touches in this event
 for touch: AnyObject in touches {
 // Get the location of the touch in this scene
 let location = touch.locationInNode(self)
 // Check if the location of the touch is within the button's bounds
 if button.containsPoint(location) {
 println("tapped!")
 }
 }
 }
 
 
 let startButtonTexture = SKTexture(imageNamed: "button_start")
 let startButtonPressedTexture = SKTexture(imageNamed: "button_start_pressed")
 //let soundButtonTexture = SKTexture(imageNamed: "speaker_on")
 //let soundButtonTextureOff = SKTexture(imageNamed: "speaker_off")
 
 //let logoSprite = SKSpriteNode(imageNamed: "logo")
 var startButton : SKSpriteNode! = nil
 
 override func sceneDidLoad() {
 backgroundColor = SKColor(red:0.30, green:0.81, blue:0.89, alpha:1.0)
 
 //Set up logo - sprite initialized earlier
 //logoSprite.position = CGPoint(x: size.width / 2, y: size.height / 2 + 100)
 
 //addChild(logoSprite)
 
 //Set up start button
 startButton = SKSpriteNode(texture: startButtonTexture)
 startButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - startButton.size.height / 2)
 
 addChild(startButton)
 
 }
 
 override func touchesBegan(_ touches: Set, with event: UIEvent?) {
 if let touch = touches.first {
 if selectedButton != nil {
 handleStartButtonHover(isHovering: false)
 }
 
 // Check which button was clicked (if any)
 if startButton.contains(touch.location(in: self)) {
 selectedButton = startButton
 handleStartButtonHover(isHovering: true)
 } else if soundButton.contains(touch.location(in: self)) {
 selectedButton = soundButton
 handleSoundButtonHover(isHovering: true)
 }
 }
 }
 
 override func touchesMoved(_ touches: Set, with event: UIEvent?) {
 if let touch = touches.first {
 
 // Check which button was clicked (if any)
 if selectedButton == startButton {
 handleStartButtonHover(isHovering: (startButton.contains(touch.location(in: self))))
 } else if selectedButton == soundButton {
 handleSoundButtonHover(isHovering: (soundButton.contains(touch.location(in: self))))
 }
 }
 }
 
 override func touchesEnded(_ touches: Set, with event: UIEvent?) {
 if let touch = touches.first {
 
 if selectedButton == startButton {
 // Start button clicked
 handleStartButtonHover(isHovering: false)
 
 if (startButton.contains(touch.location(in: self))) {
 handleStartButtonClick()
 }
 
 } else if selectedButton == soundButton {
 // Sound button clicked
 handleSoundButtonHover(isHovering: false)
 
 if (soundButton.contains(touch.location(in: self))) {
 handleSoundButtonClick()
 }
 }
 }
 
 selectedButton = nil
 }
 
 /// Handles start button hover behavior
 func handleStartButtonHover(isHovering : Bool) {
 if isHovering {
 startButton.texture = startButtonPressedTexture
 } else {
 startButton.texture = startButtonTexture
 }
 }
 
 /// Stubbed out start button on click method
 func handleStartButtonClick() {
 print("start clicked")
 }
 */



