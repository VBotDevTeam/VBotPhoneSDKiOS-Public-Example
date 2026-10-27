# VBotPhoneSDKiOS-Public-Example

Ứng dụng mẫu minh họa cách tích hợp **VBotPhoneSDK** vào ứng dụng iOS để thực hiện cuộc gọi VoIP.

## Tính năng

- Gọi đi (Outgoing call) với CallKit
- Nhận cuộc gọi đến (Incoming call) qua PushKit
- Chọn Hotline trước khi gọi
- Giao diện cuộc gọi tùy chỉnh (Mute, Speaker, End call)
- Quản lý nhiều tài khoản người dùng
- Hiển thị thời gian cuộc gọi

## Yêu cầu

- iOS 13.0+
- Xcode 15.0+
- CocoaPods
- Apple Developer Account (để sử dụng PushKit)

## Cài đặt

### 1. Clone project

```bash
git clone https://github.com/VBotDevTeam/VBotPhoneSDKiOS-Public-Example.git
cd VBotPhoneSDKiOS-Public-Example
```

### 2. Cài đặt dependencies

```bash
pod install
```

### 3. Mở project

```bash
open VBotPhoneSDK-Example.xcworkspace
```

## Cấu hình

### Cấu hình Xcode Project

1. **Capabilities** → Bật **Push Notifications**
2. **Capabilities** → Bật **Background Modes**:
   - Audio, AirPlay, and Picture in Picture
   - Voice over IP
   - Background fetch

### Info.plist

Đảm bảo đã thêm quyền Microphone:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Microphone access is necessary to make calls.</string>
```

### Signing & Capabilities

Cấu hình **Team** và **Bundle Identifier** của bạn trong Xcode.

## Cấu trúc Project

```
VBotPhoneSDK-Example/
├── AppDelegate.swift                    # Khởi tạo SDK, PushKit, CallKit
├── ViewController.swift                 # Màn hình chính (chọn tài khoản, gọi điện, hotline, masking session)
├── SelectMemberViewController.swift     # Chọn tài khoản mẫu (Staging)
├── TestData.swift                       # Dữ liệu tài khoản mẫu & quản lý UserDefaults
├── TestViewController.swift             # Màn hình mẫu điều hướng / chat
└── Helpers.swift                        # Utility extensions
```

## Sử dụng SDK

### Thêm dependency vào Podfile

```ruby
pod 'VBotPhoneSDKiOS-Public', :git => 'https://github.com/VBotDevTeam/VBotPhoneSDKiOS-Public.git', :tag => '1.1.11'
```

### Khởi tạo SDK

```swift
// AppDelegate.swift
let config = VBotConfig(
    supportPopupCall: true,
    includesCallsInRecents: true,
    iconTemplateImageData: UIImage(named: "callkit-icon")?.pngData()
)
VBotPhone.sharedInstance.setup(with: config)
```

### Kết nối tài khoản

```swift
VBotPhone.sharedInstance.connect(token: userToken, pushkitToken: pushToken) { name, error in
    if let error = error {
        print("Lỗi kết nối: \(error)")
        return
    }
    print("Đã kết nối: \(name ?? "")")
}
```

### Thực hiện cuộc gọi đi

```swift
VBotPhone.sharedInstance.startOutgoingCall(
    displayName: "Tên hiển thị",
    number: "0123456789",
    hotline: "hotlineNumber"
) { success, error in
    if success {
        print("Cuộc gọi bắt đầu")
    }
}
```

### Lắng nghe sự kiện cuộc gọi

```swift
extension ViewController: VBotPhoneDelegate {
    func callStateChanged(state: VBotCallState) {
        print("Trạng thái: \(state.description)")
    }

    func callEnded(reason: VBotEndCallReason, endedBy: VBotCallEndParty) {
        print("Cuộc gọi kết thúc: \(reason.key), bởi \(endedBy.key)")
    }
}
```

### Nhận cuộc gọi đến (PushKit)

```swift
// AppDelegate.swift
func pushRegistry(_ registry: PKPushRegistry,
                  didReceiveIncomingPushWith payload: PKPushPayload,
                  for type: PKPushType,
                  completion: @escaping () -> Void) {
    if type == .voIP {
        VBotPhone.sharedInstance.startIncomingCall(payload: payload, completion: completion)
    }
}
```


## Troubleshooting

### Lỗi "Sandbox: rsync.samba deny file-write-create"

Trong **Build Settings** → **User Script Sandboxing** → Chọn **No**

### Không nhận được cuộc gọi đến

1. Kiểm tra đã bật **Push Notifications** capability
2. Kiểm tra đã cấu hình đúng **VoIP certificate** trên Apple Developer Portal
3. Kiểm tra pushkit token đã được gửi lên server

## Liên hệ

VBot Dev Team - [https://vbot.vn](https://vbot.vn)
