//
//  AddEmpleadoViewController.swift
//  GestorHeme
//
//  Created by jon mikel on 12/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit

class AddEmpleadoViewController: UIViewController {
    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var apellidosLabel: UILabel!
    @IBOutlet weak var fechaLabel: UILabel!
    @IBOutlet weak var telefonoLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    var empleado: EmpleadoModel = EmpleadoModel()
    var updateMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Empleado"
        addSaveEmpleadoButton()
        
        setValues()
    }
    
    func addSaveEmpleadoButton() {
        var rightButtons: [UIBarButtonItem] = []
        rightButtons.append(UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .done, target: self, action: #selector(didClickSaveButton)))
        
        if empleado.empleadoId != 0 {
            rightButtons.append(UIBarButtonItem(image: UIImage(systemName: "phone"), style: .done, target: self, action: #selector(didClickCallEmpleadoButton)))
        }
        
        self.navigationItem.rightBarButtonItems = rightButtons
    }
    
    func setValues() {
        nombreLabel.text = empleado.nombre
        apellidosLabel.text = empleado.apellidos
        if empleado.fecha != 0 {
            fechaLabel.text = CommonFunctions.getTimeTypeStringFromDate(date: Date(timeIntervalSince1970: TimeInterval(empleado.fecha)))
        }
        telefonoLabel.text = empleado.telefono
        emailLabel.text = empleado.email
    }
    
    func showInputFieldView(inputReference: Int, keyBoardType: UIKeyboardType, text: String, controllerTitle: String) {
        let showItemStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let controller: FieldViewController = showItemStoryboard.instantiateViewController(withIdentifier: "FieldViewController") as! FieldViewController
        controller.inputReference = inputReference
        controller.delegate = self
        controller.keyboardType = keyBoardType
        controller.inputText = text
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    func openDatePickerView() {
        let showItemStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let controller: DatePickerSelectorViewController = showItemStoryboard.instantiateViewController(withIdentifier: "DatePickerSelectorViewController") as! DatePickerSelectorViewController
        controller.delegate = self
        controller.datePickerMode = .date
        controller.initialDate = 0
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    func checkFields() {
        if empleado.nombre.count == 0 {
            CommonFunctions.showGenericAlertMessage(mensaje: "Debe escribir un nombre", viewController: self)
            return
        }
        
        if empleado.apellidos.count == 0 {
            CommonFunctions.showGenericAlertMessage(mensaje: "Debe escribir los apellidos del empleado", viewController: self)
            return
        }
        
        if empleado.fecha == 0 {
            CommonFunctions.showGenericAlertMessage(mensaje: "Debe seleccionar una fecha de nacimiento", viewController: self)
            return
        }
        
        if telefonoLabel.text!.count < 9 {
            CommonFunctions.showGenericAlertMessage(mensaje: "Debe incluir un número de contacto válido", viewController: self)
            return
        }
        
        if emailLabel.text!.count < 6 {
            CommonFunctions.showGenericAlertMessage(mensaje: "Debe incluir el e-mail del cliente", viewController: self)
            return
        }
        
        if !emailLabel.text!.contains("@") {
            CommonFunctions.showGenericAlertMessage(mensaje: "Debe incluir un e-mail válido", viewController: self)
            return
        }
        
        if empleado.redColorValue == 0 {
            setPredefinedColor()
        }
        
        
        if !updateMode {
            CommonFunctions.showLoadingStateView(descriptionText: "Guardando empleado")
            empleado.empleadoId = Int64(Date().timeIntervalSince1970)
            Constants.cloudDatabaseManager.empleadoManager.saveEmpleado(empleado: empleado, delegate: self)
        } else {
            CommonFunctions.showLoadingStateView(descriptionText: "Actualizando empleado")
            Constants.cloudDatabaseManager.empleadoManager.updateEmpleado(empleado: empleado, delegate: self)
        }
    }
    
    func setPredefinedColor() {
        let components = UIColor.systemBlue.cgColor.components
        empleado.redColorValue = Float(components![0])
        empleado.greenColorValue = Float(components![1])
        empleado.blueColorValue = Float(components![2])
    }
    
    func callEmpleado() {
        
    }
}

extension AddEmpleadoViewController {
    @IBAction func didClickNombreField(_ sender: Any) {
        showInputFieldView(inputReference: 1, keyBoardType: .default, text: nombreLabel.text!, controllerTitle: "Nombre")
    }
    
    @IBAction func didClickApellidosField(_ sender: Any) {
        showInputFieldView(inputReference: 2, keyBoardType: .default, text: apellidosLabel.text!, controllerTitle: "Apellidos")
    }
    
    @IBAction func didClickFechaField(_ sender: Any) {
        openDatePickerView()
    }
    
    @objc func didClickSaveButton(sender: UIBarButtonItem) {
        checkFields()
    }
    
    @objc func didClickCallEmpleadoButton(sender: UIBarButtonItem) {
        CommonFunctions.callPhone(telefono: empleado.telefono.replacingOccurrences(of: " ", with: ""))
    }
    
    @IBAction func didClickTelefonoButton(_ sender: Any) {
        showInputFieldView(inputReference: 3, keyBoardType: .phonePad, text: telefonoLabel.text!, controllerTitle: "Telefono")
    }
    
    @IBAction func didClickEmailButton(_ sender: Any) {
        showInputFieldView(inputReference: 4, keyBoardType: .emailAddress, text: emailLabel.text!, controllerTitle: "Email")
    }
}

extension AddEmpleadoViewController: AddClientInputFieldProtocol {
    func textSaved(text: String, inputReference: Int) {
        switch inputReference {
        case 1:
            empleado.nombre = text
            nombreLabel.text = text
        case 2:
            empleado.apellidos = text
            apellidosLabel.text = text
        case 3:
            empleado.telefono = text
            telefonoLabel.text = text
        default:
            empleado.email = text
            emailLabel.text = text
        }
    }
}

extension AddEmpleadoViewController: DatePickerSelectorProtocol {
    func dateSelected(date: Date) {
        empleado.fecha = Int64(date.timeIntervalSince1970)
        fechaLabel.text = CommonFunctions.getTimeTypeStringFromDate(date: date)
    }
}

extension AddEmpleadoViewController: CloudEmpleadoProtocol {
    func empleadoSincronizationFinished() {
        print("EXITO SINCRONIZANDO EMPLEADO")
        DispatchQueue.main.async {
            CommonFunctions.hideLoadingStateView()
            if !self.updateMode {
                if !Constants.databaseManager.empleadosManager.addEmpleadoToDatabase(newEmpleado: self.empleado) {
                    CommonFunctions.showGenericAlertMessage(mensaje: "Error guardando empleado, intentelo de nuevo", viewController: self)
                    return
                }
            } else {
                if !Constants.databaseManager.empleadosManager.updateEmpleado(empleado: self.empleado) {
                    CommonFunctions.showGenericAlertMessage(mensaje: "Error actualizando empleado, intentelo de nuevo", viewController: self)
                    return
                }
            }
            
            self.navigationController!.popViewController(animated: true)
        }
    }
    
    func empleadoSincronizationError(error: String) {
        print("ERROR SINCRONIZANDO EMPLEADO")
        DispatchQueue.main.async {
            CommonFunctions.hideLoadingStateView()
            CommonFunctions.showGenericAlertMessage(mensaje: error, viewController: self)
        }
    }
    
    func empleadoDeleted(empleado: EmpleadoModel) {
        //No necesario
    }
    
    
}
