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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Estadisticas"
        
        customizeFilterButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func customizeFilterButton() {
        CommonFunctions.customizeButton(button: filtroButton)
    }

}
