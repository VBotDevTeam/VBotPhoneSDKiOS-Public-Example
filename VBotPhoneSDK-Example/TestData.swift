//
//  TestData.swift
//  VBotPhoneSDK_Example
//
//  Created by VPMedia on 02/02/2025.
//

import Foundation

enum TypeDevice: String {
    case ios = "ios"
    case android = "android"
}

enum TypeTest: String {
    case vbot = "vbot"
}

class SDKMember: Codable {
    var type: String
    var typeTest: String
    var ext: String
    var callName: String
    var token: String
    
    init(type: String, typeTest: String, callName: String, ext: String, token: String) {
        self.type = type
        self.typeTest = typeTest
        self.ext = ext
        self.callName = callName
        self.token = token
    }
}

@MainActor let TestAccount: [SDKMember] = [
    SDKMember(type: "ios", typeTest: "vbot", callName: "vbottester 01 Staging", ext: "112", token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJWYWx1ZSI6IjIyLTE1NS0zNS0xMzY0In0.OPL0OHrmKDGrWWdKx22Ys4K7fMkqbGetH8b3qCiRxXM"),
    SDKMember(type: "ios", typeTest: "vbot", callName: "vbottester 02 Staging", ext: "113", token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJWYWx1ZSI6IjIyLTE1Ny0zNi00MyJ9.lbE3ExHza6t8kcMrT9BPQGmtCUz_l1F3Pk9WX7OrQ3w"),
]

@MainActor let VBotMemberForCall: [SDKMember] = [
    SDKMember(type: "ios", typeTest: "vbot", callName: "vbottester 03", ext: "2630", token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJWYWx1ZSI6IjU0ODctNjMxMi0zNzUtODA1In0.gIg859oUGCDycy1hCUJXEyDve7j5YGJREIgDWMpxXbc"),
]

// Hàm lưu CallUser vào UserDefaults
func saveSDKMember(_ user: SDKMember) {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(user) {
        UserDefaults.standard.set(encoded, forKey: "SDKMember")
    }
}

// Hàm lấy CallUser từ UserDefaults
func getSDKMember() -> SDKMember? {
    if let savedData = UserDefaults.standard.data(forKey: "SDKMember") {
        let decoder = JSONDecoder()
        if let loadedUser = try? decoder.decode(SDKMember.self, from: savedData) {
            return loadedUser
        }
    }
    return nil
}

func deleteSDKMember() {
    UserDefaults.standard.removeObject(forKey: "SDKMember")
}

// Hàm lưu PushToken vào UserDefaults
func savePushToken(_ token: String) {
    UserDefaults.standard.set(token, forKey: "PushToken")
}

// Hàm lấy PushToken từ UserDefaults
func getPushToken() -> String? {
    return UserDefaults.standard.string(forKey: "PushToken")
}
