//
//  SettingsViewController.swift
//  GestorHeme
//
//  Created by jon mikel on 09/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit
import LocalAuthentication

class HemeViewController: UIViewController {
    @IBOutlet weak var hemeTableView: UITableView!
    
    var hemeModels: [HemeModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        createObjectsForTableView()
        hemeTableView.reloadData()
    }
    
    func createObjectsForTableView() {
        hemeModels.removeAll()
        createCajaModel()
    }
    
    func createCajaModel() {
        let caja: HemeModel = HemeModel()
        caja.nombreImagen = "cash"
        caja.titulo = "CAJA"
        caja.descripcion = "Las estadististicas de los cierres de caja de la peluqueria Heme"
        hemeModels.append(caja)
    }
    
    func openStadisticasViewController() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "StadisticasCaja", bundle:nil)
        let controller: StadisticasCajaViewController = storyBoard.instantiateViewController(withIdentifier: "StadisticasCajaViewController") as! StadisticasCajaViewController
        controller.presentDate = Date()
        self.navigationController!.pushViewController(controller, animated: true)
    }
}

extension HemeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hemeModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HemeTableViewCell = tableView.dequeueReusableCell(withIdentifier: "HemeTableViewCell") as! HemeTableViewCell
        cell.setupCell(hemeModel: hemeModels[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            identifyUser()
        }
    }
}

extension HemeViewController {
    func identifyUser() {
        let context = LAContext()
        let reason = "Identificate para acceder a las estadisticas"
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in
            if success {
                DispatchQueue.main.async {
                    self.openStadisticasViewController()
                }
            } else {
                CommonFunctions.showGenericAlertMessage(mensaje: "Error autenticando usuario, no podrá acceder a las estadisticas sin autenticarte", viewController: self)
            }
        }
    }
}
