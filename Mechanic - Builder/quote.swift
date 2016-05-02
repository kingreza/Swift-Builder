//
//  quote.swift
//  Mechanic - Builder
//
//  Created by Reza Shirazian on 2016-05-01.
//  Copyright © 2016 Reza Shirazian. All rights reserved.
//

import Foundation


struct Quote {

  var mechanic: Mechanic
  var services: [Service]
  var customer: Customer
  var car: String
  var coupon: String?

  init(mechanic: Mechanic, services: [Service], customer: Customer, car: String, coupon: String?) {
    self.mechanic = mechanic
    self.services = services
    self.customer = customer
    self.car = car
    self.coupon = coupon
  }

}
