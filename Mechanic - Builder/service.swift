//
//  service.swift
//  Mechanic - Builder
//
//  Created by Reza Shirazian on 2016-04-30.
//  Copyright © 2016 Reza Shirazian. All rights reserved.
//

import Foundation


struct Service: Hashable, Equatable {

  var name: String
  var minimumSkillRequired: MechanicSkill
  var price: Double

  init(name: String, minimumSkillRequired: MechanicSkill, price: Double) {
    self.name = name
    self.minimumSkillRequired = minimumSkillRequired
    self.price = price
  }

  var hashValue: Int {
    return name.hashValue
  }

}

func == (lhs: Service, rhs: Service) -> Bool {
  return lhs.hashValue == rhs.hashValue
}
