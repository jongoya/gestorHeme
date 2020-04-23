//
//  StadisticaView.swift
//  GestorHeme
//
//  Created by jon mikel on 22/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit
import Charts

class StadisticaView: UIView {
    var titleLabel: UILabel!
    var lastValueLabel: UILabel!
    var chart: LineChartView!
    
    var title: String!
    var valores: [StadisticaModel] = []
    var isMensual: Bool!
    var isTotal: Bool!
    var delegate: StadisticaViewProtocol!

    init(title: String, valores: [StadisticaModel], isMensual: Bool, isTotal: Bool, delegate: StadisticaViewProtocol) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.title = title
        self.valores = valores.sorted(by: { $0.fecha < $1.fecha })
        self.isTotal = isTotal
        self.isMensual = isMensual
        self.delegate = delegate

        customizeView()
        addTapGesture()
        addTitleView()
        addLastValueView()
        addChart()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func customizeView() {
        layer.cornerRadius = 10
        backgroundColor = .white
    }
    
    func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(graphClicked(_:)))
        addGestureRecognizer(tap)
    }
    
    func addTitleView() {
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.textColor = .systemRed
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.numberOfLines = 1
        addSubview(titleLabel)
    }
    
    func addLastValueView() {
        let value: Double = valores.last?.valor ?? 0.0
        lastValueLabel = UILabel()
        lastValueLabel.translatesAutoresizingMaskIntoConstraints = false
        lastValueLabel.numberOfLines = 1
        if valores.count > 0 {
            lastValueLabel.text = title  == "Numero Servicios" ? String(Int(value)) : String(format:"%.2f", value) +  " €"
        } else {
            lastValueLabel.text = "No hay valores para este rango"
        }
        lastValueLabel.textColor = .black
        lastValueLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        lastValueLabel.numberOfLines = 1
        addSubview(lastValueLabel)
    }
    
    func addChart() {
        chart = LineChartView()
        chart.isUserInteractionEnabled = false
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.noDataText = "No hay valores para esta grafica"
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
        chart.data = lineChartData
        
        addSubview(chart)
    }
    
    func customizeChart() {
        chart.xAxis.labelPosition = .bottom
        chart.dragEnabled = false
        chart.setScaleEnabled(false)
        chart.pinchZoomEnabled = false
        chart.animate(xAxisDuration: 0.5, yAxisDuration: 0.5)
        chart.rightAxis.enabled = false
        chart.leftAxis.gridColor = .clear
        chart.leftAxis.valueFormatter = AxisFormatter(isAnual: !isMensual && !isTotal)
        chart.rightAxis.valueFormatter = AxisFormatter(isAnual: !isMensual && !isTotal)
        chart.xAxis.valueFormatter = AxisFormatter(isAnual: !isMensual && !isTotal)
        chart.xAxis.drawGridLinesEnabled = false
        chart.leftAxis.drawLabelsEnabled = false
        chart.extraLeftOffset = 20.0
        chart.extraRightOffset = 20.0
        chart.legend.enabled = false
        chart.xAxis.labelFont = .systemFont(ofSize: 12, weight: .semibold)
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
    
    func setConstraints() {
        heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        
        lastValueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5).isActive = true
        lastValueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        lastValueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        
        chart.topAnchor.constraint(equalTo: lastValueLabel.bottomAnchor, constant: 10).isActive = true
        chart.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        chart.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        chart.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
    }
}

extension StadisticaView {
    @objc func graphClicked(_ sender: UITapGestureRecognizer? = nil) {
        delegate.stadisticaClicked(title: title, valores: valores)
    }
}
