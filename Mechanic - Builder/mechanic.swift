//
//  mechanic.swift
//  Mechanic - Builder
//
//  Created by Reza Shirazian on 2016-04-30.
//  Copyright © 2016 Reza Shirazian. All rights reserved.
//

import Foundation

struct Mechanic: Hashable, Equatable {
  static var id: Int = 0
  var id: Int
  var name: String
  var skill: MechanicSkill
  var isBusy: Bool

  init(name: String, skill: MechanicSkill) {
    self.name = name
    self.skill = skill
    self.isBusy = false
    Mechanic.id += 1
    self.id = Mechanic.id
  }

  var hashValue: Int {
    return id
  }
}

func == (lhs: Mechanic, rhs: Mechanic) -> Bool {
  return lhs.id == rhs.id
}
