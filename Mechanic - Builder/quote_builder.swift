//
//  quote_builder.swift
//  Mechanic - Builder
//
//  Created by Reza Shirazian on 2016-05-01.
//  Copyright © 2016 Reza Shirazian. All rights reserved.
//

import Foundation

class QuoteBuilder: QuoteBuildable {

  private var possibleMechanic: Mechanic?
  private var services: Set<Service> = Set<Service>()
  private var customer: Customer?
  private var possibleCar: String?
  private var possibleCoupon: String?

  func setMechanic() {
    if let highestSkillSetRequiredForServices = highestSkillSetRequired {
      if let mechanic = (DataProvider.instance.mechanics.filter {
                        !$0.isBusy &&
                        $0.skill.rawValue >= highestSkillSetRequiredForServices.rawValue}).first {
          self.possibleMechanic = mechanic
      }
    }
  }

  func setMechanic(mechanic: Mechanic) {
    if mechanic.isBusy {
      print("\(mechanic.name) is busy")
      return
    }
    if mechanic.skill.rawValue < highestSkillSetRequired?.rawValue {
       print("\(mechanic.name) cannot perform the services requested for this quote")
      return
    }

    possibleMechanic = mechanic
  }

  func addService(service: Service) {
    services.insert(service)
  }

  func removeService(service: Service) {
    services.remove(service)
  }

  func setCustomer(customer: Customer) {
    self.customer = customer
  }

  func setCar(car: String) {
    self.possibleCar = car

  }

  func setCoupon(coupon: String) {
    self.possibleCoupon = coupon

  }

  func result() -> Quote? {
    if isValid {
      possibleMechanic!.isBusy = true
      let quote = Quote(mechanic: possibleMechanic!,
                        services: Array(services),
                        customer: customer!,
                        car: possibleCar!,
                        coupon: possibleCoupon)
      clearBuilder()
      return quote
    } else {
      return nil
    }
  }

  var isValid: Bool {
    if possibleMechanic == nil {
        print("No mechanic is set")
        return false
    }

    if !possibleMechanicCanDoServices() {
      print("Selected mechanic cannot perform services")
      return false
    }
    if services.count == 0 {
      print("No service selected")
      return false
    }

    if customer == nil {
      print("No cutomer is set")
      return false
    }

    if possibleCar == nil {
      print("No car is set")
      return false
    }

    print("Quote is valid")
    return true

  }

  private func clearBuilder() {
    possibleMechanic = nil
    services.removeAll()
    customer = nil
  }
  private func possibleMechanicCanDoServices() -> Bool {
    if let possibleMechanic = possibleMechanic {
      return possibleMechanic.skill.rawValue >= highestSkillSetRequired?.rawValue
    }
    return false
  }

  private var highestSkillSetRequired: MechanicSkill? {
    get {
      return MechanicSkill(rawValue: services.reduce (0, combine: {max($0, $1.minimumSkillRequired.rawValue)}))
    }
  }

}
