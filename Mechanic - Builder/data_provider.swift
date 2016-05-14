//
//  data_provider.swift
//  Mechanic - Builder
//
//  Created by Reza Shirazian on 2016-04-30.
//  Copyright © 2016 Reza Shirazian. All rights reserved.
//

import Foundation


class DataProvider {

  static let instance = DataProvider()

  var mechanics: Set<Mechanic>
  var services: Set<Service>


  private init() {
    mechanics = Set<Mechanic>()
    services = Set<Service>()
    initData()
  }

  private func initData() {
    initMechanic()
    initServices()


  }

  private func initMechanic() {
    mechanics.insert(Mechanic(name: "Steve Brimington", skill: .Junior))
    mechanics.insert(Mechanic(name: "Mike Fulton", skill: .Junior))
    mechanics.insert(Mechanic(name: "Ali Bellevue", skill: .Junior))
    mechanics.insert(Mechanic(name: "Dick Duchess", skill: .Apprentice))
    mechanics.insert(Mechanic(name: "Shane Inglewood", skill: .Apprentice))
    mechanics.insert(Mechanic(name: "Trevor Matters", skill: .Apprentice))
    mechanics.insert(Mechanic(name: "Moris King", skill: .Experienced))
    mechanics.insert(Mechanic(name: "Nick Main", skill: .Experienced))
    mechanics.insert(Mechanic(name: "Zane Marine", skill: .Master))
  }

  private func initServices() {

    services.insert(Service(name: "Brake Inspection",
      minimumSkillRequired: .Junior,
      price: 15.00))
    services.insert(Service(name: "Battery Inspection",
      minimumSkillRequired: .Junior,
      price: 17.00))
    services.insert(Service(name: "Oil Change",
      minimumSkillRequired: .Junior,
      price: 35.00))
    services.insert(Service(name: "Door Latch Replacement",
      minimumSkillRequired: .Junior,
      price: 33.00))
    services.insert(Service(name: "Lubricate Trunk",
      minimumSkillRequired: .Junior,
      price: 19.00))
    services.insert(Service(name: "Air Filter Replacement",
      minimumSkillRequired: .Junior,
      price: 39.00))
    services.insert(Service(name: "Brake Motor Replacement",
      minimumSkillRequired: .Apprentice,
      price: 115.00))
    services.insert(Service(name: "Brake Pad Replacement",
      minimumSkillRequired: .Apprentice,
      price: 89.00))
    services.insert(Service(name: "Battery Replacement",
      minimumSkillRequired: .Apprentice,
      price: 110.00))
    services.insert(Service(name: "Timing Belt Replacement",
      minimumSkillRequired: .Master,
      price: 250.00))
    services.insert(Service(name: "Power Steering Replacement",
      minimumSkillRequired: .Master,
      price: 270.00))

  }

  func getMechanic(name: String) -> Mechanic? {
    return (mechanics.filter {$0.name == name}).first
  }

  func getMechanicForService(service: Service) -> Mechanic? {

    return (mechanics.filter {$0.skill.rawValue > service.minimumSkillRequired.rawValue &&
                              $0.isBusy == false}).first
  }

  func getService(name: String) -> Service? {

    return (services.filter {$0.name == name}).first
  }

}
