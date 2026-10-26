//
//  ViewController.swift
//  VBotPhoneSDK-Example
//
//  Created by VPMedia on 01/04/2024.
//  Copyright (c) 2024 VPMedia. All rights reserved.
//

import UIKit
import VBotPhoneSDK
import AVFAudio

class ViewController: UIViewController {
    // MARK: - UI Components

    private lazy var selectMemberButton = createButton(
        title: "Chọn tài khoản",
        backgroundColor: UIColor.systemMintCompat,
        action: #selector(go_selectMember)
    )
    
    private lazy var loginButton = createButton(
        title: "Lưu",
        backgroundColor: .systemBlue,
        action: #selector(loginButton_tapped)
    )
    
    private lazy var accountLabel = createLabel(
        text: "Chưa chọn tài khoản",
        textColor: .red
    )
    
    private lazy var selectMemberToCallButton = createButton(
        title: "Chọn tài khoản để gọi",
        backgroundColor: .systemGreen,
        action: #selector(go_selectMemberToCall)
    )
    
    private let phoneTf: UITextField = {
        let tf = UITextField()
        tf.clearButtonMode = .always
        tf.keyboardType = .numberPad
        tf.borderStyle = .roundedRect
        tf.placeholder = "Nhập số điện thoại"
        return tf
    }()
    
    private lazy var callSessionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Dùng Call Session (Masking)"
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    private lazy var callSessionSwitch: UISwitch = {
        let sw = UISwitch()
        sw.translatesAutoresizingMaskIntoConstraints = false
        sw.isOn = false
        return sw
    }()
    
    private lazy var callSessionToggleStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [callSessionLabel, callSessionSwitch])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        callSessionSwitch.setContentHuggingPriority(.required, for: .horizontal)
        callSessionLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return stackView
    }()
    
    private lazy var callButton = createButton(
        title: "Gọi",
        backgroundColor: UIColor.systemMintCompat,
        action: #selector(callButton_tapped)
    )
    
    private lazy var getHotlinesButton = createButton(
        title: "Get Hotlines",
        backgroundColor: .systemOrange,
        action: #selector(getHotlinesButton_tapped)
    )
    
    private lazy var selectHotlineButton = createButton(
        title: "Chọn Hotline",
        backgroundColor: .systemPurple,
        action: #selector(selectHotlineButton_tapped)
    )
    
    private lazy var selectedHotlineLabel = createLabel(
        text: "Chưa chọn hotline",
        textColor: .gray
    )
    
    private lazy var line = createLine()
    
    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    // MARK: - Properties

    private let client = VBotPhone.sharedInstance
    private var selectedMember: SDKMember?
    private var memberToCall: SDKMember?
    private var selectedHotline: VBotHotline?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        hideKeyboardWhenTappedAround()
        setupView()
        
        phoneTf.addTarget(self, action: #selector(phoneTextFieldDidChange), for: .editingChanged)
        VBotPhone.sharedInstance.addDelegate(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIDevice.current.isProximityMonitoringEnabled = false
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .default
    }

    // MARK: - Setup UI

    private func setupUI() {
        view.addSubview(containerStackView)
        
        let items: [UIView] = [
            accountLabel,
            selectMemberButton,
            loginButton,
            line,
            selectMemberToCallButton,
            phoneTf,
            callSessionToggleStack,
            callButton,
            getHotlinesButton,
            selectHotlineButton,
            selectedHotlineLabel
        ]
        
        items.forEach { containerStackView.addArrangedSubview($0) }
        
        NSLayoutConstraint.activate([
            containerStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            containerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            loginButton.heightAnchor.constraint(equalToConstant: 44),
            accountLabel.heightAnchor.constraint(equalToConstant: 44),
            selectMemberToCallButton.heightAnchor.constraint(equalToConstant: 44),
            callSessionToggleStack.heightAnchor.constraint(equalToConstant: 44),
            getHotlinesButton.heightAnchor.constraint(equalToConstant: 44),
            selectHotlineButton.heightAnchor.constraint(equalToConstant: 44),
            selectedHotlineLabel.heightAnchor.constraint(equalToConstant: 44),
            line.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupView() {
        if let loadedUser = getSDKMember() {
            setupViewForLoggedInUser(loadedUser)
        } else {
            setupViewForLoggedOutUser()
        }
    }
    
    private func setupViewForLoggedInUser(_ member: SDKMember) {
        selectedMember = member
        selectMemberToCallButton.isEnabled = true
        selectMemberButton.isEnabled = true
        loginButton.setTitle("Xóa", for: .normal)
        loginButton.backgroundColor = .systemRed
        accountLabel.isHidden = false
        
        let attributedText = NSMutableAttributedString(string: "Đã kết nối: ", attributes: [
            .font: UIFont.systemFont(ofSize: 16, weight: .regular),
            .foregroundColor: UIColor.black
        ])
        
        let userColor = UIColor.systemTealCompat
        let userAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: userColor
        ]
        
        attributedText.append(NSAttributedString(string: member.callName, attributes: userAttributes))
        accountLabel.attributedText = attributedText
        
        if let member = findTestMember(by: member.ext) {
            selectedMember = member
            selectMemberButton.setTitle("Đã chọn: \(member.callName)", for: .normal)
            selectMemberButton.isEnabled = false
        }
        
        phoneTextFieldDidChange()
    }
    
    func findTestMember(by ext: String) -> SDKMember? {
        return TestAccount.first { $0.ext == ext }
    }
    
    private func setupViewForLoggedOutUser() {
        selectMemberButton.isEnabled = true
        selectMemberToCallButton.isEnabled = false
        loginButton.setTitle("Lưu", for: .normal)
        loginButton.backgroundColor = .systemBlue
        accountLabel.text = "Chưa chọn tài khoản"
        accountLabel.textColor = .red
        
        phoneTextFieldDidChange()
    }
    
    // MARK: - Actions

    @objc private func go_selectMember() {
        presentSelectMemberViewController(toCall: false)
    }
    
    @objc private func go_selectMemberToCall() {
        presentSelectMemberViewController(toCall: true)
    }
    
    @objc private func loginButton_tapped() {
        if getSDKMember() == nil {
            if let member = selectedMember {
                saveMember(member)
            } else {
                showError(code: 401, message: "Chưa chọn thành viên")
            }
        } else {
            deleteMember()
        }
    }
    
    @objc private func callButton_tapped() {
        let phone = phoneTf.text ?? ""
        makeCall(memberToCall, phonenumber: phone)
    }
    
    @objc private func phoneTextFieldDidChange() {
        let phoneNumber = phoneTf.text ?? ""
        callButton.isEnabled = memberToCall != nil || !phoneNumber.isEmpty
    }
    
    @objc private func getHotlinesButton_tapped() {
        showProgress()
        VBotPhone.sharedInstance.getHotlines { [weak self] hotlines, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.hideProgress()
                if let error = error {
                    if let nsError = error as NSError? {
                        self.showError(code: nsError.code, message: nsError.localizedDescription)
                    } else {
                        self.showError(code: -1, message: error.localizedDescription)
                    }
                    return
                }
                let hotlinesList: [VBotHotline] = hotlines ?? []
                let lines = hotlinesList.map { "\($0.name) (\($0.phoneNumber))" }
                let message = lines.isEmpty ? "No hotlines available" : lines.joined(separator: "\n")
                let alert = UIAlertController(title: "Hotlines", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
    @objc private func selectHotlineButton_tapped() {
        showProgress()
        VBotPhone.sharedInstance.getHotlines { [weak self] hotlines, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.hideProgress()
                if let error = error {
                    if let nsError = error as NSError? {
                        self.showError(code: nsError.code, message: nsError.localizedDescription)
                    } else {
                        self.showError(code: -1, message: error.localizedDescription)
                    }
                    return
                }
                
                guard let hotlinesList = hotlines, !hotlinesList.isEmpty else {
                    self.showError(code: -1, message: "Không có hotline nào khả dụng")
                    return
                }
                
                let alert = UIAlertController(title: "Chọn Hotline", message: "Vui lòng chọn hotline để gọi", preferredStyle: .actionSheet)
                
                for hotline in hotlinesList {
                    let action = UIAlertAction(title: "\(hotline.name) (\(hotline.phoneNumber))", style: .default) { [weak self] _ in
                        self?.selectedHotline = hotline
                        self?.updateSelectedHotlineLabel()
                    }
                    alert.addAction(action)
                }
                
                let cancelAction = UIAlertAction(title: "Hủy", style: .cancel)
                alert.addAction(cancelAction)
                
                if let popoverController = alert.popoverPresentationController {
                    popoverController.sourceView = self.selectHotlineButton
                    popoverController.sourceRect = self.selectHotlineButton.bounds
                }
                
                self.present(alert, animated: true)
            }
        }
    }
    
    private func updateSelectedHotlineLabel() {
        if let hotline = selectedHotline {
            selectedHotlineLabel.text = "Hotline: \(hotline.name) (\(hotline.phoneNumber))"
            selectedHotlineLabel.textColor = .systemBlue
        } else {
            selectedHotlineLabel.text = "Chưa chọn hotline"
            selectedHotlineLabel.textColor = .gray
        }
    }
    
    // MARK: - Helper Methods

    private func createButton(title: String, backgroundColor: UIColor, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 4
        button.tintColor = .white
        return button
    }
    
    private func createLabel(text: String, textColor: UIColor) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = text
        label.textColor = textColor
        return label
    }
    
    private func createLine() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }
    
    private func presentSelectMemberViewController(toCall: Bool) {
        let vc = SelectMemberViewController(delegate: self, toCall: toCall)
        present(vc.wrapToNavigationController(), animated: true)
    }
    
    private func saveMember(_ member: SDKMember) {
        showProgress()
        let pushKitToken = getPushToken() ?? ""
        VBotPhone.sharedInstance.connect(token: member.token, pushkitToken: pushKitToken) { [weak self] name, error in
            guard let self = self else { return }
            if let error = error as NSError? {
                self.showError(code: error.code, message: error.localizedDescription)
                self.hideProgress()
                return
            }
            saveSDKMember(member)
            self.hideProgress()
            self.setupViewForLoggedInUser(member)
        }
    }
    
    private func deleteMember() {
        showProgress()
        VBotPhone.sharedInstance.disconnect { [weak self] error in
            guard let self = self else { return }
            if let error = error as NSError? {
                self.showError(code: error.code, message: error.localizedDescription)
            }
            self.hideProgress()
            deleteSDKMember()
            self.setupViewForLoggedOutUser()
        }
    }
    
    func generateExternalCallId(length: Int = 32) -> String {
        let maxLength = min(length, 32)
        let allowedCharacters = Array("abcdefghijklmnopqrstuvwxyz0123456789")
        
        return String((0..<maxLength).map { _ in
            allowedCharacters.randomElement()!
        })
    }
    
    func fetchCallSession(phoneNumber: String, completion: @escaping (String?, Error?) -> Void) {
        guard let url = URL(string: "https://open-api-staging.vbot.vn/v3.0/api/call-sessions") else {
            completion(nil, NSError(domain: "AppError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("sk-opa-qtFTJi1qfOY_Hlf-Gj8KN1vvYqAumDX_rb-2oMq5Ar0CN0n--H0ODHbpK7t0spozHtKALa4e7wdsqy2XViTcvW0YALXh0AMFKvg32jBgVSc", forHTTPHeaderField: "X-API-Key")
        
        let reqBody = CallSessionRequest(phone_number: phoneNumber)
        do {
            request.httpBody = try JSONEncoder().encode(reqBody)
        } catch {
            completion(nil, error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "AppError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(CallSessionResponse.self, from: data)
                if apiResponse.error == 0, let sessionData = apiResponse.data {
                    completion(sessionData.session_id, nil)
                } else {
                    let errMsg = apiResponse.message ?? "Unknown error"
                    completion(nil, NSError(domain: "AppError", code: apiResponse.error, userInfo: [NSLocalizedDescriptionKey: errMsg]))
                }
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    
    private func makeCall(_ member: SDKMember? = nil, phonenumber: String = "") {
        callButton.isEnabled = false
        var name = ""
        var phone = ""
        
        if phonenumber != "" {
            name = phonenumber
            phone = phonenumber
        } else {
            if member != nil {
                name = member!.callName
                phone = member!.ext
            }
        }
        
        let hotline = selectedHotline?.phoneNumber ?? ""
        let externalCallId = generateExternalCallId()
        
        if callSessionSwitch.isOn {
            showProgress()
            
            fetchCallSession(phoneNumber: phone) { [weak self] sessionId, error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.hideProgress()
                    
                    if let error = error {
                        self.showError(code: (error as NSError).code, message: error.localizedDescription)
                        self.callButton.isEnabled = true
                        return
                    }
                    
                    guard let sessionId = sessionId, !sessionId.isEmpty else {
                        self.showError(code: -1, message: "Không thể lấy session_id")
                        self.callButton.isEnabled = true
                        return
                    }
                    
                    self.performStartOutgoingCall(displayName: name, number: sessionId, hotline: hotline, externalCallId: externalCallId)
                }
            }
        } else {
            performStartOutgoingCall(displayName: name, number: phone, hotline: hotline, externalCallId: externalCallId)
        }
    }
    
    private func performStartOutgoingCall(displayName: String, number: String, hotline: String, externalCallId: String) {
        client.startOutgoingCall(displayName: displayName, number: number, hotline: hotline, externalCallId: externalCallId) { [weak self] success, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.callButton.isEnabled = true
            }
            if success {
                return
            } else {
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
                    if let error = error as NSError? {
                        self.showError(code: error.code, message: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    private func showError(code: Int, message: String) {
        let errorMessage = UIAlertController(title: "Lỗi", message: "Code: \(code)\nMessage: \(message)", preferredStyle: .alert)
        errorMessage.addAction(UIAlertAction(title: "Đóng", style: .default))
        present(errorMessage, animated: true)
    }
}

// MARK: - SelectMemberVCDelegate

extension ViewController: SelectMemberVCDelegate {
    func didSelectMember(_ member: SDKMember, toCall: Bool) {
        if toCall {
            memberToCall = member
            selectMemberToCallButton.setTitle("Gọi cho: \(member.callName)", for: .normal)
            phoneTextFieldDidChange()
        } else {
            selectedMember = member
            selectMemberButton.setTitle("Đã chọn: \(member.callName)", for: .normal)
        }
    }
}

// MARK: - VBotPhoneDelegate

extension ViewController: VBotPhoneDelegate {
    func callStateChanged(state: VBotCallState) {
        // Handle call state changed if needed
    }
    
    func callAccepted() {
        // Handle call accepted
    }
    
    func callEnded(reason: VBotEndCallReason) {
        // Handle call ended
    }

    func microphonePermission(status: AVAudioSession.RecordPermission) {
        // Handle mic permission
    }

    func messageButtonTapped() {
        let chatVC = TestViewController()
        chatVC.modalPresentationStyle = .fullScreen
        present(chatVC, animated: true)
    }
}

struct CallSessionRequest: Codable {
    let phone_number: String
}

struct CallSessionResponse: Codable {
    let error: Int
    let message: String?
    let data: CallSessionData?
}

struct CallSessionData: Codable {
    let session_id: String
    let expires_in: Int?
    let created_at: String
}
