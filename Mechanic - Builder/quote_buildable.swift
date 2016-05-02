//
//  quote_buildable.swift
//  Mechanic - Builder
//
//  Created by Reza Shirazian on 2016-05-01.
//  Copyright © 2016 Reza Shirazian. All rights reserved.
//

import Foundation

protocol QuoteBuildable {

  func setMechanic()

  func setMechanic(mechanic: Mechanic)

  func addService(service: Service)

  func removeService(service: Service)

  func setCustomer(customer: Customer)

  func setCar(car: String)

  func setCoupon(coupon: String)

  func result() -> Quote?

  var isValid: Bool {get}

}
