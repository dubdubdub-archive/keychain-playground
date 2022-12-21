//
//  ContentView.swift
//  keychain-playground
//
//  Created by Robert Bordeaux on 12/19/22.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
//    let addData = (addKeychainData(Service: "dubdubdub.xyz", WalletAddr: "0xb8CE9ab6943e0eCED004cDe8e3bBed6568B2Fa01", Label: "dub_wallet", PrivateKey: "0x348ce564d427a3311b6536bbcff9390d69395b06ed6c486954e971d960fe8709"))
//    print(result)
    
    let readData = (readKeychainData(Service: "dubdubdub.xyz", WalletAddr: "0xb8CE9ab6943e0eCED004cDe8e3bBed6568B2Fa01", Label: "dub_wallet"))
}


class KeychainManager{
    enum KeychainError: Error{
        case duplicateEntry
        case unknown(OSStatus)
    }
    static func save(
        service: String,
        walletAddr: String,
        label: String,
        privateKey: Data
    ) throws {
//        print("In the class boss!")
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: walletAddr as AnyObject,
            kSecAttrLabel as String: label as AnyObject,
            kSecValueData as String: privateKey as AnyObject
        ]
        print(query)
        
        let status = SecItemAdd(query as CFDictionary, nil)
//        print("After the query boss!")
        
        guard status != errSecDuplicateItem else{
            throw KeychainError.duplicateEntry
        }
        
//        print("After the first guard boss!")
//        print(status)
        
        guard status == errSecSuccess else{
            throw KeychainError.unknown(status)
        }
        
//        print("After the second guard boss!")
        
        print("All good here boss")
    }
    
    static func get(
        service: String,
        walletAddr: String,
        label: String
    ) -> Data? {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: walletAddr as AnyObject,
            kSecAttrLabel as String: label as AnyObject,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        print("Status: \(status)")
        
        return result as? Data
    }
}

func addKeychainData(Service: String, WalletAddr: String, Label: String, PrivateKey: String){
    do {
//        print("got here boss!")
        try KeychainManager.save(
            service: Service,
            walletAddr: WalletAddr,
            label: Label,
            privateKey: PrivateKey.data(using: .utf8) ?? Data()
        )
    } catch {
        print(error)
    }
}

func readKeychainData(Service: String, WalletAddr: String, Label: String){
    guard let data = KeychainManager.get(
        service: Service,
        walletAddr: WalletAddr,
        label: Label
    ) else {
        print("Failed to read data with string")
//        print(data)
        return
    }
    let privateKey = String(decoding: data, as: UTF8.self)
    print(privateKey)
    
//    do {
////        print("got here boss!")
//        try KeychainManager.get(
//            service: Service,
//            walletAddr: WalletAddr,
//            label: Label
//        )
//    } catch {
//        print(error)
//    }
}
