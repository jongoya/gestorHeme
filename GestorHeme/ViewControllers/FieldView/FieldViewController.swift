//
//  AddClientFieldViewController.swift
//  GestorHeme
//
//  Created by jon mikel on 01/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit
import Speech

class FieldViewController: UIViewController {
    @IBOutlet weak var inpuField: UITextView!
    
    var delegate: AddClientInputFieldProtocol!
    var inputReference: Int!
    var keyboardType:UIKeyboardType!
    var inputText: String!
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "es_ES"))
    var request: SFSpeechAudioBufferRecognitionRequest?
    var speechTask: SFSpeechRecognitionTask!
    var microphoneButtton: UIBarButtonItem!
    var recording: Bool = false
    var centeredText: UIView!
    var node: AVAudioInputNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inpuField.becomeFirstResponder()
        inpuField.keyboardType = keyboardType
        inpuField.text = inputText
        
        addMicrophoneButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate.textSaved(text: inpuField.text, inputReference: self.inputReference)
    }
    
    func addMicrophoneButton() {
        microphoneButtton = UIBarButtonItem(image: UIImage(systemName: "mic"), style: .done, target: self, action: #selector(didClickMicrophoneButton))
        self.navigationItem.rightBarButtonItem = microphoneButtton
    }
    
    func addCenteredText() {
        centeredText = UIView()
        centeredText.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(centeredText)
        
        let alphaView: UIView = UIView()
        alphaView.translatesAutoresizingMaskIntoConstraints = false
        alphaView.backgroundColor = .black
        alphaView.alpha = 0.4
        centeredText.addSubview(alphaView)
        
        let microText: UILabel = UILabel()
        microText.translatesAutoresizingMaskIntoConstraints = false
        microText.text = "Grabando!"
        microText.textColor = .white
        microText.textAlignment = .center
        microText.font = .systemFont(ofSize: 15)
        centeredText.addSubview(microText)
        
        centeredText.heightAnchor.constraint(equalToConstant: 40).isActive = true
        centeredText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centeredText.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        centeredText.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        alphaView.topAnchor.constraint(equalTo: centeredText.topAnchor).isActive = true
        alphaView.bottomAnchor.constraint(equalTo: centeredText.bottomAnchor).isActive = true
        alphaView.leadingAnchor.constraint(equalTo: centeredText.leadingAnchor).isActive = true
        alphaView.trailingAnchor.constraint(equalTo: centeredText.trailingAnchor).isActive = true
        
        microText.topAnchor.constraint(equalTo: centeredText.topAnchor).isActive = true
        microText.bottomAnchor.constraint(equalTo: centeredText.bottomAnchor).isActive = true
        microText.leadingAnchor.constraint(equalTo: centeredText.leadingAnchor).isActive = true
        microText.trailingAnchor.constraint(equalTo: centeredText.trailingAnchor).isActive = true
    }
}

extension FieldViewController {
    @objc func didClickMicrophoneButton(sender: UIBarButtonItem) {
        if recording {
            microphoneButtton.image = UIImage(systemName: "mic")
            centeredText.removeFromSuperview()
            stopRecording(node: node)
            return
        }
        
        addCenteredText()
        self.inpuField.endEditing(true)
        recording = true
        node = prepareAudioInputNode()
        
        if !startAudioEngine() {
            CommonFunctions.showGenericAlertMessage(mensaje: "Error preparando el audio", viewController: self)
            return
        }
        
        if isSpeechRecognizerNotAvailable() {
            CommonFunctions.showGenericAlertMessage(mensaje: "No hay microfono disponible en este mobcenil", viewController: self)
            return
        }
        
        microphoneButtton.image = UIImage(systemName: "mic.fill")
        
        speechTask = speechRecognizer!.recognitionTask(with: request!, resultHandler: { (result, error) in
            var isFinal = false
            
            if let result = result {
                if self.recording {
                    self.inpuField.text = result.bestTranscription.formattedString
                    isFinal = result.isFinal
                }
            }
            
            if error != nil || isFinal {
                if self.recording {
                    self.stopRecording(node: self.node!)
                }
            }
        })
    }
    
    func prepareAudioInputNode() -> AVAudioInputNode {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        request = SFSpeechAudioBufferRecognitionRequest()
        request!.shouldReportPartialResults = true
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.request!.append(buffer)
        }
        
        return node
    }
    
    func startAudioEngine() -> Bool {
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            return false
        }
        
        return true
    }
    
    func isSpeechRecognizerNotAvailable() -> Bool {
        return speechRecognizer == nil && speechRecognizer!.isAvailable
    }
    
    func stopRecording(node: AVAudioInputNode) {
        recording = false
        self.audioEngine.stop()
        node.removeTap(onBus: 0)

        self.request!.endAudio()
        self.request = nil
        self.speechTask = nil
    }
}
