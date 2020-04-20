//
//  AddClientFieldViewController.swift
//  GestorHeme
//
//  Created by jon mikel on 01/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit

class FieldViewController: UIViewController {
    @IBOutlet weak var inpuField: UITextView!
    
    var delegate: AddClientInputFieldProtocol!
    var inputReference: Int!
    var keyboardType:UIKeyboardType!
    var inputText: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle()
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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "mic"), style: .done, target: self, action: #selector(didClickMicrophoneButton))
    }
    
    func setTitle() {
        switch inputReference {
        case 1:
            title = "Nombre"
        case 2:
            title = "Apellidos"
        case 3:
            title = "Teléfono"
        case 4:
            title = "Email"
        case 5:
            title = "Dirección"
        case 6:
            title = "Cada cuanto biene"
        case 7:
            title = "Observación"
        default:
            break
        }
    }
}

extension FieldViewController {
    @objc func didClickMicrophoneButton(sender: UIBarButtonItem) {
    }
}
