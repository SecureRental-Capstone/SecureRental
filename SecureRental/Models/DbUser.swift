////
////  DbUser.swift
////  SecureRental
////
////  Created by Haniya Akhtar on 2024-11-15.
////
//
//
//
//enum UserTableError: Error {
//    case invalidAttributes
//}
//
//class DbUser {
//    var userId: String
//    var email: String
//    var name: String
//    var age: Int
//
//    init(userId: String, email: String, name: String, age: Int) {
//        self.userId = userId
//        self.email = email
//        self.name = name
//        self.age = age
//    }
//
//    //convert this DbUser object into a DynamoDB item
////    func getAsItem() throws -> [String: DynamoDBClientTypes.AttributeValue] {
////        return [
////            "userId": .s(userId),
////            "email": .s(email),
////            "name": .s(name),
////            "age": .n("\(age)") //DynamoDB stores numbers as strings
////        ]
////    }
//
//    //init DbUser object from DynamoDB item (for reading from DB)
////    convenience init(withItem item: [String: DynamoDBClientTypes.AttributeValue]) throws {
////        guard let userIdAttr = item["userId"],
////              case .s(let userId) = userIdAttr,  //extract userId as string
////              let emailAttr = item["email"],
////              case .s(let email) = emailAttr,  //extract email as string
////              let nameAttr = item["name"],
////              case .s(let name) = nameAttr,  //extract name as string
////              let ageAttr = item["age"],
////              case .n(let ageString) = ageAttr,  //extract age as string from .n
////              let age = Int(ageString) else {  //convert ageString to Int
////            
////            throw UserTableError.invalidAttributes
////        }
////
////        self.init(userId: userId, email: email, name: name, age: age)
////    }
//}
