<h1>Design Patterns in Swift: Builder</h1>
This repository is part of a series. For the full list check out <a href="https://shirazian.wordpress.com/2016/04/11/design-patterns-in-swift/">Design Patterns in Swift</a>

For a cheat-sheet of design patterns implemented in Swift check out <a href="https://github.com/ochococo/Design-Patterns-In-Swift"> Design Patterns implemented in Swift: A cheat-sheet</a>

<h3>The problem:</h3>
Our customers at <a href="http://www.yourmechanic.com">YourMechanic</a> request quotes through our website or through their YourMechanic App. A quote is a complicated object. It must have a car, at least one service, the customer's contact information, a mechanic capable of doing the services automatically picked by the system or selected by the user. A quote may or may not have a coupon code. We need a system that can build our quote and guarantee its validity. The system should be extendable and capable of dealing with changes to our quote creation process, ideally without having to change anything in the quote object itself.
<h3>The solution:</h3>
A quote is a composite of specific data from multiple different objects. Some these objects may not be all available at once, so we cannot have a valid quote object until all the needed data points are collected. Our first step is to figure out the data we need, then we will use a builder that will take these data points and builds the quote from the ground up. We are also going to task our builder with verifying the validity of our object, which can be as specific or as broad as we want. For our case, beside ensuring the presences of all the specific data required to create a quote, we are also going to ensure that our quote has a valid mechanic. This means we will check against the minimum required skill to complete a set of services against the mechanic selected by the user. If the mechanic cannot perform the jobs, the builder will complain that the quote object is invalid.

<!--more-->

Link to the repo for the completed project: <a href="https://github.com/kingreza/Swift-Builder">Swift - Builder</a>

Let's begin.

Before we get into building our builder we are going to quickly define our customer, mechanic and service objects. We will use these objects to build a mock data source for our builder.

```Swift
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

enum MechanicSkill: Int {
  case Junior = 1, Apprentice, Experienced, Master
}

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
```

First off we define a customer as an object that will have a name, address and email. We will set these properties through its initializer. Next we define an enumerable called MechanicSkill. This enumerable will be used to set the skill set of our mechanics and the minimum skill set required for completing a service. Next we define our Mechanic object. A mechanic will have a unique id, name, skill set of type MechanicSkill enumerable and an isBusy boolean flag. We set these values through the Mechanic initializers. We also conform to Hashable and Equatable which makes it possible to use our Mechanic object in a Set type(Will show how this becomes useful in a bit). Doing so means we have to define a hashValue and a == function for our mechanic. Since our mechanic id will be unique it can be our hashValue and we can assume when the two ids are equal we are dealing with the same mechanic.

Finally we define our service object. A service will have a unique name, minimumSkillRequired of type MechanicSkill enumerable and a price of type double. We set these values, and conform to the Hashable and Equatable protocol.

Next we are going to create a DataProvider class that will simulate our database. This class will have a set of mechanics and a set of services that we are going to use for our builder.

```Swift

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

```

We define our DataProvider class as a singleton (We got two design patterns for the price one!). A singleton ensures that there is only one instance of this class at all times. Since we want our data to be persistent throughout our project, a singleton works best for our mock database DataProvider class.

We define a static instance of the class DataProvider. We create two properties, a Set of type Mechanic and a Set of type Service. Using a Set ensures that we have unique values in our collection and since we do not care about the order of our objects, a Set becomes a natural choice. Since we defined our Service and Mechanic object as Equatable and Hashable creating a Set of them is as easy as:

```Swift
  var mechanics: Set<Mechanic>
  var services: Set<Service>
```

of course we will instantiate our sets in our initializers and fill them with data. Finally we add a few helper methods that will ease querying our DataSource. For this case, I already know what I need so I've defined them in advance. They simply call higher order functions against our set for finding mechanics and services based on their names. And in once case finding the first available mechanic for a specific service.

If you want to practice higher order functions or get a better understanding of closures I recommend extending these helper methods in DataProvider to return more interesting results. (Most expensive service, all our master mechanics, all replacement services, average cost of all our services, average skill set of our mechanics, a list of initials from our mechanic's names, setting all skill sets to a specific skill set on all services and etc...)

Anyways, let's get back to the task at hand. We now have our support objects defined and a mock DataProvider we can use to query for data. We can now build our builder. By looking at the requirements mentioned in the problem we can make a list of expected data our Quote needs. Lets see what those are.
<ul>
 	<li>We need a capable mechanic, either picked by the customer or selected by the system</li>
 	<li>We need at least one Service</li>
 	<li>We need a Customer</li>
 	<li>We need a Car</li>
 	<li>We may have a Coupon</li>
</ul>
Let's take these requirements and define a protocol for our Builder. This will ensure that whatever object that is our builder, will provide the functionality for our requirements.

```Swift
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
```

We define two functions for setting mechanics, one will be auto assigned and the other will be picked by the user and passed directly into our builder. We define two functions for adding and removing services from our collection services. We define a function for setting our customer which will simply take a customer object. We define a function for setting our car, which for sake of brevity is just a simple string for this project. We also define a methot to set our coupon if there is one. Finally we define two methods, one that will return our built quote and one which will let us know if our quote object is valid. A valid quote object is one that has all the needed information and those information are valid. In our case it means we know for a fact that the mechanic assigned to the quote will be able to do the jobs in it.

Let's build our builder.

```Swift
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
    if mechanic.skill.rawValue < highestSkillSetRequired?.rawValue { print("\(mechanic.name) cannot perform the services requested for this quote") return } possibleMechanic = mechanic } func addService(service: Service) { services.insert(service) } func removeService(service: Service) { services.remove(service) } func setCustomer(customer: Customer) { self.customer = customer } func setCar(car: String) { self.possibleCar = car } func setCoupon(coupon: String) { self.possibleCoupon = coupon } func result() -> Quote? {
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
```

That's a lot of code, let's break it down step by step.

```Swift
class QuoteBuilder: QuoteBuildable {

  private var possibleMechanic: Mechanic?
  private var services: Set<Service> = Set<Service>()
  private var customer: Customer?
  private var possibleCar: String?
  private var possibleCoupon: String?
```

We define QuoteBuilder as class that implements our protocol: QuoteBuildable. We define possibleMechanic as an optional mechanic type. We define a set of services, a customer, possible car and possible coupon. These properties are basically placeholders for the items we need to build our quote object.

```Swift
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
```

Next up we implement our setMechanic functions. These are the first two items we will implement to conform QuoteBuildable protocol. Our first setMechanic does not take in any input and assigns the first available mechanic with the skills required to perform the job for our services. This is done by using Swift's higher order function filter. If you haven't seen these before, I suggest you take a look at <a href="https://www.weheartswift.com/higher-order-functions-map-filter-reduce-and-more/">this document</a>, having a solid grasp on closures and higher order functions can save you ton of time necessary for loop implementations.

Our second setMechanic will simply take in a mechanic and if she is not busy and has the minimum skill set to do the services in our quote it will be assigned as a possible mechanic.

```Swift
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
```

Next up we implement our add/remove functions for adding or removing services from our set. We also implement setCar and setCoupon for setting their respective values. This stuff is fairly straightforward. It is worth noting that right now we have not built a quote yet. All we are doing are conforming to our QuoteBuildable protocol and ensuring that our implementation collects and saves the values needed in their intermediate placeholders.

```Swift
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
```

Next up we have our isValid property. Here we will check what is collected and verify we have what is needed to build a Quote object. We check if there is a mechanic picked for this quote. We check to see if the possible mechanic has the skill set to perform the jobs listed in the service set. We check and see if the service set has any services. We make sure a customer object has been set and finally we check to see if the user has given us a car, which for this example is a simple string. We do not check for a coupon since it is an optional item. If all those checks have been passed by the user, we return true to indicate that the quote is valid.

Note that not only do we check for the existences of all requirement information, but since the validity of the mechanic assigned is has also been defined as part of the builder's responsibility we also check to ensure that the possible mechanic set can actually do the services listed in our services set.

```Swift
  func result() -> Quote? {
    if isValid {
      print("***")
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
  
  private func clearBuilder() {
    possibleMechanic = nil
    services.removeAll()
    customer = nil
  }
```

finally we define our result function. This method is responsible for putting it all together. If our builder decides that our object is valid, it will use the information it has collected and create an instance of a quote object. Once the object is built, we clear our builder from all the information that we have collected and return our newly built quote object.

Our quote object can have its initializer take in all the parameters it needs to built itself because we know how builder has taken care of ensuring it has all the items it needs and that those items are valid. Notice that we pass a possibleCoupon to our quote. This item was not part of our requirements and is an optional property. Therefor it may very well be null. Here is our Quote object

```Swift
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
```

Notice that our Quote object does not need to worry itself with getting and setting its properties, especially if they don't normally change once the item is created. The quote object is also not concerned with the validity of its properties since they are already taken care of by the builder. Also note that the initializer and the initialization process for the Quote class is simple. Since we know that this item will be build through a builder, we don't have to worry about setting and getting various part of the quote.

Also we can rest be sure that all Quote objects will always have all their required properties set after they are built. All our Quote objects will be complete and valid. Lets run this through an example.

```Swift

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
```

Running the code above gives the following output

```
No mechanic is set
Quote is valid
***
Mike Fulton cannot perform the services requested for this quote
No mechanic is set
Steve Brimington cannot perform the services requested for this quote
No mechanic is set
Quote is valid
Selected mechanic cannot perform services
Quote is valid
***
Program ended with exit code: 0
```

We can see that when we initially create a QuoteBuilder and check its validity we get "No Mechanic is set". However when we assign our user, services, car and set our mechanic automatically through our setMechnanic function, our builder responds with Quote is valid and assigns the new quote through its result() function call.
We clear out our builder and begin to create a new quote. We set customer and the "Brake pad replacement" service. Next up we attempt to assign Mike Fulton to the job, however since he is only a junior mechanic and cannot perform a "Brake Pad Replacement" service, our builder informs us and keeps the mechanic unset. Same is true when we try to assign Steve Brimington, another junior mechanic. However once we let the system pick our mechanic, it assigns a valid mechanic, one that is capable of doing the job.

To make things interesting, we add a Timing Belt Replacement service which requires a master mechanic. Once we add that service, our model is invalid again since the mechanic assigned is no longer fit for the services in our set. We run setMechanic once more and the system updates our assigned mechanic. When we check and see that our model is valid, we call result on our quoteBuilder and retrieve our Quote object from our builder.

Congratulations you have just implemented the Builder Design Pattern to solve a nontrivial problem.

The repo for the complete project can be found here: <a href="https://github.com/kingreza/Swift-Builder">Swift - Builder.</a>

Download a copy of it and play around with it. See if you can find ways to improve its design, Add more complex functionalities. Here are some suggestions on how to expand or improve on the project:
<ul>
 	<li>Our quotes require a valid address, extend our builder to accommodate this new feature</li>
 	<li>When we get the builder to set a Mechanic, that mechanic might end up being unqualified if a job is added that is beyond his skill set. Have our builder run setMechanic() if the user has not set the mechanic themselves, if there is a change in minimum skills required.</li>
</ul>
