//
//  ViewController.swift
//  GestorHeme
//
//  Created by jon mikel on 31/03/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit
import MessageUI

class RootViewController: UITabBarController {
    @IBOutlet weak var rigthNavigationButton: UIBarButtonItem!
    @IBOutlet weak var secondRightNavigationButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Clientes"
        self.delegate = self
        Constants.rootController = self
        setNotificationBarItemBadge()
        CommonFunctions.checkBackupState()
    }
    
    func setNotificationBarItemBadge() {
        let notifications: [NotificationModel] =  Constants.databaseManager.notificationsManager.getAllNotificationsFromDatabase()
        var notificationesNoLeidas: Int = 0
        for notification in notifications {
            if !notification.leido {
                notificationesNoLeidas = notificationesNoLeidas + 1
            }
        }
        
        if notificationesNoLeidas > 0 {
            tabBar.items![2].badgeValue = String(notificationesNoLeidas)
        } else {
            tabBar.items![2].badgeValue = nil
        }
    }
    
    func openSettingsViewController() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Settings", bundle:nil)
        let controller: SettingsViewController = storyBoard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    func fillSecondRightNavigationButtonImage() {
        secondRightNavigationButton.image = UIImage(systemName: "person.fill")
    }
    
    func unfillSecondRightNavigationButtonImage() {
        secondRightNavigationButton.image = UIImage(systemName: "person")
    }

}


//Click actions
extension RootViewController {
    @IBAction func didClickRightNavigationButton(_ sender: Any) {
        if selectedIndex == 0 {//Clients tab
            performSegue(withIdentifier: "AddClientIdentifier", sender: nil)
        } else if selectedIndex == 3 {
            openSettingsViewController()
        } else if selectedIndex == 1 {
            let controller: AgendaViewController =  selectedViewController as! AgendaViewController
            controller.didClickCalendarButton()
        }
    }
    
    @IBAction func didClickSecondRightButton(_ sender: Any) {
        if selectedIndex == 1 {
            let controller: AgendaViewController =  selectedViewController as! AgendaViewController
            controller.didClickListarClientes()
        }
    }
}

extension RootViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        switch tabBarController.selectedIndex {
        case 0:
            title = "Clientes"
            rigthNavigationButton.image = UIImage(systemName: "plus")
            secondRightNavigationButton.image = UIImage(named: "")
        case 1:
            title = "Agenda"
            rigthNavigationButton.image = UIImage(systemName: "calendar")
            secondRightNavigationButton.image = UIImage(systemName: "person")
        case 2:
            title = "Notificaciones"
            rigthNavigationButton.image = UIImage(named: "")
            secondRightNavigationButton.image = UIImage(named: "")
        default:
            title = "Heme"
            rigthNavigationButton.image = UIImage(systemName: "wrench.fill")
            secondRightNavigationButton.image = UIImage(named: "")
        }
    }
}

extension RootViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
        if error == nil  && result == .sent {
            UserPreferences.saveValueInUserDefaults(value: Int64(Date().timeIntervalSince1970), key: Constants.backupKey)
        }
    }
}
