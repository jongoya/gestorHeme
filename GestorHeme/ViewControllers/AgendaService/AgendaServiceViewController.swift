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
    @IBOutlet weak var precioLabel: UILabel!
    
    var newService: ServiceModel = ServiceModel()
    var clientSeleced: ClientModel!
    var newDate: Date!
    var modificacionHecha: Bool = false
    var delegate: AgendaServiceProtocol!

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
    }
    
    func saveService() {
        newService.clientId = clientSeleced.id
        newService.serviceId = Int64(Date().timeIntervalSince1970)
        CommonFunctions.showLoadingStateView(descriptionText: "Guardando servicio")
        
        Constants.cloudDatabaseManager.serviceManager.saveService(service: newService, delegate: self)
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
            return newService.precio > 0 ? String(format: "%.2f", newService.precio) : ""
        default:
            return newService.observacion
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
    
    @IBAction func didClickPlusButton(_ sender: Any) {
        performSegue(withIdentifier: "AddClienteIdentifier", sender: nil)
    }
    
    @IBAction func didClickPrecioField(_ sender: Any) {
        performSegue(withIdentifier: "FieldIdentifier", sender: 0)
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
            controller.keyboardType = getKeyboardTypeForInputReference(inputReference: (sender as! Int))
            controller.inputText = getValueForInputReference(inputReference: (sender as! Int))
            controller.title = getTitleForInputReference(inputReference: (sender as! Int))
        } else if segue.identifier == "ListSelectorIdentifier" {
            let controller: ListSelectorViewController = segue.destination as! ListSelectorViewController
            controller.delegate = self
            controller.inputReference = (sender as! Int)
            controller.listOptions = getArrayForInputReference(inputReference: (sender as! Int))
            controller.allowMultiselection = (sender as! Int) == 2 ? true : false
        } else if segue.identifier == "ClientListIdentifier" {
            let controller: ClientListSelectorViewController = segue.destination as! ClientListSelectorViewController
            controller.delegate = self
        } else if segue.identifier == "AddClienteIdentifier" {
            let controller: AddClientViewController = segue.destination as! AddClientViewController
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
        modificacionHecha = true
        switch inputReference {
        case 0:
            let value = text.replacingOccurrences(of: ",", with: ".")
            precioLabel.text = value + " €"
            newService.precio = (value as NSString).doubleValue
            break
        default:
            newService.observacion = text
            observacionesLabel.text = text
        }
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

extension AgendaServiceViewController: CloudServiceManagerProtocol {
    func serviceSincronizationFinished() {
        let notifications: [NotificationModel] = Constants.databaseManager.notificationsManager.getAllNotificationsForClientAndNotificationType(notificationType: Constants.notificacionCadenciaIdentifier, clientId: clientSeleced.id)
        if notifications.count == 0 {
            saveServiceInDatabase()
        } else {
            updateNotifications(notifications: notifications)
        }
    }
    
    func serviceSincronizationError(error: String) {
        DispatchQueue.main.async {
            CommonFunctions.hideLoadingStateView()
            CommonFunctions.showGenericAlertMessage(mensaje: error, viewController: self)
        }
    }
    func saveServiceInDatabase() {
        print("EXITO GUARDANDO SERVICIO")
        _ = Constants.databaseManager.servicesManager.addServiceInDatabase(newService: newService)
        
        DispatchQueue.main.async {
            CommonFunctions.hideLoadingStateView()
            self.delegate.serviceAdded()
            self.navigationController!.popViewController(animated: true)
        }
    }
    
    func updateNotifications(notifications: [NotificationModel]) {
        var notificacionesEliminar: [NotificationModel] = []
        var notificacionesAActualizar: [NotificationModel] = []
        for notification in notifications {
            notification.clientId = notification.clientId.filter {$0 != clientSeleced.id}
            if notification.clientId.count == 0 {
                notificacionesEliminar.append(notification)
            } else {
                notificacionesAActualizar.append(notification)
            }
        }
        
        if notificacionesAActualizar.count > 0 {
            Constants.cloudDatabaseManager.notificationManager.saveNotifications(notifications: notificacionesAActualizar, delegate: self)
        } else if notificacionesEliminar.count > 0 {
            Constants.cloudDatabaseManager.notificationManager.deleteNotifications(notifications: notificacionesEliminar, notificationType: Constants.notificacionCadenciaIdentifier, clientId: clientSeleced.id, delegate: self)
        }
    }
}

extension AgendaServiceViewController: CloudNotificationProtocol {
    func notificacionSincronizationError(error: String) {
        DispatchQueue.main.async {
            CommonFunctions.hideLoadingStateView()
            CommonFunctions.showGenericAlertMessage(mensaje: error, viewController: self)
        }
    }
    
    func notificacionSincronizationFinished() {
        print("EXITO GUARDANDO SERVICIO")
        _ = Constants.databaseManager.servicesManager.addServiceInDatabase(newService: newService)
        
        print("EXITO ACTUALIZANDO NOTIFICACIONES")
        _ = Constants.databaseManager.notificationsManager.updateNotificationsForClientAndType(notificationType: Constants.notificacionCadenciaIdentifier, clientId: clientSeleced.id)
        
        DispatchQueue.main.async {
            CommonFunctions.hideLoadingStateView()
            self.delegate.serviceAdded()
            self.navigationController!.popViewController(animated: true)
        }
    }
}

extension AgendaServiceViewController: CloudEliminarNotificationsProtocol {
    func succesDeletingNotification(notifications: [NotificationModel]) {
        _ = Constants.databaseManager.servicesManager.addServiceInDatabase(newService: newService)
        
        for notificacion in notifications {
            _ = Constants.databaseManager.notificationsManager.eliminarNotificacion(notificationId: notificacion.notificationId)
        }
        
        DispatchQueue.main.async {
            CommonFunctions.hideLoadingStateView()
            self.delegate.serviceAdded()
            self.navigationController!.popViewController(animated: true)
        }
    }
    
    func errorDeletingNotifications(error: String) {
        DispatchQueue.main.async {
            CommonFunctions.hideLoadingStateView()
            CommonFunctions.showGenericAlertMessage(mensaje: "Error guardando el servicio", viewController: self)
        }
    }
}

extension AgendaServiceViewController: AddClientProtocol {
    func clientAdded(client: ClientModel) {
        clientSeleced = client
        newService.nombre = client.nombre
        newService.apellidos = client.apellidos
        nombreLabel.text = client.nombre + " " + client.apellidos
        modificacionHecha = true
    }
}
