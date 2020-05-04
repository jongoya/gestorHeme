//
//  AgendaViewController.swift
//  GestorHeme
//
//  Created by jon mikel on 03/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit
import RMPickerViewController
import FSCalendar
import iCarousel

class AgendaViewController: UIViewController {
    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var filterProfessionalButton: UIButton!
    @IBOutlet weak var monthCalendar: FSCalendar!
    @IBOutlet weak var topMonthCalendarConstrain: NSLayoutConstraint!
    @IBOutlet weak var dayCarousel: iCarousel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var servicesViewArray: [UIView] = []
    var profesionalsArray: [EmpleadoModel] = []
    var presentDate: Date = Date()
    var initialDate: Date!
    var selectedProfesional: Int64 = 0
    var showingClientes: Bool = false
    let animationDuration: CGFloat = 0.5
    var calendarVisible: Bool = false
    var calendarHeigth: CGFloat = 400
    var daysInCarousel: [Date] = []
    var scrollRefreshControl: UIRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        setDayCarousel()
        customizeMonthCalendar()
        setProfesionalArray()
        customizeButtons()
        customizeCarousel()
        addRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !showingClientes {
            addAgenda(profesional: selectedProfesional)
        } else {
            Constants.rootController.fillSecondRightNavigationButtonImage()
            showClients()
        }
    }
    
    func setDayCarousel() {
        dayCarousel.isPagingEnabled = true
        daysInCarousel.removeAll()
        initialDate = Calendar.current.date(byAdding: .year, value: -2, to: presentDate)!
        let finalDate: Date = Calendar.current.date(byAdding: .year, value: 2, to: presentDate)!
        
        for index in 0...AgendaFunctions.getNumberOfDaysBetweenDates(date1: initialDate, date2: finalDate) {
            daysInCarousel.append(Calendar.current.date(byAdding: .day, value: index, to: initialDate)!)
        }
        
        dayCarousel.reloadData()
        
        dayCarousel.scrollToItem(at: AgendaFunctions.getNumberOfDaysBetweenDates(date1: initialDate, date2: presentDate) , animated: false)
    }
    
    func customizeMonthCalendar() {
        monthCalendar.locale = Locale(identifier: "es_ES")
    }
    
    func customizeCarousel() {
        dayCarousel.type = .rotary
    }
    
    func setProfesionalArray() {
        let empleado: EmpleadoModel = EmpleadoModel()
        empleado.nombre = "Todos"
        profesionalsArray.append(empleado)
        profesionalsArray.append(contentsOf: CommonFunctions.getProfessionalList())
    }
    
    func customizeButtons() {
        CommonFunctions.customizeButton(button: filterProfessionalButton)
    }
    
    func addAgenda(profesional: Int64) {
        Constants.rootController.unfillSecondRightNavigationButtonImage()
        showingClientes = false
        removeAgenda()
        
        addAgendaItems(profesional: profesional)
        
        setAgendaItemsConstraints()
    }
    
    func addAgendaItems(profesional: Int64) {
        var serviceDate: Date = AgendaFunctions.getBeginningOfDayFromDate(date: presentDate)
        
        for _ in 1...50 {
            let agendaItemView: AgendaItemView = AgendaItemView.init(date: serviceDate, profesional: profesional, delegate: self)
            scrollContentView.addSubview(agendaItemView)
            
            servicesViewArray.append(agendaItemView)
            
            serviceDate = AgendaFunctions.add15MinutesToDate(date: serviceDate)
        }
    }
    
    func setAgendaItemsConstraints() {
        var previousView: UIView!
        for agendaView in servicesViewArray {
            agendaView.topAnchor.constraint(equalTo: previousView != nil ? previousView.bottomAnchor : scrollContentView.topAnchor).isActive = true
            agendaView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor).isActive = true
            agendaView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor).isActive = true
            
            previousView = agendaView
        }
        
        if !Constants.databaseManager.cierreCajaManager.checkCierreCajaInDatabase(fecha: presentDate) {
            let button: UIButton =  createCierreCajaButton()
            scrollContentView.addSubview(button)
            servicesViewArray.append(button)
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            button.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 20).isActive = true
            button.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor).isActive = true
            button.widthAnchor.constraint(equalToConstant: 150).isActive = true
            previousView = button
        }
        
        scrollContentView.bottomAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 20).isActive = true
    }
    
    func removeAgenda() {
        for view: UIView in scrollContentView.subviews {
            view.removeFromSuperview()
        }
        
        servicesViewArray = []
    }
    
    func showProfessionalSelectorView() {
        let selectAction: RMAction<UIPickerView> = RMAction(title: "Seleccionar", style: .done) { (pickerView) in
            if self.calendarVisible {
                self.hideMonthCalendarView(withAnimationDuration: self.animationDuration)
                self.calendarVisible = !self.calendarVisible
            }
            
            let row: Int = pickerView.contentView.selectedRow(inComponent: 0)
            self.selectedProfesional = row == 0 ? 0 : self.profesionalsArray[row].empleadoId
            self.filterProfessionalButton.setTitle(self.profesionalsArray[row].nombre, for: .normal)
            self.filterProfessionalButton.setTitleColor(AgendaFunctions.getColorForProfesional(profesionalId: self.profesionalsArray[row].empleadoId), for: .normal)
            self.addAgenda(profesional: self.selectedProfesional)
        }!
        let cancelAction: RMAction<UIPickerView> = RMAction(title: "Cancelar", style: .cancel, andHandler: nil)!
        let controller: RMPickerViewController = RMPickerViewController(style: .white, select: selectAction, andCancel: cancelAction)!
        controller.picker.delegate = self
        controller.picker.dataSource = self
        present(controller, animated: true, completion: nil)
    }
    
    func showClients() {
        removeAgenda()
        var clientArray: [Int64] = []
        let services: [ServiceModel] = Constants.databaseManager.servicesManager.getServicesForDay(date: presentDate)
        for service in services {
            clientArray.append(service.clientId)
        }
        
        clientArray = Array(Set(clientArray))
        
        createClientsViewsForClients(clients: clientArray)
    }
    
    func createClientsViewsForClients(clients: [Int64]) {
        var previousView: UIView!
        
        for clientId in clients {
            let client: ClientModel? = Constants.databaseManager.clientsManager.getClientFromDatabase(clientId: clientId)
            
            if client == nil {
                continue
            }
            
            let clientView: AgendaClientItemView = AgendaClientItemView(cliente: client!, presentDate: presentDate, delegate: self)
            scrollContentView.addSubview(clientView)
            
            clientView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 15).isActive = true
            clientView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -15).isActive = true
            clientView.topAnchor.constraint(equalTo: previousView != nil ? previousView.bottomAnchor : scrollContentView.topAnchor, constant: 10).isActive = true
            clientView.heightAnchor.constraint(equalToConstant: 60).isActive = true
            
            previousView = clientView
        }
        
        if previousView != nil {
            scrollContentView.bottomAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 15).isActive = true
        }
    }
    
    func createCierreCajaButton() -> UIButton {
        let button: UIButton = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.setTitle("Cerrar Caja", for: .normal)
        button.setTitleColor(.black, for: .normal)
        CommonFunctions.customizeButton(button: button)
        button.addTarget(self, action: #selector(didClickCerrarCajaButton), for: .touchUpInside)
        return button
    }
    
    func addRefreshControl() {
        scrollRefreshControl.addTarget(self, action: #selector(refreshDay), for: .valueChanged)
        scrollView.refreshControl = scrollRefreshControl
    }
    
    func getCierreCajaNotification() -> NotificationModel? {
        let beginingOfDay: Date = AgendaFunctions.getBeginningOfDayFromDate(date: presentDate)
        let endOfDay: Date = AgendaFunctions.getEndOfDayFromDate(date: presentDate)
        let begininOfDayTimestamp: Int64 = Int64(beginingOfDay.timeIntervalSince1970)
        let endOfDayTimestamp: Int64 = Int64(endOfDay.timeIntervalSince1970)
        
        let notifications: [NotificationModel] = Constants.databaseManager.notificationsManager.getAllNotificationsForType(type: Constants.notificacionCajaCierreIdentifier)
        
        for notification in notifications {
            if notification.fecha > begininOfDayTimestamp && notification.fecha < endOfDayTimestamp {
                return notification
            }
        }
        
        return nil
    }
}

extension AgendaViewController {
    @IBAction func didClickProfessionalFilterButton(_ sender: Any) {
        showProfessionalSelectorView()
    }
    
    func didClickCalendarButton() {
        if calendarVisible {
            hideMonthCalendarView(withAnimationDuration: animationDuration)
        } else {
            showMonthCalendarView()
        }
        
        calendarVisible = !calendarVisible
    }
    
    func didClickListarClientes() {
        if calendarVisible {
            hideMonthCalendarView(withAnimationDuration: animationDuration)
            calendarVisible = !calendarVisible
        }
        
        if showingClientes {
            Constants.rootController.unfillSecondRightNavigationButtonImage()
            showingClientes = false
            addAgenda(profesional: selectedProfesional)
        } else {
            Constants.rootController.fillSecondRightNavigationButtonImage()
            showingClientes = true
            removeAgenda()
            showClients()
        }
    }
    
    @objc func refreshDay() {
        Constants.cloudDatabaseManager.serviceManager.getServiciosPorDia(date: presentDate, delegate: self)
    }
    
    @objc func didClickCerrarCajaButton() {
        performSegue(withIdentifier: "cierreCajaIdentifier", sender: nil)
    }
}

extension AgendaViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return profesionalsArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return profesionalsArray[row].nombre
    }
}

extension AgendaViewController: AgendaItemViewProtocol {
    func crossButtonClicked(service: ServiceModel) {
        CommonFunctions.showLoadingStateView(descriptionText: "Eliminando servicio")
        Constants.cloudDatabaseManager.serviceManager.deleteService(service: service, delegate: self)
    }
    
    func dayClicked(date: Date) {
        performSegue(withIdentifier: "AgendaServiceIdentifier", sender: date)
    }
    
    func serviceClicked(service: ServiceModel) {
        performSegue(withIdentifier: "ServiceDetailIdentifier", sender: service)
    }
}

extension AgendaViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ServiceDetailIdentifier" {
            openServiceDetail(sender: sender, segue: segue)
        } else if segue.identifier == "ClientDetailIdentifier" {
            let controller: ClientDetailViewController = segue.destination as! ClientDetailViewController
            controller.client = (sender as! ClientModel)
        } else if segue.identifier == "AgendaServiceIdentifier" {
            let controller: AgendaServiceViewController = segue.destination as! AgendaServiceViewController
            controller.newDate = (sender as! Date)
            controller.delegate = self
        } else if segue.identifier == "cierreCajaIdentifier" {
            let controller: CierreCajaViewController = segue.destination as! CierreCajaViewController
            controller.presentDate = presentDate
            controller.notification = getCierreCajaNotification()
        }
    }
    
    func openServiceDetail(sender: Any?, segue: UIStoryboardSegue) {
        let service: ServiceModel = sender as! ServiceModel
        let controller: AddServicioViewController = segue.destination as! AddServicioViewController
        let client: ClientModel? = Constants.databaseManager.clientsManager.getClientFromDatabase(clientId: service.clientId)
        if client == nil {
            CommonFunctions.showGenericAlertMessage(mensaje: "Error mostrando el detalle servicio", viewController: self)
            return
        }
        
        controller.client = client
        controller.modifyService = true
        controller.service = service
        controller.delegate = self
    }
}

extension AgendaViewController: AddServicioProtocol {
    func serviceContentFilled(service: ServiceModel, serviceUpdated: Bool) {
        //no es necesario implementar
    }
}

extension AgendaViewController: ClientItemViewProtocol {
    func clientClicked(client: ClientModel) {
        performSegue(withIdentifier: "ClientDetailIdentifier", sender: client)
    }
}

extension AgendaViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        presentDate = date
        calendarVisible = false
        hideMonthCalendarView(withAnimationDuration: animationDuration)
        setDayCarousel()
        addAgenda(profesional: selectedProfesional)
    }
    
    func hideMonthCalendarView(withAnimationDuration: CGFloat) {
        UIView.animate(withDuration: TimeInterval(withAnimationDuration), delay: 0, options: .curveEaseOut, animations: {
            self.topMonthCalendarConstrain.constant = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func showMonthCalendarView() {
        UIView.animate(withDuration: TimeInterval(animationDuration), delay: 0, options: .curveEaseOut, animations: {
            self.topMonthCalendarConstrain.constant = self.calendarHeigth
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

extension AgendaViewController: iCarouselDataSource, iCarouselDelegate {
    func numberOfItems(in carousel: iCarousel) -> Int {
        return daysInCarousel.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let view: CarouselItem = CarouselItem(frame: CGRect(x: 0, y: 0, width: 80, height: 70), date: daysInCarousel[index])
        if index == carousel.currentItemIndex {
            view.highlightView()
        } else {
            view.unhightlightView()
        }
        
        return view
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        let oldItem: CarouselItem = carousel.itemView(at: carousel.currentItemIndex) as! CarouselItem
        let item: CarouselItem = carousel.itemView(at: index) as! CarouselItem
        item.highlightView()
        oldItem.unhightlightView()
        presentDate = item.date
        calendarVisible = false
        hideMonthCalendarView(withAnimationDuration: animationDuration)
        addAgenda(profesional: selectedProfesional)
    }
    
    func carouselDidEndDecelerating(_ carousel: iCarousel) {
        let item: CarouselItem = carousel.currentItemView as! CarouselItem
        item.highlightView()
        presentDate = item.date
        calendarVisible = false
        hideMonthCalendarView(withAnimationDuration: animationDuration)
        addAgenda(profesional: selectedProfesional)
    }
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        //TODO mirar si es necesario
    }
    
    func carouselWillBeginDragging(_ carousel: iCarousel) {
        let oldItem: CarouselItem = carousel.itemView(at: carousel.currentItemIndex) as! CarouselItem
        oldItem.unhightlightView()
    }
}


extension AgendaViewController: CloudServiceManagerProtocol {
    func serviceSincronizationFinished() {
        DispatchQueue.main.async {
            self.scrollRefreshControl.endRefreshing()
            if !self.showingClientes {
                Constants.rootController.unfillSecondRightNavigationButtonImage()
                self.addAgenda(profesional: self.selectedProfesional)
            } else {
                Constants.rootController.fillSecondRightNavigationButtonImage()
                self.showClients()
            }
        }
    }
    func serviceSincronizationError(error: String) {
        DispatchQueue.main.async {
            self.scrollRefreshControl.endRefreshing()
            CommonFunctions.showGenericAlertMessage(mensaje: "Error recogiendo servicios", viewController: self)
        }
    }
}

extension AgendaViewController: AgendaServiceProtocol {
    func serviceAdded() {
        let item: CarouselItem = dayCarousel.currentItemView! as! CarouselItem
        item.checkCitasPoint()
    }
}

extension AgendaViewController: CloudEliminarServiceProtocol {
    func serviceEliminado(service: ServiceModel) {
        if !Constants.databaseManager.servicesManager.deleteService(service: service) {
            DispatchQueue.main.async {
                CommonFunctions.hideLoadingStateView()
                CommonFunctions.showGenericAlertMessage(mensaje: "Error eliminando servicio, intentelo de nuevo", viewController: self)
            }
            return
        }
        
        DispatchQueue.main.async {
            CommonFunctions.hideLoadingStateView()
            self.addAgenda(profesional: self.selectedProfesional)
            
            let item: CarouselItem = self.dayCarousel.currentItemView! as! CarouselItem
            item.checkCitasPoint()
        }
    }
    
    func errorEliminandoService(error: String) {
        DispatchQueue.main.async {
            CommonFunctions.hideLoadingStateView()
            CommonFunctions.showGenericAlertMessage(mensaje: error, viewController: self)
        }
    }
}

extension AgendaViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollContentView
    }
}
