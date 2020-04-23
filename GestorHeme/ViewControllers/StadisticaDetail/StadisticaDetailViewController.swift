//
//  StadisticaDetailViewController.swift
//  GestorHeme
//
//  Created by jon mikel on 23/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit
import Charts

class StadisticaDetailViewController: UIViewController {
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var stadisticaTitleLabel: UILabel!
    @IBOutlet weak var chartTableView: UITableView!
    
    var valores: [StadisticaModel]!
    var stadisticaTitle: String!
    var isMensual: Bool!
    var isTotal: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Detalle"
        
        stadisticaTitleLabel.text = stadisticaTitle
        
        addChart()
    }
    
    func addChart() {
        lineChartView.noDataText = "No hay valores para esta grafica"
        customizeChart()
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<valores.count {
            let date: Date = Date(timeIntervalSince1970: TimeInterval(valores[i].fecha))
            var xValue: Double = Double(Calendar.current.component(.day, from: date))
            if !isMensual && !isTotal {
                xValue = Double(AgendaFunctions.getMonthNumberFromDate(date: date))
            }
            
            if isTotal {
                xValue = Double(AgendaFunctions.getYearNumberFromDate(date: date))
            }
            
            let dataEntry = BarChartDataEntry(x: xValue, y: valores[i].valor)
            dataEntries.append(dataEntry)
        }
        
        let lineChartData = LineChartData(dataSet: createDataSet(dataEntries: dataEntries))
        lineChartView.data = lineChartData
    }
    
    func customizeChart() {
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.dragEnabled = false
        lineChartView.setScaleEnabled(false)
        lineChartView.pinchZoomEnabled = false
        lineChartView.animate(xAxisDuration: 0.5, yAxisDuration: 0.5)
        lineChartView.rightAxis.enabled = false
        lineChartView.leftAxis.gridColor = .clear
        lineChartView.leftAxis.valueFormatter = AxisFormatter(isAnual: !isMensual && !isTotal)
        lineChartView.rightAxis.valueFormatter = AxisFormatter(isAnual: !isMensual && !isTotal)
        lineChartView.xAxis.valueFormatter = AxisFormatter(isAnual: !isMensual && !isTotal)
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.drawLabelsEnabled = false
        lineChartView.extraLeftOffset = 20.0
        lineChartView.extraRightOffset = 20.0
        lineChartView.legend.enabled = false
        lineChartView.xAxis.labelFont = .systemFont(ofSize: 12, weight: .semibold)
    }
    
    func createDataSet(dataEntries: [BarChartDataEntry]) -> LineChartDataSet {
        let lineChartDataSet = LineChartDataSet(entries: dataEntries, label: title)
        lineChartDataSet.setColor(.systemRed)
        lineChartDataSet.lineWidth = 2
        lineChartDataSet.setCircleColor(.red)
        lineChartDataSet.circleRadius = 6
        lineChartDataSet.circleHoleColor = .systemRed
        lineChartDataSet.mode = .cubicBezier
        lineChartDataSet.valueFont = .systemFont(ofSize: 10, weight: .semibold)
        lineChartDataSet.highlightColor = .systemRed
        lineChartDataSet.highlightEnabled = false
        
        return lineChartDataSet
    }
}

extension StadisticaDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return valores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: StadisticaDetailCell = tableView.dequeueReusableCell(withIdentifier: "StadisticaDetailCell") as! StadisticaDetailCell
        cell.setupCell(stadisticaModel: valores[indexPath.row], isNumeroServicios: stadisticaTitle == "Numero Servicios", isMensual: isMensual, isTotal: isTotal)
        cell.selectionStyle = .none
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
