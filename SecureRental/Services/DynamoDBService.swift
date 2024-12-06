//
//  DynamoDBService.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2024-11-15.
//


//import Foundation
//
//enum DynamoDBServiceError: Error {
//    case invalidAttributes
//    case uninitializedClient
//    case itemNotFound
//    case tableNotFound
//}
//
//class DynamoDBService {
//    
//    private var ddbClient: DynamoDBClient?
//    private let tableName: String
//
//    init(region: String, tableName: String) {
//        self.tableName = tableName
//        self.ddbClient = try? DynamoDBClient(region: region)  //init DynamoDB client
//    }
//
//    //fetch a user from DynamoDB using userId
//    func getUser(userId: String) async throws -> DbUser? {
//        guard let client = self.ddbClient else {
//            throw DynamoDBServiceError.uninitializedClient
//        }
//
//        let getItemInput = GetItemInput(
//            key: [
//                "userId": .s(userId)  //key is userId as a string
//            ], tableName: tableName
//        )
//
//        let output = try await client.getItem(input: getItemInput)
//
//        //if no item was found, return nil
//        guard let item = output.item else {
//            return nil
//        }
//        
//        if let userIdAttr = item["userId"],
//           case .s(let userId) = userIdAttr,  //extract userId as a string
//           let emailAttr = item["email"],
//           case .s(let email) = emailAttr,  //extract email as a string
//           let nameAttr = item["name"],
//           case .s(let name) = nameAttr,  //extract name as a string
//           let ageAttr = item["age"],
//           case .n(let ageStr) = ageAttr,  //extract age as a string from .n
//           let age = Int(ageStr) {  //convert age string to Int
//
//            //return the User object if everything is valid
//            return DbUser(
//                userId: userId,
//                email: email,
//                name: name,
//                age: age
//            )
//            
//        } else {
//            throw DynamoDBServiceError.invalidAttributes
//        }
//    }
//
//    func getProfile(userId: String) async throws -> Profile? {
//        guard let client = self.ddbClient else {
//            throw DynamoDBServiceError.uninitializedClient
//        }
//
//        let getItemInput = GetItemInput(
//            key: [
//                "userId": DynamoDBClientTypes.AttributeValue.s(userId)  //key is userId as a string
//            ],
//            tableName: "Profiles"
//        )
//
//        let output = try await client.getItem(input: getItemInput)
//
//        //if no item was found, return nil
//        guard let item = output.item else {
//            return nil
//        }
//        
//        // Extract attributes from the DynamoDB item
//        if let userIdAttr = item["userId"],
//           case .s(let userId) = userIdAttr,  //extract userId as a string
//           let emailAttr = item["email"],
//           case .s(let email) = emailAttr,  //extract email as a string
//           let nameAttr = item["name"],
//           case .s(let name) = nameAttr,  //extract name as a string
//           let bioAttr = item["bio"],
//           case .s(let bio) = bioAttr,  //extract bio as a string
//           let addressAttr = item["address"],
//           case .s(let address) = addressAttr,  //extract address as a string
//           let phoneNumberAttr = item["phoneNumber"],
//           case .s(let phoneNumber) = phoneNumberAttr,  //extract phoneNumber as a string
//           let ageAttr = item["age"],
//           case .n(let ageStr) = ageAttr,  //extract age as a string from .n
//           let age = Int(ageStr) {  //convert age string to Int
//
//            //return the Profile object with extracted data
//            return Profile(
//                userId: userId,
//                email: email,
//                name: name,
//                bio: bio,
//                address: address,
//                phoneNumber: phoneNumber,
//                age: age
//            )
//            
//        } else {
//            //if any required attribute is missing, throw an error
//            throw DynamoDBServiceError.invalidAttributes
//        }
//    }
//    
//    func updateProfile(profile: Profile) async throws {
//        guard let client = self.ddbClient else {
//            throw DynamoDBServiceError.uninitializedClient
//        }
//
//        let updateItemInput = UpdateItemInput(
//            expressionAttributeValues: [
//                ":email": DynamoDBClientTypes.AttributeValue.s(profile.email ?? ""),
//                ":name": DynamoDBClientTypes.AttributeValue.s(profile.name ?? ""),
//                ":bio": DynamoDBClientTypes.AttributeValue.s(profile.bio ?? ""),
//                ":address": DynamoDBClientTypes.AttributeValue.s(profile.address ?? ""),
//                ":phoneNumber": DynamoDBClientTypes.AttributeValue.s(profile.phoneNumber ?? ""),
//                ":age": DynamoDBClientTypes.AttributeValue.n(String(profile.age ?? 0))
//            ], key: [
//                "userId": DynamoDBClientTypes.AttributeValue.s(profile.userId)  //key is userId
//            ],
//            tableName: "Profiles", updateExpression: "SET email = :email, name = :name, bio = :bio, address = :address, phoneNumber = :phoneNumber, age = :age"  // Ensure the correct table name
//        )
//
//        //perform the update in DynamoDB
//        _ = try await client.updateItem(input: updateItemInput)
//    }
//
//    
//    //add a user to DynamoDB
//    func addUser(user: DbUser) async throws {
//        guard let client = self.ddbClient else {
//            throw DynamoDBServiceError.uninitializedClient
//        }
//
//        let putItemInput = PutItemInput(
//            item: [
//                "userId": .s(user.userId),
//                "email": .s(user.email),
//                "name": .s(user.name),
//                "age": .n(String(user.age))
//            ], tableName: tableName
//        )
//
//        //put the item into DynamoDB
//        _ = try await client.putItem(input: putItemInput)
//    }
//    
//    //example of a sign-in function
//    func signInUser(email: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void) {
//        //call service to check credentials, rn assumming sign-in is successful always
//        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
//            if email == "test@example.com" && password == "password123" {
//                completion(.success(true))
//            } else {
//                completion(.success(false))
//            }
//        }
//    }
//
//    //update a user in DynamoDB
//    func updateUser(user: DbUser) async throws {
//        guard let client = self.ddbClient else {
//            throw DynamoDBServiceError.uninitializedClient
//        }
//
//        let updateItemInput = UpdateItemInput(
//            expressionAttributeValues: [
//                ":email": .s(user.email),
//                ":name": .s(user.name),
//                ":age": .n(String(user.age))
//            ], key: [
//                "userId": .s(user.userId)
//            ], tableName: tableName,
//            updateExpression: "SET email = :email, name = :name, age = :age"
//        )
//
//        _ = try await client.updateItem(input: updateItemInput)
//    }
//
//    //delete a user from DynamoDB
//    func deleteUser(userId: String) async throws {
//        guard let client = self.ddbClient else {
//            throw DynamoDBServiceError.uninitializedClient
//        }
//
//        let deleteItemInput = DeleteItemInput(
//            key: [
//                "userId": .s(userId)
//            ],
//            tableName: tableName
//        )
//
//        _ = try await client.deleteItem(input: deleteItemInput)
//    }
//
//    //check if a table exists
//    func tableExists() async throws -> Bool {
//        guard let client = self.ddbClient else {
//            throw DynamoDBServiceError.uninitializedClient
//        }
//
//        let describeTableInput = DescribeTableInput(tableName: tableName)
//        let output = try await client.describeTable(input: describeTableInput)
//
//        return output.table?.tableName == tableName
//    }
//
//    //wait until the table is active
//    func awaitTableActive() async throws {
//        while try (await self.tableExists() == false) {
//            do {
//                let duration = UInt64(0.25 * 1_000_000_000) // 0.25 seconds
//                try await Task.sleep(nanoseconds: duration)
//            } catch {
//                print("Sleep error:", dump(error))
//            }
//        }
//
//        //check if table status is active
//        while try (await self.getTableStatus() != .active) {
//            do {
//                let duration = UInt64(0.25 * 1_000_000_000) //0.25 seconds
//                try await Task.sleep(nanoseconds: duration)
//            } catch {
//                print("Sleep error:", dump(error))
//            }
//        }
//    }
//
//    //get table status
//    func getTableStatus() async throws -> DynamoDBClientTypes.TableStatus {
//        guard let client = self.ddbClient else {
//            throw DynamoDBServiceError.uninitializedClient
//        }
//
//        let describeTableInput = DescribeTableInput(tableName: tableName)
//        let output = try await client.describeTable(input: describeTableInput)
//
//        guard let status = output.table?.tableStatus else {
//            throw DynamoDBServiceError.invalidAttributes
//        }
//
//        return status
//    }
//}
