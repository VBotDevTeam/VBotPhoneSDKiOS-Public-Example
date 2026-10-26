//
//  TestViewController.swift
//  VBotPhoneSDK_Example
//
//  Created by VPMedia on 31/7/25.
//

import UIKit
import VBotPhoneSDK

class TestViewController: UIViewController {

    private lazy var showBackButton = createButton(
        title: "Back",
        backgroundColor: .gray,
        action: #selector(backButton_tapped)
    )
    
    private lazy var returnToCallVCButton = createButton(
        title: "Return to Call VC",
        backgroundColor: .systemMintCompat,
        action: #selector(returnCallVCButton_tapped)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(containerStackView)
        
        var items = [returnToCallVCButton, showBackButton]
        
        items.forEach { containerStackView.addArrangedSubview($0) }
        
        NSLayoutConstraint.activate([
            containerStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            containerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            showBackButton.heightAnchor.constraint(equalToConstant: 44),
            
        ])
    }
    
    
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
    
    @objc private func backButton_tapped() {
        dismiss(animated: true)
    }
    
    @objc private func returnCallVCButton_tapped() {
        VBotPhone.sharedInstance.returnToCallVCIfNeeded()
    }
    

}
