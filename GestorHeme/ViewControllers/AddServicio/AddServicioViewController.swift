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
    @IBOutlet weak var precioLabel: UILabel!
    
    var client: ClientModel!
    var service: ServiceModel = ServiceModel()
    var modifyService: Bool = false
    var delegate: AddServicioProtocol!
    var modificacionHecha: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title =  modifyService ? "Servicio" : "Nuevo Servicio"
        addBackButton()
        setMainValues()
        print(service.serviceId)
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
        professionalLabel.text = Constants.databaseManager.empleadosManager.getEmpleadoFromDatabase(empleadoId: service.profesional)?.nombre
        servicioLabel.text = CommonFunctions.getServiciosStringFromServiciosArray(servicios: service.servicio)
        observacionLabel.text = service.observacion
        precioLabel.text = String(format: "%.2f", service.precio) + " €"
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
        } else {
            delegate.serviceContentFilled(service: service, serviceUpdated: modifyService)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func saveService() {
        CommonFunctions.showLoadingStateView(descriptionText: "Guardando servicio")
        service.clientId = client.id
        service.serviceId = Int64(Date().timeIntervalSince1970)

        Constants.cloudDatabaseManager.serviceManager.saveService(service: service, delegate: self)
    }
    
    func updateService() {
        CommonFunctions.showLoadingStateView(descriptionText: "Actualizando servicio")
        
        Constants.cloudDatabaseManager.serviceManager.updateService(service: service, delegate: self)
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
    
    func addBackButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .done, target: self, action: #selector(didClickBackButton))
    }
    
    func updateNotifications(notifications: [NotificationModel]) {
        var notificacionesEliminar: [NotificationModel] = []
        var notificacionesAActualizar: [NotificationModel] = []
        for notification in notifications {
            notification.clientId = notification.clientId.filter {$0 != client.id}
            if notification.clientId.count == 0 {
                notificacionesEliminar.append(notification)
            } else {
                notificacionesAActualizar.append(notification)
            }
        }

        if notificacionesAActualizar.count > 0 {
            Constants.cloudDatabaseManager.notificationManager.saveNotifications(notifications: notificacionesAActualizar, delegate: self)
        } else if notificacionesEliminar.count > 0 {
            Constants.cloudDatabaseManager.notificationManager.deleteNotifications(notifications: notificacionesEliminar, notificationType: Constants.notificacionCadenciaIdentifier, clientId: client.id, delegate: self)
        }
    }
    
    func getTitleForInputReference(inputReference: Int) -> String {
        switch inputReference {
        case 0:
            return "Precio"
        default:
            return "Observaciones"
        }
    }
    
    func getValueForInputReference(inputReference: Int) -> String {
        switch inputReference {
        case 0:
            return service.precio > 0 ? String(format: "%.2f", service.precio) : ""
        default:
            return service.observacion
        }
    }
    
    func getKeyboardTypeForInputReference(inputReference: Int) -> UIKeyboardType {
        switch inputReference {
        case 0:
            return .decimalPad
        default:
            return .default
        }
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
        performSegue(withIdentifier: "FieldIdentifier", sender: 1)
    }
    
    @IBAction func didClickSaveButton(_ sender: Any) {
        checkFields()
    }
    
    @IBAction func didClickPrecioButton(_ sender: Any) {
        performSegue(withIdentifier: "FieldIdentifier", sender: 0)
    }
    
    @objc func didClickBackButton(sender: UIBarButtonItem) {
        if modifyService {
            if !modificacionHecha {
                self.navigationController?.popViewController(animated: true)
            } else {
                showChangesAlertMessage()
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension AddServicioViewController: DatePickerSelectorProtocol {
    func dateSelected(date: Date) {
        modificacionHecha = true
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
            controller.keyboardType = getKeyboardTypeForInputReference(inputReference: (sender as! Int))
            controller.inputText = getValueForInputReference(inputReference: (sender as! Int))
            controller.title = getTitleForInputReference(inputReference: (sender as! Int))
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
        modificacionHecha = true
        
        switch inputReference {
        case 0:
            let value = text.replacingOccurrences(of: ",", with: ".")
            precioLabel.text = value + " €"
            service.precio = (value as NSString).doubleValue
            break
        default:
            service.observacion = text
            observacionLabel.text = text
        }
    }
}

extension AddServicioViewController: ListSelectorProtocol {
    func multiSelectionOptionsSelected(options: [Any], inputReference: Int) {
        modificacionHecha = true
        switch inputReference {
            case 2:
                service.servicio = CommonFunctions.getServiciosIdentifiers(servicios: (options as! [TipoServicioModel]))
                servicioLabel.text = CommonFunctions.getServiciosString(servicios: (options as! [TipoServicioModel]))
            default:
                break
        }
    }
    
    func optionSelected(option: Any, inputReference: Int) {
        modificacionHecha = true
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

extension AddServicioViewController: CloudServiceManagerProtocol {
    func serviceSincronizationFinished() {
        if !modifyService {
            let notifications: [NotificationModel] = Constants.databaseManager.notificationsManager.getAllNotificationsForClientAndNotificationType(notificationType: Constants.notificacionCadenciaIdentifier, clientId: client.id)
            if notifications.count == 0 {
                saveServiceInDatabase()
            } else {
                updateNotifications(notifications: notifications)
            }
        } else {
            updateServiceInDatabase()
        }
    }
    
    func saveServiceInDatabase() {
        print("EXITO GUARDANDO SERVICIO")
        if !Constants.databaseManager.servicesManager.addServiceInDatabase(newService: service) {
            DispatchQueue.main.async {
                CommonFunctions.hideLoadingStateView()
                CommonFunctions.showGenericAlertMessage(mensaje: "Error al guardar el servicio, intentelo de nuevo mas tarde", viewController: self)
            }
            return
        }
        
        returnToPreviousScreen()
    }
    
    func updateServiceInDatabase() {
        print("EXITO ACTUALIZANDO SERVICIO")
        if !Constants.databaseManager.servicesManager.updateServiceInDatabase(service: service) {
            DispatchQueue.main.async {
                CommonFunctions.hideLoadingStateView()
                CommonFunctions.showGenericAlertMessage(mensaje: "Error updating service, please try again", viewController: self)
            }
            return
        }
        
        returnToPreviousScreen()
    }
    
    func returnToPreviousScreen() {
        DispatchQueue.main.async {
            CommonFunctions.hideLoadingStateView()
            self.delegate.serviceContentFilled(service: self.service, serviceUpdated: self.modifyService)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func serviceSincronizationError(error: String) {
        print("ERROR SINCRONIZANDO SERVICIO")
        DispatchQueue.main.async {
            CommonFunctions.hideLoadingStateView()
            CommonFunctions.showGenericAlertMessage(mensaje: "Error sincronizando el servicio", viewController: self)
        }
    }
}

extension AddServicioViewController: CloudNotificationProtocol {
    func notificacionSincronizationError(error: String) {
        DispatchQueue.main.async {
            CommonFunctions.hideLoadingStateView()
            CommonFunctions.showGenericAlertMessage(mensaje: error, viewController: self)
        }
    }
    
    func notificacionSincronizationFinished() {
        print("EXITO GUARDANDO SERVICIO")
        _ = Constants.databaseManager.servicesManager.addServiceInDatabase(newService: service)
        
        print("EXITO ACTUALIZANDO NOTIFICACIONES")
        _ = Constants.databaseManager.notificationsManager.updateNotificationsForClientAndType(notificationType: Constants.notificacionCadenciaIdentifier, clientId: client.id)
        
        returnToPreviousScreen()
    }
}

extension AddServicioViewController: CloudEliminarNotificationsProtocol {
    func succesDeletingNotification(notifications: [NotificationModel]) {
        _ = Constants.databaseManager.servicesManager.addServiceInDatabase(newService: service)
        
        for notificacion in notifications {
            _ = Constants.databaseManager.notificationsManager.eliminarNotificacion(notificationId: notificacion.notificationId)
        }
        
        returnToPreviousScreen()
    }
    
    func errorDeletingNotifications(error: String) {
        print("ERROR SINCRONIZANDO SERVICIO")
        DispatchQueue.main.async {
            CommonFunctions.hideLoadingStateView()
            CommonFunctions.showGenericAlertMessage(mensaje: "Error sincronizando el servicio", viewController: self)
        }
    }
}

