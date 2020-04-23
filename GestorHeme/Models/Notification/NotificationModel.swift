//
//  NotificationModel.swift
//  GestorHeme
//
//  Created by jon mikel on 09/04/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import Foundation

class NotificationModel: NSObject {
    var clientId: [Int64] = []
    var notificationId: Int64 = 0
    var descripcion: String = ""
    var fecha: Int64 = 0
    var leido: Bool = false
    var type: String = ""
}
