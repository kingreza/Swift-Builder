//
//  customer.swift
//  Mechanic - Builder
//
//  Created by Reza Shirazian on 2016-04-30.
//  Copyright © 2016 Reza Shirazian. All rights reserved.
//

import Foundation

struct Customer {
  var name: String
  var address: String
  var email: String

  init(name: String, address: String, email: String) {
    self.name = name
    self.address = address
    self.email = email
  }
}
