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
    case xanhsm = "xanhsm"
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
    SDKMember(type: "ios", typeTest: "vbot", callName: "cangu 01 Staging", ext: "112", token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJWYWx1ZSI6IjIyLTE1NS0zNS0xMzY0In0.OPL0OHrmKDGrWWdKx22Ys4K7fMkqbGetH8b3qCiRxXM"),
    SDKMember(type: "ios", typeTest: "vbot", callName: "vbottester 01 Staging", ext: "112", token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJWYWx1ZSI6IjIyLTE1Ny0zNi00MyJ9.lbE3ExHza6t8kcMrT9BPQGmtCUz_l1F3Pk9WX7OrQ3w"),
    SDKMember(type: "ios", typeTest: "vbot", callName: "vbottester 02 Staging", ext: "113", token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJWYWx1ZSI6IjIyLTE1Ny0zNi00MyJ9.lbE3ExHza6t8kcMrT9BPQGmtCUz_l1F3Pk9WX7OrQ3w"),
    SDKMember(type: "ios", typeTest: "vbot", callName: "iOS 01 Dev", ext: "104", token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJWYWx1ZSI6IjU0ODctNzg4NS03MjQtODE0In0._Srt3W-r34ZzCfRXZ5ZNm-0xyoDlQ8a8UHaKr1j5Lko"),
    SDKMember(type: "ios", typeTest: "vbot", callName: "bhxh 01 Staging", ext: "101", token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJWYWx1ZSI6IjE1OC0zNDEtMTI5LTE5ODYifQ.OqWZ2elMrzhyBkongmZxQWyKu5MVDjiZN3mbm20PEI0"),
    SDKMember(type: "ios", typeTest: "vbot", callName: "bhxh 02 Staging", ext: "102", token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJWYWx1ZSI6IjE1OC0zNDItMTMwLTE5ODcifQ.BxSDzTqPVz37VWZbc6f1bKxg0f_xjrVlHDWOlulvpu4"),
    SDKMember(type: "ios", typeTest: "vbot", callName: "bhxh 03 Staging", ext: "103", token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJWYWx1ZSI6IjE1OC0zNDMtMTMxLTE5ODgifQ._NikGj24gwyb1h7EMkIC6lH_y4gYE4BWX7OGOqko0jc"),

    
    SDKMember(type: "ios", typeTest: "vbot", callName: "thanhntos sdk", ext: "112", token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJWYWx1ZSI6IjU0ODctODMwNy03MzktODMyIn0.tB-wgZXw5I8-k5mfEUJ2fyjgXBfUulNHzMbISRzRNYQ"),
]


@MainActor let VBotMemberForCall: [SDKMember]  = [
    SDKMember(type: "ios", typeTest: "vbot", callName: "ThanhntOS", ext: "2630", token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJWYWx1ZSI6IjU0ODctNjMxMi0zNzUtODA1In0.gIg859oUGCDycy1hCUJXEyDve7j5YGJREIgDWMpxXbc"),
]

//@MainActor let TestAccount: [SDKMember] = [
//    SDKMember(type: "ios", typeTest: "vbot", callName: "VBot iOS 01", ext: "102", token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJWYWx1ZSI6IjU1LTQxLTEzLTIxIn0.hAmi-c9nuzANHvs7fZyYPkO4kJNQ4iu5UbCz-tUwTJQ"),
//    SDKMember(type: "ios", typeTest: "vbot", callName: "VBot iOS 02", ext: "103", token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJWYWx1ZSI6IjU1LTQyLTE0LTIwIn0.L2THsu4Qns-UUfuu2CFDABdgKr-i1K00GqEBYaNc1nk"),
//    SDKMember(type: "ios", typeTest: "vbot", callName: "VBot android", ext: "101", token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJWYWx1ZSI6IjQ1LTE3LTQtNyJ9.tfUUUNAqq00Z3qnCQ4DP1kQ9-jfLBwNRXEoK0pv86-A"),
//    SDKMember(type: "ios", typeTest: "vbot", callName: "VBot Admin", ext: "0", token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJWYWx1ZSI6IjU5NDMtNTUyNi0yOTEtMzU1In0.6uNPF1nk-sKJYjB82dsiX8nHt3CRr4cArBwkRAfqGF0")
//]
//
//
//@MainActor let VBotMemberForCall: [SDKMember]  = [
//    SDKMember(type: "ios", typeTest: "vbot", callName: "quocdattt", ext: "6666", token: "ios01"),
//    SDKMember(type: "ios", typeTest: "vbot", callName: "Cá Ngừ Admin", ext: "0", token: "ios01"),
//    SDKMember(type: "ios", typeTest: "vbot", callName: "Cá Voi", ext: "3752", token: "ios01"),
//    SDKMember(type: "ios", typeTest: "vbot", callName: "Cá Mòi", ext: "3437", token: "ios01"),
//    SDKMember(type: "ios", typeTest: "vbot", callName: "Cá Heo", ext: "2182", token: "ios01"),
//    SDKMember(type: "ios", typeTest: "vbot", callName: "Cá Chim", ext: "8345", token: "ios01"),
//    SDKMember(type: "ios", typeTest: "vbot", callName: "Cá Mú", ext: "2551", token: "ios01"),
//    SDKMember(type: "ios", typeTest: "vbot", callName: "Cá Chuồn", ext: "1926", token: "ios01"),
//   
//    
//]


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
