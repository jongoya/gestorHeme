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
    
    
    
    var allNotifications: [NotificationModel] = []
    var todayNotifications: [NotificationModel] = []
    var oldNotifications: [NotificationModel] = []
    var emptyStateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        didClickcumpleButton("")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showNotifications()
    }
    
    func showNotifications() {
        if emptyStateLabel != nil {
            emptyStateLabel.removeFromSuperview()
            emptyStateLabel = nil
        }
        
        allNotifications = Constants.databaseManager.notificationsManager.getAllNotificationsFromDatabase()
        
        if allNotifications.count > 0 {
            filterNotifications()
            notificationsTableView.reloadData()
        } else {
            emptyStateLabel = CommonFunctions.createEmptyState(emptyText: "No hay notificaciones disponibles", parentView: self.view)
        }
    }
    
    func filterNotifications() {
        todayNotifications.removeAll()
        oldNotifications.removeAll()
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
        let storyBoard : UIStoryboard = UIStoryboard(name: "Notification", bundle:nil)
        let controller: NotificationDetailViewController = storyBoard.instantiateViewController(withIdentifier: "NotificationDetailViewController") as! NotificationDetailViewController
        controller.notification = getNotificationModelForIndexPath(indexPath: indexPath)
        self.navigationController!.pushViewController(controller, animated: true)
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
    }
    @IBAction func didClickCadenciaButton(_ sender: Any) {
        paintWholeButton(view: cadenciaView, label: cadenciaLabel)
        paintBorderButton(view: cumpleView, label: cumpleLabel)
        paintBorderButton(view: facturacionView, label: facturacionLabel)
        
    }
    @IBAction func didClickFacturacionButton(_ sender: Any) {
        paintWholeButton(view: facturacionView, label: facturacionLabel)
        paintBorderButton(view: cumpleView, label: cumpleLabel)
        paintBorderButton(view: cadenciaView, label: cadenciaLabel)
        
    }
}
