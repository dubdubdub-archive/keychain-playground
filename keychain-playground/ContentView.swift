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
    
//    let readData: () = (readKeychainData(Service: "dubdubdub.xyz", WalletAddr: "0xb8CE9ab6943e0eCED004cDe8e3bBed6568B2Fa01", Label: "dub_wallet"))
    

    let run = (initial())
    
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
//            kSecReturnAttributes as String: kCFBooleanTrue,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        print (query)
        print("Status: \(status)")
        
        return result as? Data
    }
    
    static func getWalletAddr(
        service: String,
        label: String
    ) -> [String]? {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrLabel as String: label as AnyObject,
            kSecReturnAttributes as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]
//        var item: CFTypeRef?
        var result: AnyObject?
        var ethereumAddresses = [String]()
//        let status = SecItemCopyMatching(query as CFDictionary, &result)
//        for matches in SecItemCopyMatching(query as CFDictionary, &result){
//
//        }
        if SecItemCopyMatching(query as CFDictionary, &result) == noErr {
//            print("In here boss!")
            // Extract result
            
            if let existingItem = result as? [[String: Any]] {
                existingItem.forEach { item in
                    ethereumAddresses.append(item["acct"] as! String)
                }
                print(existingItem)
                return ethereumAddresses
            }
        } else {
            print("Something went wrong trying to find the user in the keychain")
        }
        print (query)
        let ethereumAddressesNoOptionals = ethereumAddresses.compactMap { $0 }
        return ethereumAddressesNoOptionals
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
        print("Failed to read key with given query")
        //        print(data)
        return
    }
    let privateKey = String(decoding: data, as: UTF8.self)
    print(privateKey)
}
    
func readEthereumAddress(Service: String, Label: String) -> [String]{
    guard let WalletAddr: [String] = KeychainManager.getWalletAddr(
        service: Service,
        label: Label
    ) else {
        print("Failed to read address with given query")
        //        print(data)
        return ["nil"]
    }
//    if let unWalletAddr = WalletAddr {
//        print (WalletAddr)
//        return WalletAddr
//    }
    let ethereumAddressesNoOptionals = WalletAddr.compactMap { $0 }
    let ethereumAddressesNoNil = ethereumAddressesNoOptionals.filter { $0 != "nil" }
//    print (ethereumAddressesNoNil)
    return ethereumAddressesNoNil
//    print(WalletAddr)
//    return WalletAddr
//    let EthereumAddresses = String(WalletAddr)
    
//    do {
////        print("got here boss!")
//        try KeychainManager.getWalletAddr(
//            service: Service,
//            label: Label
//        )
//    } catch {
//        print(error)
//    }
}

func initial() {
    let readWalletAddr: [String] = (readEthereumAddress(Service: "dubdubdub.xyz", Label: "dub_wallet"))
    if readWalletAddr.count == 0{
        print ("No accounts found!")
    } else {
        print (readWalletAddr)
    }
    
    
//        let addData = (addKeychainData(Service: "dubdubdub.xyz", WalletAddr: "0x28CE9ab6943e0eCED004cDe8e3Hf7d6568B2Fa01", Label: "dub_wallet", PrivateKey: "0x915ce564d427a3311b6536bbcff9390d69395b06ed6c486954e971d960fe8709"))
//        print(addData)
        
//        let readPrivateKeyData: () = (readKeychainData(Service: "dubdubdub.xyz", WalletAddr: "0xb8CE9ab6943e0eCED004cDe8e3bBed6568B2Fa01", Label: "dub_wallet"))
//        print(readPrivateKeyData)
    
}
    
    
    
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

