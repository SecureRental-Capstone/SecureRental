// swiftlint:disable all
import Amplify
import Foundation

extension RentalListing {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case title
    case description
    case price
    case images
    case location
    case isAvailable
    case datePosted
    case numberOfBedrooms
    case numberOfBathrooms
    case squareFootage
    case amenities
    case owner
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let rentalListing = RentalListing.keys
    
    model.authRules = [
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "RentalListings"
    model.syncPluralName = "RentalListings"
    
    model.attributes(
      .primaryKey(fields: [rentalListing.id])
    )
    
    model.fields(
      .field(rentalListing.id, is: .required, ofType: .string),
      .field(rentalListing.title, is: .required, ofType: .string),
      .field(rentalListing.description, is: .optional, ofType: .string),
      .field(rentalListing.price, is: .required, ofType: .string),
      .field(rentalListing.images, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(rentalListing.location, is: .required, ofType: .string),
      .field(rentalListing.isAvailable, is: .required, ofType: .bool),
      .field(rentalListing.datePosted, is: .required, ofType: .dateTime),
      .field(rentalListing.numberOfBedrooms, is: .required, ofType: .int),
      .field(rentalListing.numberOfBathrooms, is: .required, ofType: .int),
      .field(rentalListing.squareFootage, is: .required, ofType: .int),
      .field(rentalListing.amenities, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(rentalListing.owner, is: .optional, ofType: .string),
      .field(rentalListing.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(rentalListing.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension RentalListing: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}