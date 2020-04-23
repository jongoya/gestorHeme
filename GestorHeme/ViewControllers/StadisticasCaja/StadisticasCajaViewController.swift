//
//  StadisticasCajaViewController.swift
//  GestorHeme
//
//  Created by jon mikel on 21/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit

class StadisticasCajaViewController: UIViewController {
    @IBOutlet weak var filtroButton: UIView!
    @IBOutlet weak var filtroLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var actionSheetView: UIView!
    @IBOutlet weak var alphaView: UIView!
    @IBOutlet weak var actionView: UIView!
    @IBOutlet weak var fechasPickerView: UIPickerView!
    @IBOutlet weak var actionSheetViewBottomAnchor: NSLayoutConstraint!
    @IBOutlet weak var actionSheetViewTopAnchor: NSLayoutConstraint!
    
    var chartViews: [UIView] = []
    var cierreCajas: [CierreCajaModel] = []
    let meses: [String] = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
    var años: [Int] = []
    var isMensual: Bool = true
    var monthSelected: Int = 0
    var yearSelected: Int = 0
    var presentDate: Date!
    var isTotal: Bool = false
    let scrollViewTopOfset: CGFloat = 70
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        monthSelected = AgendaFunctions.getMonthNumberFromDate(date: Date())
        yearSelected = AgendaFunctions.getYearNumberFromDate(date: Date())
        title = "Estadisticas"
        
        customizeFilterButton()
        customizeActionSheet()
        setYearArray()
        setPickerView()
        hideActionSheetView(duration: 0)
        addTapGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addCharts()
    }
    
    func customizeFilterButton() {
        CommonFunctions.customizeButton(button: filtroButton)
    }
    
    func customizeActionSheet() {
        actionView.layer.cornerRadius = 10
    }
    
    func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(actionSheetTap(_:)))
        alphaView.addGestureRecognizer(tap)
    }
    
    func setPickerView() {
        fechasPickerView.delegate = self
        fechasPickerView.dataSource = self
    }
    
    func setFechaInPicker() {
        if isMensual {
            fechasPickerView.selectRow(monthSelected - 1, inComponent: 0, animated: false)
            fechasPickerView.selectRow(yearSelected - años.first!, inComponent: 1, animated: false)
        }

        fechasPickerView.selectRow(yearSelected - años.first!, inComponent: 0, animated: false)
    }
    
    func setFechaLabel() {
        if isTotal {
            filtroLabel.text = "Total"
            return
        }
        
        if isMensual {
            filtroLabel.text = CommonFunctions.getMonthFromDate(date: presentDate).capitalized
            return
        }
        
        filtroLabel.text = CommonFunctions.getYearFromDate(date: presentDate)
    }
    
    func setYearArray() {
        let actualYear: Int = Calendar.current.component(.year, from: Date())
        
        for index in (actualYear - 50)...(actualYear + 50) {
            años.append(index)
        }
    }
    
    func addCharts() {
        removesScrollViewSubViews()
        setFechaLabel()
        cierreCajas = Constants.databaseManager.cierreCajaManager.getAllCierreCajasForEstadisticas(date: presentDate, isMonth: isMensual, isTotal: isTotal)
        
        if !isMensual  && !isTotal {
            cierreCajas = StadisticasFunctions.getCierreCajasAnual(cierres: cierreCajas)
        }
        
        if isTotal {
            cierreCajas = StadisticasFunctions.getCierreCajasTotal(cierres: cierreCajas)
        }
        
        addNumeroServiciosChart()
        addTotalCajaChart()
        addTotalProductosChart()
        addEfectivoChart()
        addTarjetaChart()
        
        setScrollContentConstraints()
    }
    
    func removesScrollViewSubViews() {
        for view in scrollContentView.subviews {
            view.removeFromSuperview()
        }
        
        chartViews.removeAll()
    }
    
    func addNumeroServiciosChart() {
        var numeroServiciosValues: [StadisticaModel] = []
        
        for cierreCaja: CierreCajaModel in cierreCajas {
            numeroServiciosValues.append(StadisticaModel(fecha: cierreCaja.fecha, valor: Double(cierreCaja.numeroServicios)))
        }
        
        let numeroServiciosChart: StadisticaView = StadisticaView(title: "Numero Servicios", valores: numeroServiciosValues, isMensual: isMensual, isTotal: isTotal, delegate: self)
        scrollContentView.addSubview(numeroServiciosChart)
        chartViews.append(numeroServiciosChart)
    }
    
    func addTotalCajaChart() {
        var totalCajaValues: [StadisticaModel] = []
        
        for cierreCaja: CierreCajaModel in cierreCajas {
            totalCajaValues.append(StadisticaModel(fecha: cierreCaja.fecha, valor: cierreCaja.totalCaja))
        }
        
        let totalCajaChart: StadisticaView = StadisticaView(title: "Total Caja", valores: totalCajaValues, isMensual: isMensual, isTotal: isTotal, delegate: self)
        scrollContentView.addSubview(totalCajaChart)
        chartViews.append(totalCajaChart)
    }
    
    func addTotalProductosChart() {
        var totalProductosValues: [StadisticaModel] = []
        
        for cierreCaja: CierreCajaModel in cierreCajas {
            totalProductosValues.append(StadisticaModel(fecha: cierreCaja.fecha, valor: cierreCaja.totalProductos))
        }
        
        let totalProductosChart: StadisticaView = StadisticaView(title: "Total Productos", valores: totalProductosValues, isMensual: isMensual, isTotal: isTotal, delegate: self)
        scrollContentView.addSubview(totalProductosChart)
        chartViews.append(totalProductosChart)
    }
    
    func addEfectivoChart() {
        var totalEfectivoValues: [StadisticaModel] = []
        
        for cierreCaja: CierreCajaModel in cierreCajas {
            totalEfectivoValues.append(StadisticaModel(fecha: cierreCaja.fecha, valor: cierreCaja.efectivo))
        }
        
        let totalProductosChart: StadisticaView = StadisticaView(title: "Efectivo", valores: totalEfectivoValues, isMensual: isMensual, isTotal: isTotal, delegate: self)
        scrollContentView.addSubview(totalProductosChart)
        chartViews.append(totalProductosChart)
    }
    
    func addTarjetaChart() {
        var totalTarjetaValues: [StadisticaModel] = []
        
        for cierreCaja: CierreCajaModel in cierreCajas {
            totalTarjetaValues.append(StadisticaModel(fecha: cierreCaja.fecha, valor: cierreCaja.tarjeta))
        }
        
        let totalTarjetaChart: StadisticaView = StadisticaView(title: "Tarjeta", valores: totalTarjetaValues, isMensual: isMensual, isTotal: isTotal, delegate: self)
        scrollContentView.addSubview(totalTarjetaChart)
        chartViews.append(totalTarjetaChart)
    }
    
    func setScrollContentConstraints() {
        var previousView: UIView!
        for view: UIView in chartViews {
            view.topAnchor.constraint(equalTo: previousView != nil ? previousView.bottomAnchor : scrollContentView.topAnchor, constant: previousView != nil ? 10 : scrollViewTopOfset).isActive = true
            view.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 10).isActive = true
            view.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -10).isActive = true
            
            previousView = view
        }
        
        previousView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor, constant: -10).isActive = true
    }
    
    func showActionSheetView() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.actionSheetViewBottomAnchor.constant = 0
            self.actionSheetViewTopAnchor.constant = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        UIView.animate(withDuration: 0.3, delay: 0.3, options: [.curveEaseInOut], animations: {
            self.alphaView.alpha = 0.5
        }, completion: nil)
    }
    
    func hideActionSheetView(duration: Double) {
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.actionSheetViewBottomAnchor.constant = UIScreen.main.bounds.size.height
            self.actionSheetViewTopAnchor.constant = UIScreen.main.bounds.size.height
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.alphaView.alpha = 0
        }, completion: nil)
    }
    
    func createDate(month: Int, year: Int) {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = 10
        dateComponents.timeZone = TimeZone(abbreviation: "CEST")
        dateComponents.hour = 10
        dateComponents.minute = 10

        let userCalendar = Calendar.current
        presentDate = userCalendar.date(from: dateComponents)
    }
}

extension StadisticasCajaViewController {
    @IBAction func didClickFechaSelector(_ sender: Any) {
        isTotal = false
        setFechaInPicker()
        showActionSheetView()
    }
    
    @IBAction func didClickTotalButton(_ sender: Any) {
        hideActionSheetView(duration: 0.5)
        isTotal = true
        addCharts()
    }
    
    @IBAction func didClickMensualButton(_ sender: Any) {
        isMensual = true
        isTotal = false
        fechasPickerView.reloadAllComponents()
        setFechaInPicker()
    }
    
    @IBAction func didClickAnualButton(_ sender: Any) {
        isMensual = false
        isTotal = false
        fechasPickerView.reloadAllComponents()
        setFechaInPicker()
    }
    
    @IBAction func didClickCancelarButton(_ sender: Any) {
        hideActionSheetView(duration: 0.5)
    }
    
    @IBAction func didClickAceptarButton(_ sender: Any) {
        hideActionSheetView(duration: 0.5)
        createDate(month: monthSelected, year: yearSelected)
        addCharts()
    }
    
    @objc func actionSheetTap(_ sender: UITapGestureRecognizer? = nil) {
        hideActionSheetView(duration: 0.5)
    }
}

extension StadisticasCajaViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if isMensual {
            return 2
        }
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 && isMensual {
            return meses.count
        }
        
        return años.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 && isMensual {
            return meses[row]
        }
        
        return String(años[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 && isMensual {
            monthSelected = row + 1
        } else {
            yearSelected = años[row]
        }
    }
}

extension StadisticasCajaViewController: StadisticaViewProtocol {
    func stadisticaClicked(title: String, valores: [StadisticaModel]) {
        performSegue(withIdentifier: "StadisiticaDetailIdentifier", sender: ["title" : title, "valores" : valores])
    }
}

extension StadisticasCajaViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "StadisiticaDetailIdentifier" {
            let dict: [String: Any] = sender as! [String: Any]
            let controller: StadisticaDetailViewController = segue.destination as! StadisticaDetailViewController
            controller.stadisticaTitle = dict["title"] as? String
            controller.valores = dict["valores"] as? [StadisticaModel]
            controller.isMensual = isMensual
            controller.isTotal = isTotal
        }
    }
}
