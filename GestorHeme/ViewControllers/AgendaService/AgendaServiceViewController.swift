//
//  AgendaServiceViewController.swift
//  GestorHeme
//
//  Created by jon mikel on 08/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit

class AgendaServiceViewController: UIViewController {
    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var fechaLabel: UILabel!
    @IBOutlet weak var profesionalLabel: UILabel!
    @IBOutlet weak var servicioLabel: UILabel!
    @IBOutlet weak var observacionesLabel: UILabel!
    
    var newService: ServiceModel = ServiceModel()
    var clientSeleced: ClientModel!
    var newDate: Date!
    var modificacionHecha: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Servicio"
        addBackButton()
        setInitialDate()
    }
    
    func setInitialDate() {
        newService.fecha = Int64(newDate.timeIntervalSince1970)
        fechaLabel.text = CommonFunctions.getDateAndTimeTypeStringFromDate(date: newDate)
    }
    
    func getArrayForInputReference(inputReference: Int) -> [Any] {
        switch inputReference {
        case 1:
            return CommonFunctions.getProfessionalList()
        default:
            return CommonFunctions.getServiceList()
        }
    }
    
    func checkFields() {
        if nombreLabel.text!.count == 0 {
            CommonFunctions.showGenericAlertMessage(mensaje: "Debe seleccionar un cliente", viewController: self)
            return
        }
        
        if fechaLabel.text!.count == 0 {
            CommonFunctions.showGenericAlertMessage(mensaje: "Debe incluir una fecha", viewController: self)
            return
        }
        
        if profesionalLabel.text!.count == 0 {
            CommonFunctions.showGenericAlertMessage(mensaje: "Debe seleccionar a una profesional", viewController: self)
            return
        }
        
        if servicioLabel.text!.count == 0 {
            CommonFunctions.showGenericAlertMessage(mensaje: "Debe seleccionar un servicio", viewController: self)
            return
        }

        saveService()
        
        self.navigationController!.popViewController(animated: true)
    }
    
    func saveService() {
        newService.clientId = clientSeleced.id
        newService.serviceId = Int64(Date().timeIntervalSince1970)
        if !Constants.databaseManager.servicesManager.addServiceInDatabase(newService: newService) {
            CommonFunctions.showGenericAlertMessage(mensaje: "Error al guardar el servicio, intentelo de nuevo mas tarde", viewController: self)
        }
        
        Constants.cloudDatabaseManager.serviceManager.saveService(service: newService)
    }
    
    func addBackButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .done, target: self, action: #selector(didClickBackButton))
    }
    
    func showChangesAlertMessage() {
        let alertController = UIAlertController(title: "Aviso", message: "Varios datos han sido modificados, ¿desea volver sin guardar?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Aceptar", style: .default) { (_) in
            self.navigationController?.popViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel) { (_) in }

        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension AgendaServiceViewController {
    @IBAction func didClickNombreField(_ sender: Any) {
        performSegue(withIdentifier: "ClientListIdentifier", sender: nil)
    }
    
    @IBAction func didClickFechaField(_ sender: Any) {
        performSegue(withIdentifier: "DatePickerSelectorIdentifier", sender: nil)
    }
    
    @IBAction func didClickProfesionalField(_ sender: Any) {
        performSegue(withIdentifier: "ListSelectorIdentifier", sender: 1)
    }
    
    @IBAction func didClickServicioField(_ sender: Any) {
        performSegue(withIdentifier: "ListSelectorIdentifier", sender: 2)
    }
    
    @IBAction func didClickObservacionesField(_ sender: Any) {
        performSegue(withIdentifier: "FieldIdentifier", sender: 1)
    }
    
    @IBAction func didClickSaveServiceButton(_ sender: Any) {
        checkFields()
    }
    
    @objc func didClickBackButton(sender: UIBarButtonItem) {
        if !modificacionHecha {
            self.navigationController?.popViewController(animated: true)
        } else {
            showChangesAlertMessage()
        }
    }
}

extension AgendaServiceViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DatePickerSelectorIdentifier" {
            let controller: DatePickerSelectorViewController = segue.destination as! DatePickerSelectorViewController
            controller.delegate = self
            controller.datePickerMode = .dateAndTime
        } else if segue.identifier == "FieldIdentifier" {
            let controller: FieldViewController = segue.destination as! FieldViewController
            controller.inputReference = (sender as! Int)
            controller.delegate = self
            controller.keyboardType = .default
            controller.inputText = newService.observacion
        } else if segue.identifier == "ListSelectorIdentifier" {
            let controller: ListSelectorViewController = segue.destination as! ListSelectorViewController
            controller.delegate = self
            controller.inputReference = (sender as! Int)
            controller.listOptions = getArrayForInputReference(inputReference: (sender as! Int))
            controller.allowMultiselection = (sender as! Int) == 2 ? true : false
        } else if segue.identifier == "ClientListIdentifier" {
            let controller: ClientListSelectorViewController = segue.destination as! ClientListSelectorViewController
            controller.delegate = self
        }
    }
}

extension AgendaServiceViewController: DatePickerSelectorProtocol {
    func dateSelected(date: Date) {
        newService.fecha = Int64(date.timeIntervalSince1970)
        fechaLabel.text = CommonFunctions.getDateAndTimeTypeStringFromDate(date: date)
    }
}

extension AgendaServiceViewController: ListSelectorProtocol {
    func multiSelectionOptionsSelected(options: [Any], inputReference: Int) {
        modificacionHecha = true
        switch inputReference {
        case 2:
            newService.servicio = CommonFunctions.getServiciosIdentifiers(servicios: (options as! [TipoServicioModel]))
            servicioLabel.text = CommonFunctions.getServiciosString(servicios: (options as! [TipoServicioModel]))
        default:
            break
        }
    }
    
    func optionSelected(option: Any, inputReference: Int) {
        modificacionHecha = true
        switch inputReference {
        case 1:
            newService.profesional = (option as! EmpleadoModel).empleadoId
            profesionalLabel.text = (option as! EmpleadoModel).nombre
        default:
            newService.servicio = [(option as! TipoServicioModel).servicioId]
            servicioLabel.text = (option as! TipoServicioModel).nombre
        }
    }
}

extension AgendaServiceViewController: AddClientInputFieldProtocol {
    func textSaved(text: String, inputReference: Int) {
        newService.observacion = text
        observacionesLabel.text = text
        modificacionHecha = true
    }
}

extension AgendaServiceViewController: ClientListSelectorProtocol {
    func clientSelected(client: ClientModel) {
        clientSeleced = client
        newService.nombre = client.nombre
        newService.apellidos = client.apellidos
        nombreLabel.text = client.nombre + " " + client.apellidos
        modificacionHecha = true
    }
}
