//
//  NotificationsViewController.swift
//  GestorHeme
//
//  Created by jon mikel on 09/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController {
    @IBOutlet weak var notificationsTableView: UITableView!
    @IBOutlet weak var cumpleView: UIView!
    @IBOutlet weak var cumpleLabel: UILabel!
    @IBOutlet weak var cadenciaView: UIView!
    @IBOutlet weak var cadenciaLabel: UILabel!
    @IBOutlet weak var facturacionView: UIView!
    @IBOutlet weak var facturacionLabel: UILabel!
    @IBOutlet weak var personalizadaLabel: UILabel!
    @IBOutlet weak var personalizadaView: UIView!
    
    var allNotifications: [NotificationModel] = []
    var todayNotifications: [NotificationModel] = []
    var oldNotifications: [NotificationModel] = []
    var emptyStateLabel: UILabel!
    var tableRefreshControl: UIRefreshControl = UIRefreshControl()
    
    var tapSelected: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        didClickcumpleButton("")
        addRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showNotifications()
        
        DispatchQueue.global().async {
            NotificationFunctions.checkAllNotifications()
        }
    }
    
    func showNotifications() {
        todayNotifications.removeAll()
        oldNotifications.removeAll()
        if emptyStateLabel != nil {
            emptyStateLabel.removeFromSuperview()
            emptyStateLabel = nil
        }
        allNotifications = Constants.databaseManager.notificationsManager.getAllNotificationsForType(type: getNotificationType())
        
        if allNotifications.count > 0 {
            filterNotifications()
        } else {
            emptyStateLabel = CommonFunctions.createEmptyState(emptyText: "No hay notificaciones disponibles", parentView: self.view)
        }
        
        notificationsTableView.reloadData()
    }
    
    func addRefreshControl() {
        tableRefreshControl.addTarget(self, action: #selector(refreshNotifications), for: .valueChanged)
        notificationsTableView.refreshControl = tableRefreshControl
    }
    
    func filterNotifications() {
        let begginingOfDay: Int64 = Int64(NotificationFunctions.getBeginningOfDayFromDate(date: Date()).timeIntervalSince1970)
        let endDayOfDay: Int64 = Int64(NotificationFunctions.getEndOfDayFromDate(date: Date()).timeIntervalSince1970)
        
        for notification: NotificationModel in allNotifications {
            if notification.fecha > begginingOfDay && notification.fecha < endDayOfDay {
                todayNotifications.append(notification)
            } else {
                oldNotifications.append(notification)
            }
        }
    }
    
    func getNotificationModelForIndexPath(indexPath: IndexPath) -> NotificationModel {
        if indexPath.section == 0 && todayNotifications.count > 0 {
            return todayNotifications[indexPath.row]
        }
        
        return oldNotifications[indexPath.row]
    }
    
    func paintWholeButton(view: UIView, label: UILabel) {
        view.backgroundColor = .red
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.red.cgColor
        view.layer.cornerRadius = 10
        label.textColor = .white
    }
    
    func paintBorderButton(view: UIView, label: UILabel) {
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.red.cgColor
        view.layer.cornerRadius = 10
        label.textColor = .red
    }
    
    func getNotificationType() -> String {
        switch tapSelected {
        case 1:
            return Constants.notificacionCumpleIdentifier
        case 2:
            return Constants.notificacionCadenciaIdentifier
        case 3:
            return Constants.notificacionCajaCierreIdentifier
        default:
            return Constants.notificacionPersonalizadaIdentifier
        }
    }
    
    func openBirthdayDetail(notification: NotificationModel) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Notification", bundle:nil)
        let controller: NotificationDetailViewController = storyBoard.instantiateViewController(withIdentifier: "NotificationDetailViewController") as! NotificationDetailViewController
        controller.notification = notification
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    func openCierreCaja(notificacion: NotificationModel) {
        if notificacion.leido {
            CommonFunctions.showGenericAlertMessage(mensaje: "Cierre caja realizado en la fecha indicada", viewController: self)
            return
        }
        
        performSegue(withIdentifier: "cierreCajaIdentifier", sender: notificacion)
    }
    
    func openCadenciaDetail(notification: NotificationModel) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Notification", bundle:nil)
        let controller: CadenciaNotificationDetailViewController = storyBoard.instantiateViewController(withIdentifier: "CadenciaNotificationDetailViewController") as! CadenciaNotificationDetailViewController
        controller.notification = notification
        self.navigationController!.pushViewController(controller, animated: true)
        
    }
}

extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && todayNotifications.count > 0 {
            return todayNotifications.count
        } else {
            return oldNotifications.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numberOfSections = 0
        if todayNotifications.count > 0 {
            numberOfSections = numberOfSections + 1
        }
        
        if oldNotifications.count > 0 {
            numberOfSections = numberOfSections + 1
        }
        
        return numberOfSections
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NotificationCell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        cell.selectionStyle = .none
        cell.setupCell(notification: getNotificationModelForIndexPath(indexPath: indexPath))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tapSelected {
        case 1:
            openBirthdayDetail(notification: getNotificationModelForIndexPath(indexPath: indexPath))
        case 2:
            openCadenciaDetail(notification: getNotificationModelForIndexPath(indexPath: indexPath))
        case 3:
            openCierreCaja(notificacion: getNotificationModelForIndexPath(indexPath: indexPath))
        default:
            openBirthdayDetail(notification: getNotificationModelForIndexPath(indexPath: indexPath))
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0  && todayNotifications.count > 0 {
            return "Hoy"
        } else {
            return "Antiguas"
        }
    }
}

extension NotificationsViewController {
    @IBAction func didClickcumpleButton(_ sender: Any) {
        paintWholeButton(view: cumpleView, label: cumpleLabel)
        paintBorderButton(view: cadenciaView, label: cadenciaLabel)
        paintBorderButton(view: facturacionView, label: facturacionLabel)
        paintBorderButton(view: personalizadaView, label: personalizadaLabel)
        tapSelected = 1
        showNotifications()
    }
    
    @IBAction func didClickCadenciaButton(_ sender: Any) {
        paintWholeButton(view: cadenciaView, label: cadenciaLabel)
        paintBorderButton(view: cumpleView, label: cumpleLabel)
        paintBorderButton(view: facturacionView, label: facturacionLabel)
        paintBorderButton(view: personalizadaView, label: personalizadaLabel)
        tapSelected = 2
        showNotifications()
    }
    
    @IBAction func didClickFacturacionButton(_ sender: Any) {
        paintWholeButton(view: facturacionView, label: facturacionLabel)
        paintBorderButton(view: cumpleView, label: cumpleLabel)
        paintBorderButton(view: cadenciaView, label: cadenciaLabel)
        paintBorderButton(view: personalizadaView, label: personalizadaLabel)
        tapSelected = 3
        showNotifications()
    }
    
    @IBAction func didClickPersonalizada(_ sender: Any) {
        paintWholeButton(view: personalizadaView, label: personalizadaLabel)
        paintBorderButton(view: cumpleView, label: cumpleLabel)
        paintBorderButton(view: cadenciaView, label: cadenciaLabel)
        paintBorderButton(view: facturacionView, label: facturacionLabel)
        tapSelected = 4
        showNotifications()
    }
    
    @objc func refreshNotifications() {
        Constants.cloudDatabaseManager.notificationManager.getNotificaciones(delegate: self)
    }
}

extension NotificationsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cierreCajaIdentifier" {
            let notification: NotificationModel = sender as! NotificationModel
            let controller: CierreCajaViewController = segue.destination as! CierreCajaViewController
            controller.presentDate = Date(timeIntervalSince1970: TimeInterval(notification.fecha))
            controller.notification = notification
        }
    }
}

extension NotificationsViewController: CloudNotificationProtocol {
    func notificacionSincronizationFinished() {
        DispatchQueue.main.async {
            self.tableRefreshControl.endRefreshing()
            self.showNotifications()
            Constants.rootController.setNotificationBarItemBadge()
        }
    }
    
    func notificacionSincronizationError(error: String) {
        DispatchQueue.main.async {
            CommonFunctions.showGenericAlertMessage(mensaje: "Error cargando notificaciones", viewController: self)
        }
    }
}
