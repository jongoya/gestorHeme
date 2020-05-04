//
//  AddClientViewController.swift
//  GestorHeme
//
//  Created by jon mikel on 01/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit

class AddClientViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nombreView: UIView!
    @IBOutlet weak var apellidosView: UIView!
    @IBOutlet weak var fechaView: UIView!
    @IBOutlet weak var telefonoView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var direccionView: UIView!
    @IBOutlet weak var cadenciaView: UIView!
    @IBOutlet weak var observacionesView: UIView!
    @IBOutlet weak var addServicioView: UIView!
    @IBOutlet weak var scrollContentView: UIView!
    
    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var apellidosLabel: UILabel!
    @IBOutlet weak var fechaLabel: UILabel!
    @IBOutlet weak var telefonoLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var direccionLabel: UILabel!
    @IBOutlet weak var cadenciaLabel: UILabel!
    @IBOutlet weak var observacionesLabel: UILabel!
    @IBOutlet weak var addServicioTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var clientImageView: UIImageView!
    @IBOutlet weak var clientImageContainer: UIView!
    
    var newClient: ClientModel = ClientModel()
    var servicios: [ServiceModel] = []
    var addServicioPreviousView: UIView!
    var delegate: AddClientProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CommonFunctions.customizeButton(button: addServicioView)
        title = "Añadir Cliente"
        addServicioPreviousView = observacionesView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if delegate != nil {
            addServicioView.isHidden = true
        }
    }
    
    func customizeImageView() {
        clientImageView.layer.cornerRadius = 50
    }
    
    func showServicio(servicio: ServiceModel) {
        let view: ServicioView = ServicioView(service: servicio)
        scrollContentView.addSubview(view)
        view.topAnchor.constraint(equalTo: addServicioPreviousView.bottomAnchor, constant: 30).isActive = true
        view.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 15).isActive = true
        view.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -15).isActive = true
        addServicioPreviousView = view
        
        addServicioTopConstraint = addServicioView.topAnchor.constraint(equalTo: addServicioPreviousView.bottomAnchor, constant: 30)
        addServicioTopConstraint.isActive = true
        addServicioView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor, constant: -20).isActive = true
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
        
        if telefonoLabel.text!.count < 9 {
            CommonFunctions.showGenericAlertMessage(mensaje: "Debe incluir un número de contacto válido", viewController: self)
            return
        }
        
        saveClient()
    }
    
    func saveClient() {
        CommonFunctions.showLoadingStateView(descriptionText: "Guardando cliente")
        newClient.id = Int64(Date().timeIntervalSince1970)
        Constants.cloudDatabaseManager.clientManager.saveClient(client: newClient, delegate: self)
    }
    
    func saveServices() {
        for servicio: ServiceModel in servicios {
            servicio.clientId = newClient.id
        }
        
        Constants.cloudDatabaseManager.serviceManager.saveServices(services: servicios, delegate: self)
    }
}

extension AddClientViewController {
    @IBAction func didClickAñadirServicioButton(_ sender: Any) {
        if newClient.nombre.count == 0 || newClient.apellidos.count == 0 {
            CommonFunctions.showGenericAlertMessage(mensaje: "Debe incluir al menos el nombre y apellidos del cliente", viewController: self)
            return
        }
        
        performSegue(withIdentifier: "AddServicioIdentifier", sender: nil)
    }
    
    @IBAction func didClickNombreField(_ sender: Any) {
        performSegue(withIdentifier: "FieldIdentifier", sender: 1)
    }
    
    @IBAction func didClickApellidosField(_ sender: Any) {
        performSegue(withIdentifier: "FieldIdentifier", sender: 2)
    }
    
    @IBAction func didClickFechaField(_ sender: Any) {
        performSegue(withIdentifier: "DatePickerSelectorIdentifier", sender: nil)
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
        performSegue(withIdentifier: "pickerSelectorIdentifier", sender: 0)
    }
    
    @IBAction func didClickObservacionesField(_ sender: Any) {
        performSegue(withIdentifier: "FieldIdentifier", sender: 7)
    }
    
    @IBAction func didClickSaveClient(_ sender: Any) {
        checkFields()
    }
    
    @IBAction func didClickClientImage(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
}

extension AddClientViewController: AddClientInputFieldProtocol {
    func textSaved(text: String, inputReference: Int) {
        switch inputReference {
        case 1:
            newClient.nombre = text
            nombreLabel.text = text
            break
        case 2:
            newClient.apellidos = text
            apellidosLabel.text = text
            break
        case 3:
            newClient.telefono = text
            telefonoLabel.text = text
            break
        case 4:
            newClient.email = text
            emailLabel.text = text
            break
        case 5:
            newClient.direccion = text
            direccionLabel.text = text
            break
        default:
            newClient.observaciones = text
            observacionesLabel.text = text
            break
        }
    }
}

extension AddClientViewController: DatePickerSelectorProtocol {
    func dateSelected(date: Date) {
        newClient.fecha = Int64(date.timeIntervalSince1970)
        fechaLabel.text = CommonFunctions.getTimeTypeStringFromDate(date: date)
    }
}

extension AddClientViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FieldIdentifier" {
            let controller: FieldViewController = segue.destination as! FieldViewController
            controller.inputReference = (sender as! Int)
            controller.delegate = self
            controller.keyboardType = getKeyboardTypeForField(inputReference: (sender as! Int))
            controller.inputText = getInputTextForField(inputReference: (sender as! Int))
            controller.title = getControllerTitleForField(inputReference: (sender as! Int))
        } else if segue.identifier == "DatePickerSelectorIdentifier" {
            let controller: DatePickerSelectorViewController = segue.destination as! DatePickerSelectorViewController
            controller.delegate = self
            controller.datePickerMode = .date
            controller.initialDate = newClient.fecha
        } else if segue.identifier == "AddServicioIdentifier" {
            let controller: AddServicioViewController = segue.destination as! AddServicioViewController
            controller.client = newClient
            controller.delegate = self
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
            return newClient.observaciones
        }
    }
    
    func getControllerTitleForField(inputReference: Int) -> String {
        switch inputReference {
        case 1:
            return "Nombre"
        case 2:
            return "Apellidos"
        case 3:
            return "Telefono"
        case 4:
            return "Email"
        case 5:
            return "Dirección"
        default:
            return "Observaciones"
        }
    }
}

extension AddClientViewController: AddServicioProtocol {
    func serviceContentFilled(service: ServiceModel, serviceUpdated: Bool) {
        service.serviceId = Int64(Date().timeIntervalSince1970)
        servicios.append(service)
        addServicioTopConstraint.isActive = false
        showServicio(servicio: service)
    }
}

extension AddClientViewController: PickerSelectorProtocol {
    func cadenciaSelected(cadencia: String) {
        cadenciaLabel.text = cadencia
        newClient.cadenciaVisita = cadencia
    }
}

extension AddClientViewController: CloudClientManagerProtocol {
    func clientSincronizationFinished() {
        print("EXITO AÑADIENDO CLIENTE")
        if servicios.count == 0 {
            if !Constants.databaseManager.clientsManager.addClientToDatabase(newClient: newClient) {
                DispatchQueue.main.async {
                    CommonFunctions.hideLoadingStateView()
                    CommonFunctions.showGenericAlertMessage(mensaje: "Error creando usuario, intentelo de nuevo", viewController: self)
                }
                return
            }
            
            DispatchQueue.main.async {
                CommonFunctions.hideLoadingStateView()
                if self.delegate != nil {
                    self.delegate.clientAdded(client: self.newClient)
                }
                
                self.navigationController!.popViewController(animated: true)
            }
        } else {
            saveServices()
        }
    }
    
    func clientSincronizationError(error: String) {
        DispatchQueue.main.async {
            print("ERROR GUARDANDO CLIENTE")
            CommonFunctions.hideLoadingStateView()
            CommonFunctions.showGenericAlertMessage(mensaje: error, viewController: self)
        }
    }
}

extension AddClientViewController: CloudServiceManagerProtocol {
    func serviceSincronizationFinished() {
        print("EXITO GUARDANDO SERVICIOS")
        if !Constants.databaseManager.clientsManager.addClientToDatabase(newClient: newClient) {
            DispatchQueue.main.async {
                CommonFunctions.hideLoadingStateView()
                CommonFunctions.showGenericAlertMessage(mensaje: "Error guardando cliente, intentelo de nuevo", viewController: self)
            }
            return
        }
        
        for servicio: ServiceModel in servicios {
            if !Constants.databaseManager.servicesManager.addServiceInDatabase(newService: servicio) {
                DispatchQueue.main.async {
                    CommonFunctions.hideLoadingStateView()
                    CommonFunctions.showGenericAlertMessage(mensaje: "Error guardando el servicio, intentelo de nuevo", viewController: self)
                }
                return
            }
        }
        
        DispatchQueue.main.async {
            CommonFunctions.hideLoadingStateView()
            self.navigationController!.popViewController(animated: true)
        }
    }
    
    func serviceSincronizationError(error: String) {
        DispatchQueue.main.async {
            print("ERROR GUARDANDO SERVICIOS")
            CommonFunctions.hideLoadingStateView()
            CommonFunctions.showGenericAlertMessage(mensaje: error, viewController: self)
        }
    }
}

extension AddClientViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        customizeImageView()
        let image = info[.originalImage] as! UIImage
        let resizedImage = CommonFunctions.resizeImage(image: image, targetSize: CGSize(width: 150, height: 150))
        self.clientImageView.image = resizedImage
        let imageData: Data = resizedImage.pngData()!
        let imageString: String = imageData.base64EncodedString()
        newClient.imagen = imageString
    }
}
