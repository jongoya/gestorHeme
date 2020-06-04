//
//  EmpleadosViewController.swift
//  GestorHeme
//
//  Created by jon mikel on 12/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit

class EmpleadosViewController: UIViewController {
    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var empleados: [EmpleadoModel] = []
    var empleadosViews: [UIView] = []
    var showColorView: Bool = false
    var emptyStateLabel: UILabel!
    var scrollRefreshControl: UIRefreshControl = UIRefreshControl()
    var empleadoToDelete: EmpleadoModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Empleados"
        if !showColorView {
            addCreateEmpleadoButton()
        }
        
        addRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showEmpleados()
    }
    
    func showEmpleados() {
        empleados = CommonFunctions.getProfessionalList()
        
        removeScrollViewContent()
        
        if empleados.count > 0 {
            addEmpleadosViews()
            
            setConstraints()
        } else {
            emptyStateLabel = CommonFunctions.createEmptyState(emptyText: "No dispone de empleados", parentView: self.view)
        }
    }
    
    func addEmpleadosViews() {
        for empleado in empleados {
            addEmpleadoView(empleado: empleado)
        }
    }
    
    func addCreateEmpleadoButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .done, target: self, action: #selector(didClickCreateEmpleadoButton))
    }
    
    func addEmpleadoView(empleado: EmpleadoModel) {
        let empleadoView: EmpleadoView = EmpleadoView()
        empleadoView.translatesAutoresizingMaskIntoConstraints = false
        empleadoView.backgroundColor = .clear
        empleadoView.empleado = empleado
        addEmpleadoItemGestures(empleadoView: empleadoView)
        scrollContentView.addSubview(empleadoView)
        
        let crossView: UIView = UIView()
        crossView.translatesAutoresizingMaskIntoConstraints = false
        crossView.backgroundColor = .systemRed
        crossView.layer.cornerRadius = 10
        
        let tap = EmpleadoTapGesture(target: self, action: #selector(didClickCrossView(sender:)))
        tap.empleadoView = empleadoView
        crossView.addGestureRecognizer(tap)
        empleadoView.addSubview(crossView)
        
        let crossImageView: UIImageView = UIImageView()
        crossImageView.translatesAutoresizingMaskIntoConstraints = false
        crossImageView.image = UIImage.init(named: "cross")!.withRenderingMode(.alwaysTemplate)
        crossImageView.tintColor = .white
        crossView.addSubview(crossImageView)
        
        if showColorView {
            crossView.isHidden = true
            crossImageView.isHidden = true
        }
        
        let contentView: UIView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10
        empleadoView.addSubview(contentView)
        
        let imageView: UIImageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "empleado")
        contentView.addSubview(imageView)
        
        let nombreLabel: UILabel = UILabel()
        nombreLabel.translatesAutoresizingMaskIntoConstraints = false
        nombreLabel.text = empleado.nombre + " " + empleado.apellidos
        nombreLabel.textColor = .black
        nombreLabel.font = UIFont.systemFont(ofSize: 15)
        contentView.addSubview(nombreLabel)
        
        let colorView: UIView = UIView()
        colorView.translatesAutoresizingMaskIntoConstraints = false
        colorView.layer.cornerRadius = 15
        colorView.backgroundColor = UIColor(cgColor: CGColor(srgbRed: CGFloat(empleado.redColorValue), green: CGFloat(empleado.greenColorValue), blue: CGFloat(empleado.blueColorValue), alpha: 1.0))
        contentView.addSubview(colorView)
        
        if !showColorView {
            colorView.isHidden = true
        }
        
        empleadoView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        
        empleadoView.empleadoLeadingAnchor = contentView.leadingAnchor.constraint(equalTo: empleadoView.leadingAnchor, constant: 10)
        empleadoView.empleadoLeadingAnchor.isActive = true
        empleadoView.empleadoTrailingAnchor = contentView.trailingAnchor.constraint(equalTo: empleadoView.trailingAnchor, constant: -10)
        empleadoView.empleadoTrailingAnchor.isActive = true
        contentView.topAnchor.constraint(equalTo: empleadoView.topAnchor, constant: 5).isActive = true
        contentView.bottomAnchor.constraint(equalTo: empleadoView.bottomAnchor, constant: -5).isActive = true
        
        imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
        
        colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
        colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        colorView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        colorView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        nombreLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        nombreLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        nombreLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10).isActive = true
        nombreLabel.trailingAnchor.constraint(equalTo: colorView.isHidden ? contentView.trailingAnchor : colorView.leadingAnchor, constant: -10).isActive = true
        
        crossView.topAnchor.constraint(equalTo: empleadoView.topAnchor, constant: 5).isActive = true
        crossView.bottomAnchor.constraint(equalTo: empleadoView.bottomAnchor, constant: -5).isActive = true
        crossView.leadingAnchor.constraint(equalTo: empleadoView.leadingAnchor, constant: 10).isActive = true
        crossView.trailingAnchor.constraint(equalTo: empleadoView.trailingAnchor, constant: -10).isActive = true
        
        crossImageView.trailingAnchor.constraint(equalTo: crossView.trailingAnchor, constant: -20).isActive = true
        crossImageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        crossImageView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        crossImageView.centerYAnchor.constraint(equalTo: crossView.centerYAnchor).isActive = true
        
        empleadosViews.append(empleadoView)
    }
    
    func addEmpleadoItemGestures(empleadoView: EmpleadoView) {
        let tap = EmpleadoTapGesture(target: self, action: #selector(didClickEmpleadoView(sender:)))
        tap.empleadoView = empleadoView
        empleadoView.addGestureRecognizer(tap)
        if !showColorView {
            let swipeLeft = EmpleadoSwipeGesture(target: self, action: #selector(serviceSwipedLeft))
            swipeLeft.direction = .left
            swipeLeft.empleadoView = empleadoView
            empleadoView.addGestureRecognizer(swipeLeft)
            let swipeRight = EmpleadoSwipeGesture(target: self, action: #selector(serviceSwipedRight))
            swipeRight.direction = .right
            swipeRight.empleadoView = empleadoView
            empleadoView.addGestureRecognizer(swipeRight)
        }
    }
    
    func setConstraints() {
        var previousView: UIView!
        for empleadoView: UIView in empleadosViews {
            empleadoView.topAnchor.constraint(equalTo: previousView != nil ? previousView.bottomAnchor : scrollContentView.topAnchor, constant: 5).isActive = true
            
            empleadoView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor).isActive = true
            empleadoView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor).isActive = true
            
            previousView = empleadoView
        }
        
        if previousView != nil {
            previousView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor, constant: -5).isActive = true
        }
    }
    
    func removeScrollViewContent() {
        for view in scrollContentView.subviews {
            view.removeFromSuperview()
        }
        
        if emptyStateLabel != nil {
            emptyStateLabel.removeFromSuperview()
            emptyStateLabel = nil
        }
        
        empleadosViews.removeAll()
    }
    
    func leftAnimation(view: EmpleadoView) {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            view.empleadoLeadingAnchor.constant = -80
            view.empleadoTrailingAnchor.constant = -80
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func rightAnimation(view: EmpleadoView) {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            view.empleadoLeadingAnchor.constant = 10
            view.empleadoTrailingAnchor.constant = -10
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func addRefreshControl() {
        scrollRefreshControl.addTarget(self, action: #selector(refreshEmpleados), for: .valueChanged)
        scrollView.refreshControl = scrollRefreshControl
    }
    
    func updateServicios(servicios: [ServiceModel]) {
        let empleadoId: Int64 = Constants.databaseManager.empleadosManager.getAllEmpleadosFromDatabase().first!.empleadoId
        for service in servicios {
            service.profesional = empleadoId
        }
        
        Constants.cloudDatabaseManager.serviceManager.updateServices(services: servicios, delegate: self)
    }
}

extension EmpleadosViewController {
    @objc func didClickCreateEmpleadoButton(sender: UIBarButtonItem) {
        performSegue(withIdentifier: "AddEmpleadoIdentifier", sender: nil)
    }
    
    @objc func didClickEmpleadoView(sender: EmpleadoTapGesture) {
        let empleado: EmpleadoModel = sender.empleadoView.empleado
        if showColorView {
            performSegue(withIdentifier: "ColorPickerIdentifier", sender: empleado)
        } else {
            performSegue(withIdentifier: "AddEmpleadoIdentifier", sender: empleado)
        }
    }
    
    @objc func didClickCrossView(sender: EmpleadoTapGesture) {
        CommonFunctions.showLoadingStateView(descriptionText: "Eliminando empleado")
        let empleado: EmpleadoModel = sender.empleadoView.empleado

        Constants.cloudDatabaseManager.empleadoManager.deleteEmpleado(empleado: empleado, delegate: self)
    }
    
    @objc func serviceSwipedLeft(sender: EmpleadoSwipeGesture) {
        let empleadoView: EmpleadoView = sender.empleadoView
        leftAnimation(view: empleadoView)
    }
    
    @objc func serviceSwipedRight(sender: EmpleadoSwipeGesture) {
        let empleadoView: EmpleadoView = sender.empleadoView
        rightAnimation(view: empleadoView)
    }
    
    @objc func refreshEmpleados() {
        Constants.cloudDatabaseManager.empleadoManager.getEmpleados(delegate: self)
    }
}

extension EmpleadosViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ColorPickerIdentifier" {
            let controller: ColorPickerViewController = segue.destination as! ColorPickerViewController
            controller.empleado = (sender as! EmpleadoModel)
        } else if segue.identifier == "AddEmpleadoIdentifier" {
            let controller: AddEmpleadoViewController = segue.destination as! AddEmpleadoViewController
            if sender != nil {
                controller.empleado = (sender as! EmpleadoModel)
                controller.updateMode = true
            }
        }
    }
}

extension EmpleadosViewController: CloudEmpleadoProtocol {
    func empleadoSincronizationFinished() {
        print("EXITO CARGANDO EMPLEADOS")
        DispatchQueue.main.async {
            CommonFunctions.hideLoadingStateView()
            self.scrollRefreshControl.endRefreshing()
            self.showEmpleados()
        }
    }
    
    func empleadoSincronizationError(error: String) {
        print("ERROR CARGANDO EMPLEADOS")
        DispatchQueue.main.async {
            CommonFunctions.hideLoadingStateView()
            self.scrollRefreshControl.endRefreshing()
            CommonFunctions.showGenericAlertMessage(mensaje: "Error sincronizando empleados", viewController: self)
        }
    }
    
    func empleadoDeleted(empleado: EmpleadoModel) {
        let servicios: [ServiceModel] = Constants.databaseManager.servicesManager.getServicesForEmpleado(empleadoId: empleado.empleadoId)
        if servicios.count == 0 {
            print("EXITO ELIMINANDO EMPLEADO")
            if !Constants.databaseManager.empleadosManager.eliminarEmpleado(empleadoId: empleado.empleadoId) {
                DispatchQueue.main.async {
                    print("ERROR ELIMINANDO EMPLEADO")
                    CommonFunctions.hideLoadingStateView()
                    CommonFunctions.showGenericAlertMessage(mensaje: "Error eliminando empleado, inténtelo de nuevo", viewController: self)
                }
                return
            }
            
            DispatchQueue.main.async {
                CommonFunctions.hideLoadingStateView()
                self.showEmpleados()
            }
        } else {
            self.empleadoToDelete = empleado
            updateServicios(servicios: servicios)
        }
    }
}

class EmpleadoTapGesture: UITapGestureRecognizer {
    var empleadoView: EmpleadoView!
}

class EmpleadoSwipeGesture: UISwipeGestureRecognizer {
    var empleadoView: EmpleadoView!
}

class EmpleadoView: UIView {
    var empleadoLeadingAnchor: NSLayoutConstraint!
    var empleadoTrailingAnchor: NSLayoutConstraint!
    var empleado: EmpleadoModel!
}

extension EmpleadosViewController: CloudServiceManagerProtocol {
    func serviceSincronizationFinished() {
        print("EXITO ELIMINANDO EMPLEADO")
        if !Constants.databaseManager.empleadosManager.eliminarEmpleado(empleadoId: self.empleadoToDelete.empleadoId) {
            DispatchQueue.main.async {
                print("ERROR ELIMINANDO EMPLEADO")
                CommonFunctions.hideLoadingStateView()
                CommonFunctions.showGenericAlertMessage(mensaje: "Error eliminando empleado, inténtelo de nuevo", viewController: self)
            }
            return
        }
        
        let empleadoId: Int64 = Constants.databaseManager.empleadosManager.getAllEmpleadosFromDatabase().first!.empleadoId
        Constants.databaseManager.servicesManager.updateEmpleadoIdForServices(oldEmpleadoId: empleadoToDelete.empleadoId, newEmpleadoId: empleadoId)
        
        DispatchQueue.main.async {
            CommonFunctions.hideLoadingStateView()
            self.showEmpleados()
        }
    }
    
    func serviceSincronizationError(error: String) {
        print("ERROR ELIMINANDO EMPLEADO")
        DispatchQueue.main.async {
            CommonFunctions.hideLoadingStateView()
            CommonFunctions.showGenericAlertMessage(mensaje: error, viewController: self)
        }
    }
}

