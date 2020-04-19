//
//  EditClientViewController.swift
//  GestorHeme
//
//  Created by jon mikel on 02/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit

class ClientDetailViewController: UIViewController {
    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var apellidosLabel: UILabel!
    @IBOutlet weak var fechaLabel: UILabel!
    @IBOutlet weak var telefonoLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var direccionLabel: UILabel!
    @IBOutlet weak var cadenciaLabel: UILabel!
    @IBOutlet weak var observacionesLabel: UILabel!
    @IBOutlet weak var srollView: UIScrollView!
    @IBOutlet weak var observacionesView: UIView!
    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var addServicioView: UIView!
    
    var client: ClientModel!
    var services: [ServiceModel] = []
    var serviceViewsArray: [ServicioView] = []
    var addServicioButtonBottomAnchor: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Detalle Cliente"
        CommonFunctions.customizeButton(button: addServicioView)
        services = Constants.databaseManager.servicesManager.getServicesForClientId(clientId: client.id)
        sortServicesByDate()
        
        setFields()
        showServices()
    }
    
    func setFields() {
        nombreLabel.text = client.nombre
        apellidosLabel.text = client.apellidos
        fechaLabel.text = CommonFunctions.getTimeTypeStringFromDate(date: Date(timeIntervalSince1970: TimeInterval(client.fecha)))
        telefonoLabel.text = client.telefono
        emailLabel.text = client.email
        direccionLabel.text = client.direccion
        cadenciaLabel.text = client.cadenciaVisita
        observacionesLabel.text = client.observaciones
        
        if observacionesLabel.text!.count == 0 {
            observacionesLabel.text = "Añade una observación"
        }
    }
    
    func showServices() {
        if services.count == 0 {
            addServicioButtonBottomAnchor = addServicioView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor, constant: -20)
            addServicioButtonBottomAnchor.isActive = true
            return
        } else if addServicioButtonBottomAnchor != nil {
            addServicioButtonBottomAnchor.isActive = false
        }
        
        var previousView: UIView = addServicioView
        for service: ServiceModel in services {
            let serviceView: ServicioView = ServicioView(service: service)
            serviceView.delegate = self
            scrollContentView.addSubview(serviceView)
            
            serviceView.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 30).isActive = true
            serviceView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -15).isActive = true
            serviceView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 15).isActive = true
            
            serviceViewsArray.append(serviceView)
            previousView = serviceView
        }
        
        scrollContentView.bottomAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 30).isActive = true
    }
    
    func sortServicesByDate() {
        return services.sort(by: { $0.fecha > $1.fecha })
    }
    
    func removeServicesViews() {
        for view: ServicioView in serviceViewsArray {
            view.removeFromSuperview()
        }
        
        serviceViewsArray = []
    }
    
    func checkFields() {
        if nombreLabel.text!.count == 0 {
            CommonFunctions.showGenericAlertMessage(mensaje: "Debe incluir el nombre del cliente", viewController: self)
            return
        }
        
        if apellidosLabel.text!.count == 0 {
            CommonFunctions.showGenericAlertMessage(mensaje: "Debe incluir por lo menos un apellido del cliente", viewController: self)
            return
        }
        
        if fechaLabel.text!.count == 0 {
            CommonFunctions.showGenericAlertMessage(mensaje: "Debe incluir la fecha de nacimiento", viewController: self)
            return
        }
        
        if telefonoLabel.text!.count < 9 {
            CommonFunctions.showGenericAlertMessage(mensaje: "Debe incluir un número de contacto", viewController: self)
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
        
        if cadenciaLabel.text!.count == 0 {
            CommonFunctions.showGenericAlertMessage(mensaje: "Debe incluir una etimación de cada cuanto viene el cliente", viewController: self)
            return
        }
        
        updateClient()
    }
    
    func updateClient() {
        if !Constants.databaseManager.clientsManager.updateClientInDatabase(client: client) {
            CommonFunctions.showGenericAlertMessage(mensaje: "Error actualizando usuario, intentelo de nuevo", viewController: self)
            return
        }
        
        Constants.cloudDatabaseManager.clientManager.updateClient(client: client)
        
        self.navigationController!.popViewController(animated: true)
    }
}

extension ClientDetailViewController {
    @IBAction func didClickNombreField(_ sender: Any) {
        performSegue(withIdentifier: "FieldIdentifier", sender: 1)
    }
    
    @IBAction func didClickApellidosField(_ sender: Any) {
        performSegue(withIdentifier: "FieldIdentifier", sender: 2)
    }
    
    @IBAction func didClickFechaField(_ sender: Any) {
        performSegue(withIdentifier: "DateIdentifier", sender: nil)
    }
    
    @IBAction func didClickTelefonoField(_ sender: Any) {
        performSegue(withIdentifier: "FieldIdentifier", sender: 3)
    }
    
    @IBAction func didClickEmailField(_ sender: Any) {
        performSegue(withIdentifier: "FieldIdentifier", sender: 4)
    }
    
    @IBAction func didClickDireccionField(_ sender: Any) {
        performSegue(withIdentifier: "FieldIdentifier", sender: 5)
    }
    
    @IBAction func didClickCadenciaField(_ sender: Any) {
        performSegue(withIdentifier: "pickerSelectorIdentifier", sender: nil)
    }
    
    @IBAction func didClickObservacionesField(_ sender: Any) {
        performSegue(withIdentifier: "FieldIdentifier", sender: 7)
    }
    
    @IBAction func didClickSaveInfoButton(_ sender: Any) {
        checkFields()
    }
    
    @IBAction func didClickAddServicioButton(_ sender: Any) {
        performSegue(withIdentifier: "AddServicioIdentifier", sender: nil)
    }
    
    @IBAction func didClickCallButton(_ sender: Any) {
        CommonFunctions.callPhone(telefono: client.telefono.replacingOccurrences(of: " ", with: ""))
    }
}

extension ClientDetailViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FieldIdentifier" {
            let controller: FieldViewController = segue.destination as! FieldViewController
            controller.inputReference = (sender as! Int)
            controller.delegate = self
            controller.keyboardType = getKeyboardTypeForField(inputReference: (sender as! Int))
            controller.inputText = getInputTextForField(inputReference: (sender as! Int))
        } else if segue.identifier == "DateIdentifier" {
            let controller: DatePickerSelectorViewController = segue.destination as! DatePickerSelectorViewController
            controller.delegate = self
            controller.datePickerMode = .date
            controller.initialDate = client.fecha
        } else if segue.identifier == "AddServicioIdentifier" {
            let controller: AddServicioViewController = segue.destination as! AddServicioViewController
            controller.client = client
            controller.delegate = self
            if let update: [String : Any] = sender as? [String : Any] {
                controller.modifyService = (update["update"] as! Bool)
                controller.service = update["service"] as! ServiceModel
            }
        } else if segue.identifier == "pickerSelectorIdentifier" {
            let controller: PickerSelectorViewController = segue.destination as! PickerSelectorViewController
            controller.delegate = self
        }
    }
    
    func getKeyboardTypeForField(inputReference: Int) -> UIKeyboardType {
        switch inputReference {
        case 3:
            return .phonePad
        case 4:
            return .emailAddress
        default:
            return .default
        }
    }
    
    func getInputTextForField(inputReference: Int) -> String {
        switch inputReference {
        case 1:
            return nombreLabel.text!
        case 2:
            return apellidosLabel.text!
        case 3:
            return telefonoLabel.text!
        case 4:
            return emailLabel.text!
        case 5:
            return direccionLabel.text!
        default:
            return client.observaciones
        }
    }
}

extension ClientDetailViewController: DatePickerSelectorProtocol {
    func dateSelected(date: Date) {
        client.fecha = Int64(date.timeIntervalSince1970)
        fechaLabel.text = CommonFunctions.getTimeTypeStringFromDate(date: date)
    }
}

extension ClientDetailViewController: AddClientInputFieldProtocol {
    func textSaved(text: String, inputReference: Int) {
        switch inputReference {
        case 1:
            client.nombre = text
            nombreLabel.text = text
            break
        case 2:
            client.apellidos = text
            apellidosLabel.text = text
            break
        case 3:
            client.telefono = text
            telefonoLabel.text = text
            break
        case 4:
            client.email = text
            emailLabel.text = text
            break
        case 5:
            client.direccion = text
            direccionLabel.text = text
            break
        default:
            client.observaciones = text
            observacionesLabel.text = text
            break
        }
    }
}

extension ClientDetailViewController: AddServicioProtocol {
    func serviceContentFilled(service: ServiceModel, serviceUpdated: Bool) {
        if serviceUpdated {
            services = Constants.databaseManager.servicesManager.getServicesForClientId(clientId: client.id)
        } else {
            service.serviceId = Int64(Date().timeIntervalSince1970)
            services.append(service)
        }
        
        sortServicesByDate()
        removeServicesViews()
        showServices()
    }
}

extension ClientDetailViewController: ServicioViewProtocol {
    func servicioClicked(service: ServiceModel) {
        performSegue(withIdentifier: "AddServicioIdentifier", sender: ["update" :  true, "service" : service])
    }
}

extension ClientDetailViewController: PickerSelectorProtocol {
    func cadenciaSelected(cadencia: String) {
        cadenciaLabel.text = cadencia
        client.cadenciaVisita = cadencia
    }
    
    
}
