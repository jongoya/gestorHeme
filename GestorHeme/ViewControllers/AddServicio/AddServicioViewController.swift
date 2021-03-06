//
//  AddServicioViewController.swift
//  GestorHeme
//
//  Created by jon mikel on 02/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit

class AddServicioViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var fechaLabel: UILabel!
    @IBOutlet weak var professionalLabel: UILabel!
    @IBOutlet weak var servicioLabel: UILabel!
    @IBOutlet weak var observacionLabel: UILabel!
    
    var client: ClientModel!
    var service: ServiceModel = ServiceModel()
    var modifyService: Bool = false
    var delegate: AddServicioProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Servicio"
        
        setMainValues()
    }
    
    func setMainValues() {
        service.nombre = client.nombre
        service.apellidos = client.apellidos
        nombreLabel.text = client.nombre + " " + client.apellidos
        
        if modifyService {
            setAllFields()
        }
    }
    
    func setAllFields() {
        fechaLabel.text = CommonFunctions.getDateAndTimeTypeStringFromDate(date: Date(timeIntervalSince1970: TimeInterval(service.fecha)))
        professionalLabel.text = Constants.databaseManager.empleadosManager.getEmpleadoFromDatabase(empleadoId: service.profesional).nombre
        servicioLabel.text = CommonFunctions.getServiciosStringFromServiciosArray(servicios: service.servicio)
        observacionLabel.text = service.observacion
        if service.observacion.count == 0 {
            observacionLabel.text = "Añade una observación"
        }
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
        if fechaLabel.text!.count == 0 {
            CommonFunctions.showGenericAlertMessage(mensaje: "Debe incluir una fecha", viewController: self)
            return
        }
        
        if professionalLabel.text!.count == 0 {
            CommonFunctions.showGenericAlertMessage(mensaje: "Debe seleccionar a una profesional", viewController: self)
            return
        }
        
        if servicioLabel.text!.count == 0 {
            CommonFunctions.showGenericAlertMessage(mensaje: "Debe seleccionar un servicio", viewController: self)
            return
        }
        
        if client.id != 0 {
            if !modifyService {
                saveService()
            } else {
                updateService()
            }
        }
        
        delegate.serviceContentFilled(service: service, serviceUpdated: modifyService)
        self.navigationController?.popViewController(animated: true)
    }
    
    func saveService() {
        service.clientId = client.id
        service.serviceId = Int64(Date().timeIntervalSince1970)
        if !Constants.databaseManager.servicesManager.addServiceInDatabase(newService: service) {
            CommonFunctions.showGenericAlertMessage(mensaje: "Error al guardar el servicio, intentelo de nuevo mas tarde", viewController: self)
        }
        
        Constants.cloudDatabaseManager.serviceManager.saveService(service: service)
    }
    
    func updateService() {
        if !Constants.databaseManager.servicesManager.updateServiceInDatabase(service: service) {
            CommonFunctions.showGenericAlertMessage(mensaje: "Error updating service, please try again", viewController: self)
        }
        
        Constants.cloudDatabaseManager.serviceManager.updateService(service: service, showLoadingState: true)
    }
}

extension AddServicioViewController {
    @IBAction func didClickFechaButton(_ sender: Any) {
        performSegue(withIdentifier: "DatePickerSelectorIdentifier", sender: nil)
    }
    
    @IBAction func didClickProfesionalButton(_ sender: Any) {
        performSegue(withIdentifier: "ListSelectorIdentifier", sender: 1)
    }
    
    @IBAction func didClickServicioButton(_ sender: Any) {
        performSegue(withIdentifier: "ListSelectorIdentifier", sender: 2)
    }
    
    @IBAction func didClickObservacion(_ sender: Any) {
        performSegue(withIdentifier: "FieldIdentifier", sender: 0)
    }
    
    @IBAction func didClickSaveButton(_ sender: Any) {
        checkFields()
    }
}

extension AddServicioViewController: DatePickerSelectorProtocol {
    func dateSelected(date: Date) {
        service.fecha = Int64(date.timeIntervalSince1970)
        fechaLabel.text = CommonFunctions.getDateAndTimeTypeStringFromDate(date: date)
    }
}

extension AddServicioViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DatePickerSelectorIdentifier" {
            let controller: DatePickerSelectorViewController = segue.destination as! DatePickerSelectorViewController
            controller.delegate = self
            controller.datePickerMode = .dateAndTime
            controller.initialDate = service.fecha
        } else if segue.identifier == "FieldIdentifier" {
            let controller: FieldViewController = segue.destination as! FieldViewController
            controller.inputReference = (sender as! Int)
            controller.delegate = self
            controller.keyboardType = .default
            controller.inputText = service.observacion
        } else if segue.identifier == "ListSelectorIdentifier" {
            let controller: ListSelectorViewController = segue.destination as! ListSelectorViewController
            controller.delegate = self
            controller.inputReference = (sender as! Int)
            controller.listOptions = getArrayForInputReference(inputReference: (sender as! Int))
            controller.allowMultiselection = (sender as! Int) == 2 ? true : false
        }
    }
}

extension AddServicioViewController: AddClientInputFieldProtocol {
    func textSaved(text: String, inputReference: Int) {
        service.observacion = text
        observacionLabel.text = text
    }
}

extension AddServicioViewController: ListSelectorProtocol {
    func multiSelectionOptionsSelected(options: [Any], inputReference: Int) {
        switch inputReference {
            case 2:
                service.servicio = CommonFunctions.getServiciosIdentifiers(servicios: (options as! [TipoServicioModel]))
                servicioLabel.text = CommonFunctions.getServiciosString(servicios: (options as! [TipoServicioModel]))
            default:
                break
        }
    }
    
    func optionSelected(option: Any, inputReference: Int) {
        switch inputReference {
        case 1:
            service.profesional = (option as! EmpleadoModel).empleadoId
            professionalLabel.text = (option as! EmpleadoModel).nombre
        default:
            service.servicio = [(option as! TipoServicioModel).servicioId]
            servicioLabel.text = (option as! TipoServicioModel).nombre
        }
    }
}

