//
//  SettingsViewController.swift
//  GestorHeme
//
//  Created by jon mikel on 09/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit

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
        
        createStockModel()
        createFacturacionModel()
        createCajaModel()
    }
    
    func createStockModel() {
        let empleados: HemeModel = HemeModel()
        empleados.nombreImagen = "stock"
        empleados.titulo = "PRODUCTOS"
        hemeModels.append(empleados)
    }
    
    func createFacturacionModel() {
        let facturacion: HemeModel = HemeModel()
        facturacion.nombreImagen = "billing"
        facturacion.titulo = "FACTURACIÓN"
        hemeModels.append(facturacion)
    }
    
    func createCajaModel() {
        let caja: HemeModel = HemeModel()
        caja.nombreImagen = "cash"
        caja.titulo = "CAJA"
        hemeModels.append(caja)
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
        
    }
}
