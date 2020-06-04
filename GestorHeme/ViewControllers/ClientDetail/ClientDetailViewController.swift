//
//  EditClientViewController.swift
//  GestorHeme
//
//  Created by jon mikel on 02/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit
import RMDateSelectionViewController

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
    @IBOutlet weak var alarmView: UIView!
    @IBOutlet weak var alarmImageView: UIImageView!
    @IBOutlet weak var clientImageView: UIImageView!
    
    var client: ClientModel!
    var services: [ServiceModel] = []
    var serviceViewsArray: [UIView] = []
    var addServicioButtonBottomAnchor: NSLayoutConstraint!
    var scrollRefreshControl: UIRefreshControl = UIRefreshControl()
    var modificacionHecha: Bool = false
    var sincronizandoCliente: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Detalle Cliente"
        addBackButton()
        CommonFunctions.customizeButton(button: addServicioView)
        CommonFunctions.customizeButton(button: alarmView)
        addRefreshControl()
        getClientDetails()
        
        if client.notificacionPersonalizada == 0 {
            deactivateAlarmButton()
        } else {
            activateAlarmButton()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Constants.rootController.setNotificationBarItemBadge()
    }
    
    func getClientDetails() {
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
        
        if client.imagen.count > 0 {
            let dataDecoded : Data = Data(base64Encoded: client.imagen, options: .ignoreUnknownCharacters)!
            clientImageView.image = UIImage(data: dataDecoded)
            clientImageView.layer.cornerRadius = 50
        } else {
            clientImageView.image = UIImage(named: "add_image")
        }
    }
    
    func showServices() {
        removeServicesViews()
        if services.count == 0 {
            addServicioButtonBottomAnchor = addServicioView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor, constant: -20)
            addServicioButtonBottomAnchor.isActive = true
            return
        } else if addServicioButtonBottomAnchor != nil {
            addServicioButtonBottomAnchor.isActive = false
        }
        
        var serviciosFuturos: [ServiceModel] = []
        var serviciosPasados: [ServiceModel] = []
        for service: ServiceModel in services {
            let fecha: Date = Date(timeIntervalSince1970: TimeInterval(service.fecha))
            fecha < Date() ? serviciosPasados.append(service) : serviciosFuturos.append(service)
        }
        
        if serviciosFuturos.count > 0 {
            addServiceHeaderWithText(text: "PRÓXIMOS SERVICIOS")
        }
        
        for service: ServiceModel in serviciosFuturos {
            let serviceView: ServicioView = ServicioView(service: service)
            serviceView.delegate = self
            scrollContentView.addSubview(serviceView)
            serviceViewsArray.append(serviceView)
        }
        
        if serviciosPasados.count > 0 {
            addServiceHeaderWithText(text: "ANTIGUOS SERVICIOS")
        }
        
        for service: ServiceModel in serviciosPasados {
            let serviceView: ServicioView = ServicioView(service: service)
            serviceView.delegate = self
            scrollContentView.addSubview(serviceView)
            serviceViewsArray.append(serviceView)
        }
        
        setServicesConstraints()
    }
    
    func addServiceHeaderWithText(text: String) {
        let headerLabel: UILabel = UILabel()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.text = text
        headerLabel.textColor = .black
        headerLabel.font = .systemFont(ofSize: 15)
        scrollContentView.addSubview(headerLabel)
        serviceViewsArray.append(headerLabel)
    }
    
    func setServicesConstraints() {
        var previousView: UIView = addServicioView
        for serviceView: UIView in serviceViewsArray {
            serviceView.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 20).isActive = true
            serviceView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -15).isActive = true
            serviceView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 15).isActive = true
            
            previousView = serviceView
        }
        
        scrollContentView.bottomAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 30).isActive = true
    }
    
    
    func sortServicesByDate() {
        return services.sort(by: { $0.fecha > $1.fecha })
    }
    
    func removeServicesViews() {
        for view: UIView in serviceViewsArray {
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
        
        if telefonoLabel.text!.count < 9 {
            CommonFunctions.showGenericAlertMessage(mensaje: "Debe incluir un número de contacto", viewController: self)
            return
        }
        
        updateClient()
    }
    
    func updateClient() {
        sincronizandoCliente = true
        CommonFunctions.showLoadingStateView(descriptionText: "Actualizando cliente")
        Constants.cloudDatabaseManager.clientManager.updateClient(client: client, delegate: self, notificationDelegate: nil)
    }
    
    func addRefreshControl() {
        scrollRefreshControl.addTarget(self, action: #selector(refreshClient), for: .valueChanged)
        srollView.refreshControl = scrollRefreshControl
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
    
    func showDateSelectionPicker() {
        let selectAction: RMAction<UIDatePicker> = RMAction(title: "Aceptar", style: .done) { (controller) in
            let fecha: Int64 = Int64(controller.contentView.date.timeIntervalSince1970)
            self.client.notificacionPersonalizada = fecha
            self.updateClientForNotificacionPersonalizada()
        }!
        let cancelAction: RMAction<UIDatePicker> = RMAction(title: "Cancelar", style: .cancel, andHandler: nil)!
        
        let dateSelector: RMDateSelectionViewController = RMDateSelectionViewController(style: .white, title: "Seleccione", message: "Seleccione una fecha", select: selectAction, andCancel: cancelAction)!
        dateSelector.datePicker.datePickerMode = .date
        self.present(dateSelector, animated: true, completion: nil)
    }
    
    func activateAlarmButton() {
        alarmImageView.image = UIImage(named: "campana")?.withRenderingMode(.alwaysTemplate)
        alarmImageView.tintColor = .link
        alarmView.layer.borderColor = UIColor.link.cgColor
    }
    
    func deactivateAlarmButton() {
        alarmImageView.image = UIImage(named: "campana")?.withRenderingMode(.alwaysTemplate)
        alarmImageView.tintColor = .systemGray4
        alarmView.layer.borderColor = UIColor.systemGray4.cgColor
    }
    
    func updateClientForNotificacionPersonalizada() {
        CommonFunctions.showLoadingStateView(descriptionText: "Actualizando cliente")
        Constants.cloudDatabaseManager.clientManager.updateClient(client: client, delegate: nil, notificationDelegate: self)
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
    
    @IBAction func didClickImageView(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
    @objc func refreshClient() {
        Constants.cloudDatabaseManager.serviceManager.getServiciosPorCliente(clientId: client.id, delegate: self)
    }
    
    @objc func didClickBackButton(sender: UIBarButtonItem) {
        if !modificacionHecha {
            self.navigationController?.popViewController(animated: true)
        } else {
            showChangesAlertMessage()
        }
    }
    
    @IBAction func didClickAlarmView(_ sender: Any) {
        if client.notificacionPersonalizada == 0 {
            showDateSelectionPicker()
        } else {
            client.notificacionPersonalizada = 0
            updateClientForNotificacionPersonalizada()
        }
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
            controller.title = getControllerTitleForInputReference(inputReference: (sender as! Int))
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
    
    func getControllerTitleForInputReference(inputReference: Int) -> String {
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
    
    func updateServices(services: [ServiceModel]) {
        for service: ServiceModel in services {
            service.nombre = client.nombre
            service.apellidos = client.apellidos
        }
        
        Constants.cloudDatabaseManager.serviceManager.updateServices(services: services, delegate: self)
    }
}

extension ClientDetailViewController: DatePickerSelectorProtocol {
    func dateSelected(date: Date) {
        modificacionHecha = true
        client.fecha = Int64(date.timeIntervalSince1970)
        fechaLabel.text = CommonFunctions.getTimeTypeStringFromDate(date: date)
    }
}

extension ClientDetailViewController: AddClientInputFieldProtocol {
    func textSaved(text: String, inputReference: Int) {
        modificacionHecha = true
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
        modificacionHecha = true
    }
}

extension ClientDetailViewController: CloudServiceManagerProtocol {
    func serviceSincronizationFinished() {
        DispatchQueue.main.async {
            if self.sincronizandoCliente {
                print("EXITO ACTUALIZANDO SERVICIOS")
                self.sincronizandoCliente = false
                CommonFunctions.hideLoadingStateView()

                if !Constants.databaseManager.clientsManager.updateClientInDatabase(client: self.client) {
                    CommonFunctions.showGenericAlertMessage(mensaje: "Error actualizando cliente, intentelo de nuevo", viewController: self)
                }
                
                if !Constants.databaseManager.servicesManager.updateServicesForClientId(clientId: self.client.id) {
                    CommonFunctions.showGenericAlertMessage(mensaje: "Error actualizando servicios, intentelo de nuevo", viewController: self)
                }
                
                self.navigationController!.popViewController(animated: true)
            } else {
                print("EXITO CARGANDO SERVICIOS")
                self.scrollRefreshControl.endRefreshing()
                self.getClientDetails()
            }
        }
    }
    
    func serviceSincronizationError(error: String) {
        DispatchQueue.main.async {
            if self.sincronizandoCliente {
                print("ERROR ACTUALIZANDO SERVICIOS")
                self.sincronizandoCliente = false
                CommonFunctions.hideLoadingStateView()
            } else {
                print("ERROR CARGANDO SERVICIOS")
            }
            
            CommonFunctions.showGenericAlertMessage(mensaje: error, viewController: self)
        }
    }
}

extension ClientDetailViewController: CloudClientManagerProtocol {
    func clientSincronizationFinished() {
        let services: [ServiceModel] = Constants.databaseManager.servicesManager.getServicesForClientId(clientId: client.id)
        print("EXITO ACTUALIZANDO CLIENTE")
        if services.count == 0 {
            DispatchQueue.main.async {
                self.sincronizandoCliente = false
                CommonFunctions.hideLoadingStateView()
                if !Constants.databaseManager.clientsManager.updateClientInDatabase(client: self.client) {
                    CommonFunctions.showGenericAlertMessage(mensaje: "Error actualizando cliente, intentelo de nuevo", viewController: self)
                    return
                }
                
                self.navigationController!.popViewController(animated: true)
            }
        } else {
            updateServices(services: services)
        }
    }
    
    func clientSincronizationError(error: String) {
        DispatchQueue.main.async {
            self.sincronizandoCliente = false
            CommonFunctions.hideLoadingStateView()
            CommonFunctions.showGenericAlertMessage(mensaje: error, viewController: self)
        }
    }
}

extension ClientDetailViewController: CloudNotificacionPersonalizadaProtocol {
    func clientUpdated() {
        if client.notificacionPersonalizada == 0 {
            let notifications: [NotificationModel] = Constants.databaseManager.notificationsManager.getAllNotificationsForClientAndNotificationType(notificationType: Constants.notificacionPersonalizadaIdentifier, clientId: client.id)
            if notifications.count == 0 {
                _ = Constants.databaseManager.clientsManager.updateClientInDatabase(client: client)
                updateNotificacionPersonalizada()
            } else {
                Constants.cloudDatabaseManager.notificationManager.deleteNotifications(notifications: notifications, notificationType: Constants.notificacionPersonalizadaIdentifier, clientId: client.id, delegate: self)
            }
        } else {
            _ = Constants.databaseManager.clientsManager.updateClientInDatabase(client: client)
            updateNotificacionPersonalizada()
        }
    }
    
    func errorUpdatingClient(error: String) {
        DispatchQueue.main.async {
            CommonFunctions.hideLoadingStateView()
            CommonFunctions.showGenericAlertMessage(mensaje: "Error actualizando cliente", viewController: self)
        }
    }
    
    func updateNotificacionPersonalizada() {
        DispatchQueue.main.async {
            CommonFunctions.hideLoadingStateView()
            if self.client.notificacionPersonalizada == 0 {
                self.deactivateAlarmButton()
            } else {
                self.activateAlarmButton()
            }
        }
    }
}

extension ClientDetailViewController: CloudEliminarNotificationsProtocol {
    func succesDeletingNotification(notifications: [NotificationModel]) {
        _ = Constants.databaseManager.clientsManager.updateClientInDatabase(client: client)
        for notification in notifications {
            _ = Constants.databaseManager.notificationsManager.eliminarNotificacion(notificationId: notification.notificationId)
        }
        
        updateNotificacionPersonalizada()
    }
    
    func errorDeletingNotifications(error: String) {
        DispatchQueue.main.async {
            CommonFunctions.hideLoadingStateView()
            CommonFunctions.showGenericAlertMessage(mensaje: "Error eliminando notificación", viewController: self)
        }
    }
}

extension ClientDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        modificacionHecha = true
        clientImageView.layer.cornerRadius = 50
        let image = info[.originalImage] as! UIImage
        let resizedImage = CommonFunctions.resizeImage(image: image, targetSize: CGSize(width: 150, height: 150))
        self.clientImageView.image = resizedImage
        let imageData: Data = resizedImage.pngData()!
        let imageString: String = imageData.base64EncodedString()
        client.imagen = imageString
    }
}
