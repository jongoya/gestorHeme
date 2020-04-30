//
//  AddTipoServicioViewController.swift
//  GestorHeme
//
//  Created by jon mikel on 13/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit

class AddTipoServicioViewController: UIViewController {
    @IBOutlet weak var nombreServicioLabel: UILabel!
    
    var servicio: TipoServicioModel = TipoServicioModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Nuevo Servicio"
        setFields()
        addSaveServicioButton()
    }
    
    func setFields() {
        nombreServicioLabel.text = servicio.nombre
    }
    
    func addSaveServicioButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .done, target: self, action: #selector(didClickSaveButton))
    }
    
    func showInputFieldView(inputReference: Int, keyBoardType: UIKeyboardType, text: String) {
        let showItemStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let controller: FieldViewController = showItemStoryboard.instantiateViewController(withIdentifier: "FieldViewController") as! FieldViewController
        controller.inputReference = inputReference
        controller.delegate = self
        controller.keyboardType = keyBoardType
        controller.inputText = text
        controller.title = "Nombre"
        self.navigationController!.pushViewController(controller, animated: true)
    }
}

extension AddTipoServicioViewController {
    @IBAction func didClickNombreServicio(_ sender: Any) {
        showInputFieldView(inputReference: 0, keyBoardType: .default, text: nombreServicioLabel.text!)
    }
    
    @objc func didClickSaveButton(sender: UIBarButtonItem) {
        if nombreServicioLabel.text!.count == 0 {
            CommonFunctions.showGenericAlertMessage(mensaje: "Debe escribir un nombre para el servicio", viewController: self)
            return
        }
        CommonFunctions.showLoadingStateView(descriptionText: "Guardando servicio")
        
        servicio.servicioId = Int64(Date().timeIntervalSince1970)
        
        Constants.cloudDatabaseManager.tipoServicioManager.saveTipoServicio(tipoServicio: servicio, delegate: self)
    }
}

extension AddTipoServicioViewController: AddClientInputFieldProtocol {
    func textSaved(text: String, inputReference: Int) {
        servicio.nombre = text
        nombreServicioLabel.text = text
    }
}

extension AddTipoServicioViewController: CloudTipoServiciosProtocol {
    func tipoServiciosSincronizationFinished() {
        print("EXITO GUARDANDO TIPO SERVICIO")
        if !Constants.databaseManager.tipoServiciosManager.addTipoServicioToDatabase(servicio: servicio) {
            CommonFunctions.showGenericAlertMessage(mensaje: "Error guardando el nuevo servicio, inténtelo de nuevo", viewController: self)
            return
        }
        
        DispatchQueue.main.async {
            CommonFunctions.hideLoadingStateView()
            self.navigationController!.popViewController(animated: true)
        }
    }
    
    func tipoServiciosSincronizationError(error: String) {
        print("ERROR GUARDANDO TIPO SERVICIO")
        DispatchQueue.main.async {
            CommonFunctions.hideLoadingStateView()
            CommonFunctions.showGenericAlertMessage(mensaje: "Error guardando servicio", viewController: self)
        }
    }
}
