//
//  ViewController.swift
//  myLittleMonster
//
//  Created by user on 10/08/2016.
//  Copyright © 2016 David Kennedy. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var monsterImg: MonsterImg!
    @IBOutlet weak var foodImg: dragImg!
    @IBOutlet weak var heartImg: dragImg!
    @IBOutlet weak var penalty1Img: UIImageView!
    @IBOutlet weak var penalty2Img: UIImageView!
    @IBOutlet weak var penalty3Img: UIImageView!
    @IBOutlet weak var diedPanel: UIImageView!
    @IBOutlet weak var diedButton: UIButton!
    @IBOutlet weak var skullsStackView: UIStackView!
    @IBOutlet weak var livesPanel: UIImageView!
    @IBOutlet weak var moleIdle: UIButton!
    @IBOutlet weak var monsterIdle: UIButton!
    @IBOutlet weak var petLbl: UILabel!
    @IBOutlet weak var moleImg: MoleImg!
    
    let DIM_ALPHA: CGFloat = 0.2
    let OPAQUE: CGFloat = 1.0
    let MAX_PENALTIES = 3
    
    var penalties = 0
    var timer: NSTimer!
    var monsterHappy = false
    var currentItem: UInt32 = 0
    
    var musicPlayer: AVAudioPlayer!
    var sfxBite: AVAudioPlayer!
    var sfxHeart: AVAudioPlayer!
    var sfxDeath: AVAudioPlayer!
    var sfxSkull: AVAudioPlayer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        foodImg.dropTarget = monsterImg
        heartImg.dropTarget = monsterImg
        
        penalty1Img.alpha = DIM_ALPHA
        penalty2Img.alpha = DIM_ALPHA
        penalty3Img.alpha = DIM_ALPHA
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "itemDroppedOnCharacter:", name: "onTargetDropped", object: nil)

        do {
            try musicPlayer = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("cave-music", ofType: "mp3")!))
            
            try sfxBite = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("bite", ofType: "wav")!))
            
            try sfxHeart = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("heart", ofType: "wav")!))
            
            try sfxDeath = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("death", ofType: "wav")!))
            
            try sfxSkull = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("skull", ofType: "wav")!))
            
            musicPlayer.prepareToPlay()
            musicPlayer.play()
            
            sfxBite.prepareToPlay()
            sfxDeath.prepareToPlay()
            sfxHeart.prepareToPlay()
            sfxSkull.prepareToPlay()
            
        } catch let err as NSError {
            print(err.debugDescription)
        }
 
    }
    
    
    @IBAction func  monsterTapped(sender: AnyObject) {
        monsterImg.hidden = false
        livesPanel.hidden = false
        skullsStackView.hidden = false
        foodImg.hidden = false
        heartImg.hidden = false
        
        moleIdle.hidden = true
        moleImg.hidden = true
        monsterIdle.hidden = true
        petLbl.hidden = true
        diedButton.hidden = true
        diedPanel.hidden = true
    
        startTimer()
        
        
    }
    
    @IBAction func moleTapped(sender: AnyObject) {
        moleImg.hidden = false
        livesPanel.hidden = false
        skullsStackView.hidden = false
        foodImg.hidden = false
        heartImg.hidden = false
        
        moleIdle.hidden = true
        monsterImg.hidden = true
        monsterIdle.hidden = true
        petLbl.hidden = true
        diedButton.hidden = true
        diedPanel.hidden = true
        
        startTimer()
        
    }
    
    
    
    func itemDroppedOnCharacter(notif: AnyObject) {
       monsterHappy = true
        startTimer()
    }
    
    func startTimer() {
        if timer != nil {
            timer.invalidate()
            
            foodImg.alpha = DIM_ALPHA
            foodImg.userInteractionEnabled = false
            heartImg.alpha = DIM_ALPHA
            heartImg.userInteractionEnabled = false
            
            if currentItem == 0 {
                sfxHeart.play()
            } else {
                sfxBite.play()
            }
            
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "changeGameState", userInfo: nil, repeats: true)
    }
    
    func changeGameState() {
        
        
        
        if !monsterHappy {
            
            penalties++
            
            sfxSkull.play()
            
            if penalties == 1 {
                penalty1Img.alpha = OPAQUE
                penalty2Img.alpha = DIM_ALPHA
            } else if penalties == 2 {
                penalty2Img.alpha = OPAQUE
                penalty3Img.alpha = DIM_ALPHA
            } else if penalties >= 3 {
                penalty3Img.alpha = OPAQUE
            } else {
                penalty1Img.alpha = DIM_ALPHA
                penalty2Img.alpha = DIM_ALPHA
                penalty3Img.alpha = DIM_ALPHA
            }
            
            if penalties >= MAX_PENALTIES {
                gameOver()
            }

        }
        
        let rand = arc4random_uniform(2) // 0 or 1
        if rand == 0 {
            foodImg.alpha = DIM_ALPHA
            foodImg.userInteractionEnabled = false
            
            heartImg.alpha = OPAQUE
            heartImg.userInteractionEnabled = true
        } else {
            heartImg.alpha = DIM_ALPHA
            heartImg.userInteractionEnabled = false
            
            foodImg.alpha = OPAQUE
            foodImg.userInteractionEnabled = true
        }
        
        currentItem = rand
        monsterHappy = false
        
    }
    

    
    
    
    
    @IBAction func restartGame(sender: AnyObject) {
        
        penalties = 0
        currentItem = 0
        monsterHappy = false
        musicPlayer.play()
        startTimer()
        
        heartImg.hidden = false
        foodImg.hidden = false
        livesPanel.hidden = false
        skullsStackView.hidden = false
        diedPanel.hidden = true
        diedButton.hidden = true
        
        penalty1Img.alpha = DIM_ALPHA
        penalty2Img.alpha = DIM_ALPHA
        penalty3Img.alpha = DIM_ALPHA
        
        monsterImg.playIdleAnimation()
        moleImg.playMoleIdleAnimation()
        
    }
    
    
    
    
    
    func gameOver(){
        timer.invalidate()
        monsterImg.playDeathAnimation()
        moleImg.playMoleDeadAnimation()
        sfxDeath.play()
        musicPlayer.stop()
        
        heartImg.hidden = true
        foodImg.hidden = true
        livesPanel.hidden = true
        skullsStackView.hidden = true
        diedPanel.hidden = false
        diedButton.hidden = false
        
    }


}

