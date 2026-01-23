//
//  TestData.swift
//  VBotPhoneSDK_Example
//
//  Created by VPMedia on 02/02/2025.
//

import Foundation




struct User: Codable, Equatable {
    let name: String
    let token: String
}


// MARK: - User List Management

let kUserListKey = "UserListKey"

func saveUser(_ user: User) {
    var users = getUserList()
    if let idx = users.firstIndex(where: { $0.name == user.name }) {
        users[idx] = user // update nếu trùng tên
    } else {
        users.append(user)
    }
    if let data = try? JSONEncoder().encode(users) {
        UserDefaults.standard.set(data, forKey: kUserListKey)
    }
}

func getUserList() -> [User] {
    if let data = UserDefaults.standard.data(forKey: kUserListKey),
       let users = try? JSONDecoder().decode([User].self, from: data) {
        return users
    }
    return []
}

func deleteUser(_ user: User) {
    var users = getUserList()
    users.removeAll { $0 == user }
    if let data = try? JSONEncoder().encode(users) {
        UserDefaults.standard.set(data, forKey: kUserListKey)
    }
}

func deleteUserByName(_ name: String) {
    var users = getUserList()
    users.removeAll { $0.name == name }
    if let data = try? JSONEncoder().encode(users) {
        UserDefaults.standard.set(data, forKey: kUserListKey)
    }
}

// Hàm lưu PushToken vào UserDefaults
func savePushToken(_ token: String) {
    UserDefaults.standard.set(token, forKey: "PushToken")
}

// Hàm lấy PushToken từ UserDefaults
func getPushToken() -> String? {
    return UserDefaults.standard.string(forKey: "PushToken")
}

// MARK: - Custom Token Management

// Hàm lưu Custom Token vào UserDefaults
func saveCustomToken(_ token: String) {
    UserDefaults.standard.set(token, forKey: "CustomToken")
}

// Hàm lấy Custom Token từ UserDefaults
func getSavedCustomToken() -> String? {
    return UserDefaults.standard.string(forKey: "CustomToken")
}

// Hàm xóa Custom Token
func deleteCustomToken() {
    UserDefaults.standard.removeObject(forKey: "CustomToken")
}

extension UserDefaults {
    private static let sdkMemberUserKey = "SDKMemberUser"
    static var sdkMemberUser: User? {
        get {
            if let savedData = standard.data(forKey: sdkMemberUserKey),
               let loadedUser = try? JSONDecoder().decode(User.self, from: savedData) {
                return loadedUser
            }
            return nil
        }
        set {
            if let user = newValue, let encoded = try? JSONEncoder().encode(user) {
                standard.set(encoded, forKey: sdkMemberUserKey)
            }
        }
    }
    static func removeSDKMemberUser() {
        standard.removeObject(forKey: sdkMemberUserKey)
    }
}