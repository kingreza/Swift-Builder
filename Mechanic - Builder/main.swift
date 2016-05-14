//
//  main.swift
//  Mechanic - Builder
//
//  Created by Reza Shirazian on 2016-04-30.
//  Copyright © 2016 Reza Shirazian. All rights reserved.
//

import Foundation


var quoteBuilder = QuoteBuilder()

quoteBuilder.isValid

quoteBuilder.setCustomer(Customer(name: "Reza Shirazian",
                                  address: "N Rengstorff Ave Mountain View",
                                  email: "reza@example.com"))
quoteBuilder.addService(DataProvider.instance.getService("Brake Inspection")!)
quoteBuilder.addService(DataProvider.instance.getService("Battery Inspection")!)
quoteBuilder.addService(DataProvider.instance.getService("Oil Change")!)
quoteBuilder.setCar("Honda")
quoteBuilder.setMechanic()

var quote = quoteBuilder.result()

quoteBuilder.setCustomer(Customer(name: "Sarah Khosravani",
                                  address: "S Rengstorff Mountain View",
                                  email: "sarah@example.com"))

quoteBuilder.addService(DataProvider.instance.getService("Brake Pad Replacement")!)
quoteBuilder.setMechanic(DataProvider.instance.getMechanic("Mike Fulton")!)
quoteBuilder.isValid
quoteBuilder.setMechanic(DataProvider.instance.getMechanic("Steve Brimington")!)
quoteBuilder.isValid
quoteBuilder.setMechanic()
quoteBuilder.isValid
quoteBuilder.addService(DataProvider.instance.getService("Timing Belt Replacement")!)
quoteBuilder.isValid
quoteBuilder.setMechanic()

quote = quoteBuilder.result()
