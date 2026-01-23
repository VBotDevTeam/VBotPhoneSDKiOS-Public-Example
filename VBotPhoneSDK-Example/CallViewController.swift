//
//  CallViewController.swift
//  VBotPhoneSDK-Example
//
//  Created by Copilot on 23/1/26.
//

import UIKit
import VBotPhoneSDK

final class CallViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let avatarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 50
        return view
    }()
    
    private let avatarLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 36, weight: .medium)
        label.textColor = .systemGray
        label.textAlignment = .center
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 28, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .label
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    private let hotlineLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let stateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.textColor = .systemBlue
        label.text = "Đang gọi..."
        return label
    }()
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .monospacedDigitSystemFont(ofSize: 18, weight: .regular)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.text = "00:00"
        label.isHidden = true
        return label
    }()
    
    private lazy var muteButton: UIButton = {
        let button = createCircleButton(icon: "mic.fill")
        button.addTarget(self, action: #selector(toggleMute), for: .touchUpInside)
        return button
    }()
    
    private lazy var muteLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Tắt tiếng"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private lazy var speakerButton: UIButton = {
        let button = createCircleButton(icon: "speaker.wave.2.fill")
        button.addTarget(self, action: #selector(toggleSpeaker), for: .touchUpInside)
        return button
    }()
    
    private lazy var speakerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Loa ngoài"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private lazy var endButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemRed
        button.setImage(
            UIImage(systemName: "phone.down.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)),
            for: .normal
        )
        button.tintColor = .white
        button.layer.cornerRadius = 32
        button.addTarget(self, action: #selector(endTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var endLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Kết thúc"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemRed
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - State
    
    private var number: String?
    private var hotline: String?
    private var callTimer: Timer?
    private var elapsed: TimeInterval = 0
    private let client = VBotPhone.sharedInstance
    var onEndCall: (() -> Void)?
    
    // MARK: - Init
    
    init(number: String?, hotline: String?) {
        self.number = number
        self.hotline = hotline
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        applyContent()
        syncSDKState()
    }
    
    deinit {
        callTimer?.invalidate()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        // Top section - Avatar & Info
        let infoStack = UIStackView(arrangedSubviews: [nameLabel, hotlineLabel, stateLabel, timerLabel])
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        infoStack.axis = .vertical
        infoStack.spacing = 8
        infoStack.alignment = .center
        
        // Mute button stack (button + label)
        let muteStack = UIStackView(arrangedSubviews: [muteButton, muteLabel])
        muteStack.translatesAutoresizingMaskIntoConstraints = false
        muteStack.axis = .vertical
        muteStack.spacing = 8
        muteStack.alignment = .center
        
        // Speaker button stack (button + label)
        let speakerStack = UIStackView(arrangedSubviews: [speakerButton, speakerLabel])
        speakerStack.translatesAutoresizingMaskIntoConstraints = false
        speakerStack.axis = .vertical
        speakerStack.spacing = 8
        speakerStack.alignment = .center
        
        // Action buttons row
        let actionsStack = UIStackView(arrangedSubviews: [muteStack, speakerStack])
        actionsStack.translatesAutoresizingMaskIntoConstraints = false
        actionsStack.axis = .horizontal
        actionsStack.spacing = 60
        actionsStack.alignment = .center
        actionsStack.distribution = .equalCentering
        
        // End button stack (button + label)
        let endStack = UIStackView(arrangedSubviews: [endButton, endLabel])
        endStack.translatesAutoresizingMaskIntoConstraints = false
        endStack.axis = .vertical
        endStack.spacing = 8
        endStack.alignment = .center
        
        // Add subviews
        view.addSubview(avatarView)
        avatarView.addSubview(avatarLabel)
        view.addSubview(infoStack)
        view.addSubview(actionsStack)
        view.addSubview(endStack)
        
        NSLayoutConstraint.activate([
            // Avatar
            avatarView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            avatarView.widthAnchor.constraint(equalToConstant: 100),
            avatarView.heightAnchor.constraint(equalToConstant: 100),
            
            avatarLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            
            // Info stack
            infoStack.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 24),
            infoStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            infoStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            // Action buttons
            actionsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            actionsStack.bottomAnchor.constraint(equalTo: endStack.topAnchor, constant: -40),
            
            muteButton.widthAnchor.constraint(equalToConstant: 64),
            muteButton.heightAnchor.constraint(equalToConstant: 64),
            speakerButton.widthAnchor.constraint(equalToConstant: 64),
            speakerButton.heightAnchor.constraint(equalToConstant: 64),
            
            // End button
            endStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            endStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            endButton.widthAnchor.constraint(equalToConstant: 64),
            endButton.heightAnchor.constraint(equalToConstant: 64)
        ])
    }
    
    private func createCircleButton(icon: String) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemGray6
        button.tintColor = .label
        button.layer.cornerRadius = 32
        button.setImage(
            UIImage(systemName: icon, withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)),
            for: .normal
        )
        return button
    }
    
    private func applyContent() {
        let displayNumber = number?.isEmpty == false ? number! : "Cuộc gọi"
        nameLabel.text = displayNumber
        
        // Set avatar initial
        if let firstChar = displayNumber.first, firstChar.isNumber {
            avatarLabel.text = String(displayNumber.prefix(2))
        } else {
            avatarLabel.text = String(displayNumber.prefix(1)).uppercased()
        }
        
        if let hotline = hotline, !hotline.isEmpty {
            hotlineLabel.text = "Hotline: \(hotline)"
            hotlineLabel.isHidden = false
        } else {
            hotlineLabel.isHidden = true
        }
    }
    
    private func syncSDKState() {
        updateMuteButtonState(client.isCallMute())
        updateSpeakerButtonState(client.isSpeakerOn())
    }
    
    private func updateMuteButtonState(_ isMuted: Bool) {
        let icon = isMuted ? "mic.slash.fill" : "mic.fill"
        muteButton.setImage(
            UIImage(systemName: icon, withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)),
            for: .normal
        )
        muteButton.backgroundColor = isMuted ? .systemGray4 : .systemGray6
        muteButton.tintColor = isMuted ? .white : .label
    }
    
    private func updateSpeakerButtonState(_ isSpeaker: Bool) {
        let icon = isSpeaker ? "speaker.wave.3.fill" : "speaker.wave.2.fill"
        speakerButton.setImage(
            UIImage(systemName: icon, withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)),
            for: .normal
        )
        speakerButton.backgroundColor = isSpeaker ? .systemGray4 : .systemGray6
        speakerButton.tintColor = isSpeaker ? .white : .label
    }
    
    // MARK: - Actions
    
    @objc private func toggleMute() {
        let newState = !client.isCallMute()
        client.muteCall()
        updateMuteButtonState(newState)
    }
    
    @objc private func toggleSpeaker() {
        let newState = !client.isSpeakerOn()
        client.onOffSpeaker()
        updateSpeakerButtonState(newState)
    }
    
    @objc private func endTapped() {
        client.endCall { [weak self] _ in
            DispatchQueue.main.async {
                self?.onEndCall?()
            }
        }
    }
    
    // MARK: - Timer
    
    private func startTimer() {
        callTimer?.invalidate()
        elapsed = 0
        timerLabel.text = "00:00"
        timerLabel.isHidden = false
        callTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.elapsed += 1
            self.timerLabel.text = self.formatTime(self.elapsed)
        }
    }
    
    private func stopTimer() {
        callTimer?.invalidate()
        callTimer = nil
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let total = Int(time)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Public Methods
    
    func updateCallInfo(number: String?, hotline: String?) {
        self.number = number
        self.hotline = hotline
        applyContent()
    }
    
    func syncMuteState(_ isMuted: Bool) {
        updateMuteButtonState(isMuted)
    }
    
    func syncSpeakerState(_ isSpeaker: Bool) {
        updateSpeakerButtonState(isSpeaker)
    }
    
    func didStartOutgoing() {
        stateLabel.text = "Đang gọi..."
        stateLabel.textColor = .systemBlue
        timerLabel.isHidden = true
    }
    
    func didAccept() {
        stateLabel.text = "Đang đàm thoại"
        stateLabel.textColor = .systemGreen
        startTimer()
    }
    
    func didUpdateState(_ state: VBotCallState) {
        switch state {
        case .null:
            stateLabel.text = "Đang khởi tạo..."
            stateLabel.textColor = .secondaryLabel
            
        case .calling:
            stateLabel.text = "Đang gọi..."
            stateLabel.textColor = .systemBlue
            timerLabel.isHidden = true
            
        case .incoming:
            stateLabel.text = "Cuộc gọi đến"
            stateLabel.textColor = .systemOrange
            
        case .early:
            stateLabel.text = "Đang đổ chuông..."
            stateLabel.textColor = .systemBlue
            
        case .connecting:
            stateLabel.text = "Đang kết nối..."
            stateLabel.textColor = .systemBlue
            
        case .confirmed:
            stateLabel.text = "Đang đàm thoại"
            stateLabel.textColor = .systemGreen
            if callTimer == nil {
                startTimer()
            }
            
        case .disconnected:
            stateLabel.text = "Đã ngắt kết nối"
            stateLabel.textColor = .systemRed
            stopTimer()
            
        @unknown default:
            stateLabel.text = state.description
            stateLabel.textColor = .secondaryLabel
        }
    }
    
    func didEnd(reason: VBotEndCallReason) {
        stopTimer()
        stateLabel.text = "Kết thúc"
        stateLabel.textColor = .systemRed
    }
}
