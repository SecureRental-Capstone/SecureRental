// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "bbcccc96d77d15eddc4d44a735aa87ff"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: RentalListing.self)
  }
}