//
//  customer.swift
//  Mechanic - Builder
//
//  Created by Reza Shirazian on 2016-04-30.
//  Copyright © 2016 Reza Shirazian. All rights reserved.
//

import Foundation

struct Customer: Hashable, Equatable {
  var name: String
  var address: String
  var email: String

  init(name: String, address: String, email: String) {
    self.name = name
    self.address = address
    self.email = email
  }

  var hashValue: Int {
    return email.hashValue
  }
}

func == (lhs: Customer, rhs: Customer) -> Bool {
  return lhs.email == rhs.email
}
