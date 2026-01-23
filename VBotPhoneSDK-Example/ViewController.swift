//
//  ViewController.swift
//  VBotPhoneSDK-Example
//
//  Created by DAT NGUYEN QUOC on 22/1/26.
//

import UIKit
import VBotPhoneSDK
import AVFAudio

class ViewController: UIViewController {
    // MARK: - UI Components

    private lazy var selectMemberButton = createButton(
        title: "Chọn tài khoản",
        backgroundColor: UIColor.systemMint,
        action: #selector(go_selectMember)
    )
    
    private lazy var disconnectButton = createButton(
        title: "Ngắt kết nối",
        backgroundColor: .systemRed,
        action: #selector(disconnectButton_tapped)
    )
    
    private lazy var accountLabel = createLabel(
        text: "Chưa chọn tài khoản",
        textColor: .red
    )
    
    
    private let phoneTf: UITextField = {
        let tf = UITextField()
        tf.clearButtonMode = .always
        tf.keyboardType = .numberPad
        tf.borderStyle = .roundedRect  // <-- thêm dòng này
        tf.placeholder = "Nhập số điện thoại"
        return tf
    }()
    
    private lazy var callButton = createButton(
        title: "Gọi",
        backgroundColor: UIColor.systemMint,
        action: #selector(callButton_tapped)
    )
    
    private lazy var selectHotlineButton = createButton(
        title: "Chọn Hotline",
        backgroundColor: .systemPurple,
        action: #selector(selectHotlineButton_tapped)
    )
    
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
    private var selectedUser: User?
    private var selectedHotline: VBotHotline?
    var callViewController: CallViewController?
    var lastDialedNumber: String?
    var lastDialedHotline: String?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        hideKeyboardWhenTappedAround()
        setupView()
        
        // Thêm target để lắng nghe thay đổi text trong phoneTf
        phoneTf.addTarget(self, action: #selector(phoneTextFieldDidChange), for: .editingChanged)
        phoneTf.delegate = self
        
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

        [accountLabel, selectMemberButton, disconnectButton, phoneTf, callButton, selectHotlineButton]
            .forEach { containerStackView.addArrangedSubview($0) }

        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            containerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            disconnectButton.heightAnchor.constraint(equalToConstant: 44),
            accountLabel.heightAnchor.constraint(equalToConstant: 44),
            selectHotlineButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupView() {
        if let loadedUser = UserDefaults.sdkMemberUser {
            setupViewForLoggedInUser(loadedUser)
        } else {
            setupViewForLoggedOutUser()
        }
    }
    
    private func setupViewForLoggedInUser(_ user: User) {
        selectedUser = user
        disconnectButton.isEnabled = true
        disconnectButton.isHidden = false
        accountLabel.isHidden = false
        
        let attributedText = NSMutableAttributedString(
            string: "Đã kết nối: ",
            attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .regular), .foregroundColor: UIColor.black]
        )
        attributedText.append(NSAttributedString(
            string: user.name,
            attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: UIColor.systemTeal]
        ))
        accountLabel.attributedText = attributedText
        
        selectMemberButton.setTitle("Đã chọn: \(user.name)", for: .normal)
        selectMemberButton.isEnabled = false
        phoneTextFieldDidChange()
    }

    private func setupViewForLoggedOutUser() {
        selectedUser = nil
        disconnectButton.isEnabled = false
        disconnectButton.isHidden = true
        accountLabel.text = "Chưa chọn tài khoản"
        accountLabel.textColor = .red
        selectMemberButton.setTitle("Chọn tài khoản", for: .normal)
        selectMemberButton.isEnabled = true
        phoneTextFieldDidChange()
    }

    // MARK: - Actions

    @objc private func go_selectMember() {
        presentSelectMemberViewController()
    }
    
    
    @objc private func disconnectButton_tapped() {
        deleteCurrentUser()
    }
    
    @objc private func callButton_tapped() {
        let phone = phoneTf.text ?? ""
        guard !phone.isEmpty else {
            showAlert(title: "Lưu ý", message: "Vui lòng nhập số điện thoại")
            return
        }
        if phone.count > 5 && selectedHotline == nil {
            showAlert(title: "Lưu ý", message: "Vui lòng chọn hotline")
            return
        }
        let hotline = phone.count > 5 ? (selectedHotline?.phoneNumber ?? "") : ""
        lastDialedNumber = phone
        lastDialedHotline = hotline
        makeCall(phonenumber: phone, hotline: hotline)
    }
    
    @objc private func phoneTextFieldDidChange() {
        let phoneNumber = phoneTf.text ?? ""
        callButton.isEnabled = !phoneNumber.isEmpty
    }
    
    @objc private func selectHotlineButton_tapped() {
        showProgress()
        VBotPhone.sharedInstance.getHotlines { [weak self] hotlines, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.hideProgress()
                if let error = error as NSError? {
                    self.showError(code: error.code, message: error.localizedDescription)
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
        let title = selectedHotline.map { "Hotline: \($0.name) (\($0.phoneNumber))" } ?? "Chọn Hotline"
        selectHotlineButton.setTitle(title, for: .normal)
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
    
    func presentCallVCIfNeeded() {
        if let presented = callViewController, presented.presentingViewController != nil { return }
        let vc = CallViewController(number: lastDialedNumber, hotline: lastDialedHotline)
        vc.modalPresentationStyle = .fullScreen
        vc.onEndCall = { vc.dismiss(animated: true) }
        callViewController = vc
        present(vc, animated: true)
    }
    
    private func presentSelectMemberViewController() {
        let vc = SelectMemberViewController(delegate: self)
        present(vc.wrapToNavigationController(), animated: true)
    }
    
    private func saveCurrentUser(_ user: User) {
        showProgress()
        let pushKitToken = getPushToken() ?? ""
        VBotPhone.sharedInstance.connect(token: user.token, pushkitToken: pushKitToken) { [weak self] name, error in
            guard let self = self else { return }
            if let error = error as NSError? {
                self.showError(code: error.code, message: error.localizedDescription)
                self.hideProgress()
                return
            }
            UserDefaults.sdkMemberUser = user
            self.hideProgress()
            self.setupViewForLoggedInUser(user)
        }
    }

    private func deleteCurrentUser() {
        showProgress()
        VBotPhone.sharedInstance.disconnect { [weak self] error in
            guard let self = self else { return }
            self.hideProgress()
            if let error = error as NSError? {
                self.showError(code: error.code, message: error.localizedDescription)
                return
            }
            UserDefaults.removeSDKMemberUser()
            self.setupViewForLoggedOutUser()
        }
    }

    private func makeCall(phonenumber: String, hotline: String) {
        callButton.isEnabled = false
        client.startOutgoingCall(displayName: phonenumber, number: phonenumber, hotline: hotline) { [weak self] success, error in
            guard let self = self else { return }
            DispatchQueue.main.async { self.callButton.isEnabled = true }
            if !success, let error = error as NSError? {
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
                    self.showError(code: error.code, message: error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - SelectMemberVCDelegate

extension ViewController: SelectMemberVCDelegate {
    
    func didSelectMember(_ user: User) {
        saveCurrentUser(user)
    }
}
