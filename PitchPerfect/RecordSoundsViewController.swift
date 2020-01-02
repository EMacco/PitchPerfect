//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Emmanuel Okwara on 02/01/2020.
//  Copyright © 2020 Emmanuel Okwara. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordingLbl: UILabel!
    @IBOutlet weak var recordBtn: UIButton!
    var recording = false
    var audioRecorder: AVAudioRecorder!
    var pulseLayers = [CAShapeLayer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createPulse()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }

    @IBAction func recordBtnPressed(_ sender: UIButton) {
        recording = !recording
        configureUI()
        if recording {
            startRecording()
        } else {
            stopRecording()
        }
    }
    
    func startRecording() {
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let recordingName = "recorderVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(.playAndRecord, options: .defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    func stopRecording() {
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    func configureUI() {
        if recording {
            recordingLbl.text = "Tap to finish recording"
            recordBtn.setImage(#imageLiteral(resourceName: "Stop"), for: .normal)
            startAnimation()
        } else {
            recordingLbl.text = "Tap to start recording"
            recordBtn.setImage(#imageLiteral(resourceName: "Record"), for: .normal)
            stopAnimation()
        }
    }
    
    func startAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.animatePulse(index: 2)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.animatePulse(index: 1)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.animatePulse(index: 0)
                }
            }
        }
    }
    
    func stopAnimation() {
        for (index, _) in self.pulseLayers.enumerated() {
            pulseLayers[index].removeAllAnimations()
            pulseLayers[index].removeFromSuperlayer()
        }
    }
    
    func createPulse() {
        let circleInterval: CGFloat = 15
        let micRadius = (recordBtn.frame.size.width) - circleInterval
        for circleNumber in 1 ... 3 {
            let circleRadius: CGFloat = (micRadius / 2) + (circleInterval * CGFloat(circleNumber))
            let circularPath = UIBezierPath(arcCenter: .zero, radius: circleRadius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
            let pulseLayer = CAShapeLayer()
            pulseLayer.path = circularPath.cgPath
            pulseLayer.lineWidth = 3.0
            pulseLayer.fillColor = UIColor.clear.cgColor
            pulseLayer.strokeColor = Constants.blueColor
            pulseLayer.lineCap = .round
            pulseLayer.position = CGPoint(x: recordBtn.frame.size.width/2, y: recordBtn.frame.size.height/2)
            pulseLayers.append(pulseLayer)
        }
    }
    
    func animatePulse(index: Int) {
        let opacityAnim = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        opacityAnim.duration = 1.5
        opacityAnim.fromValue = 0.9
        opacityAnim.toValue = 0.0
        opacityAnim.timingFunction = CAMediaTimingFunction(name: .easeOut)
        opacityAnim.repeatCount = .greatestFiniteMagnitude
        pulseLayers[index].add(opacityAnim, forKey: "opacity")
        self.recordBtn.layer.addSublayer(pulseLayers[index])
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            self.performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            let alert = UIAlertController(title: "Audio Recording", message: "Error occurred while recording audio, please try again", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
    
}

