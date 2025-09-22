// swiftlint:disable all
import Amplify
import Foundation
import UIKit

public struct RentalListing: Model {
  public let id: String
  public var title: String
  public var description: String?
  public var price: String
  public var images: [String?]?
  public var location: String
  public var isAvailable: Bool
  public var datePosted: Temporal.DateTime
  public var numberOfBedrooms: Int
  public var numberOfBathrooms: Int
  public var squareFootage: Int
  public var amenities: [String?]?
  public var owner: String?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      title: String,
      description: String? = nil,
      price: String,
      images: [String?]? = nil,
      location: String,
      isAvailable: Bool,
      datePosted: Temporal.DateTime,
      numberOfBedrooms: Int,
      numberOfBathrooms: Int,
      squareFootage: Int,
      amenities: [String?]? = nil,
      owner: String? = nil) {
    self.init(id: id,
      title: title,
      description: description,
      price: price,
      images: images,
      location: location,
      isAvailable: isAvailable,
      datePosted: datePosted,
      numberOfBedrooms: numberOfBedrooms,
      numberOfBathrooms: numberOfBathrooms,
      squareFootage: squareFootage,
      amenities: amenities,
      owner: owner,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      title: String,
      description: String? = nil,
      price: String,
      images: [String?]? = nil,
      location: String,
      isAvailable: Bool,
      datePosted: Temporal.DateTime,
      numberOfBedrooms: Int,
      numberOfBathrooms: Int,
      squareFootage: Int,
      amenities: [String?]? = nil,
      owner: String? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.title = title
      self.description = description
      self.price = price
      self.images = images
      self.location = location
      self.isAvailable = isAvailable
      self.datePosted = datePosted
      self.numberOfBedrooms = numberOfBedrooms
      self.numberOfBathrooms = numberOfBathrooms
      self.squareFootage = squareFootage
      self.amenities = amenities
      self.owner = owner
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}
extension RentalListing {
    func toListing(images: [UIImage]) -> Listing {
        return Listing(
            title: self.title,
            description: self.description ?? "",
            price: self.price,
            images: images, // convert downloaded images
            location: self.location,
            isAvailable: self.isAvailable,
            datePosted: self.datePosted.foundationDate,
            numberOfBedrooms: self.numberOfBedrooms,
            numberOfBathrooms: self.numberOfBathrooms,
            squareFootage: self.squareFootage,
            amenities: self.amenities?.compactMap { $0 } ?? [],
            street: "", city: "", province: "", owner: ""
        )
    }
}
