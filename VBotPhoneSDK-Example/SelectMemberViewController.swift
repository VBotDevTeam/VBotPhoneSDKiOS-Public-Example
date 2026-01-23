//
//  SelectMemberViewController.swift
//  VBotPhoneSDK_Example
//
//  Created by VPMedia on 31/7/25.
//

import UIKit

@MainActor
protocol SelectMemberVCDelegate: AnyObject {
    func didSelectMember(_ member: User)
}

protocol UserCellDelegate: AnyObject {
    func didTapEdit(at indexPath: IndexPath)
    func didTapDelete(at indexPath: IndexPath)
}

class SelectMemberViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UserCellDelegate {
    // MARK: - Properties
    private let tableView = UITableView()
    private weak var delegate: SelectMemberVCDelegate?
    private var users: [User] = []

    // MARK: - Initializer
    init(delegate: SelectMemberVCDelegate?) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        users = getUserList()
        setupView()
        setupTableView()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        users = getUserList()
        tableView.reloadData()
    }

    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = .white
        title = "Chọn tài khoản"
    }
    
    private func setupNavigationBar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
    }
    
    @objc private func addButtonTapped() {
        let alert = UIAlertController(title: "Thêm người dùng", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Tên người dùng"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Token"
        }
        
        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))
        alert.addAction(UIAlertAction(title: "Lưu", style: .default) { [weak self] _ in
            guard let nameField = alert.textFields?[0],
                  let tokenField = alert.textFields?[1],
                  let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  let token = tokenField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !name.isEmpty, !token.isEmpty else {
                return
            }
            
            let newUser = User(name: name, token: token)
            saveUser(newUser)
            self?.users = getUserList()
            self?.tableView.reloadData()
        })
        
        present(alert, animated: true)
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: "UserCell")
        tableView.rowHeight = 60
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserTableViewCell
        cell.configure(with: users[indexPath.row], indexPath: indexPath, delegate: self)
        cell.selectionStyle = .none
        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let delegate = delegate {
            delegate.didSelectMember(users[indexPath.row])
        }
        dismiss(animated: true)
    }
    
    // MARK: - UserCellDelegate
    func didTapEdit(at indexPath: IndexPath) {
        handleEditUser(at: indexPath)
    }
    
    func didTapDelete(at indexPath: IndexPath) {
        handleDeleteUser(at: indexPath)
    }
    
    // MARK: - Actions
    private func handleDeleteUser(at indexPath: IndexPath) {
        let user = users[indexPath.row]
        let alert = UIAlertController(title: "Xác nhận", message: "Bạn có chắc muốn xóa '\(user.name)'?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))
        alert.addAction(UIAlertAction(title: "Xóa", style: .destructive) { [weak self] _ in
            VBotPhoneSDK_Example.deleteUser(user)
            self?.users.remove(at: indexPath.row)
            self?.tableView.deleteRows(at: [indexPath], with: .automatic)
        })
        present(alert, animated: true)
    }
    
    private func handleEditUser(at indexPath: IndexPath) {
        let user = users[indexPath.row]
        let alert = UIAlertController(title: "Sửa người dùng", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Tên người dùng"
            textField.text = user.name
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Token"
            textField.text = user.token
        }
        
        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))
        alert.addAction(UIAlertAction(title: "Lưu", style: .default) { [weak self] _ in
            guard let nameField = alert.textFields?[0],
                  let tokenField = alert.textFields?[1],
                  let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  let token = tokenField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !name.isEmpty, !token.isEmpty else {
                return
            }
            
            let updatedUser = User(name: name, token: token)
            VBotPhoneSDK_Example.deleteUser(user)
            saveUser(updatedUser)
            self?.users = getUserList()
            self?.tableView.reloadData()
        })
        
        present(alert, animated: true)
    }
}

// MARK: - UserTableViewCell
class UserTableViewCell: UITableViewCell {
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sửa", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 6
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Xóa", for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 6
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private weak var delegate: UserCellDelegate?
    private var indexPath: IndexPath?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(editButton)
        contentView.addSubview(deleteButton)
        
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 50),
            deleteButton.heightAnchor.constraint(equalToConstant: 32),
            
            editButton.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -8),
            editButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            editButton.widthAnchor.constraint(equalToConstant: 50),
            editButton.heightAnchor.constraint(equalToConstant: 32),
            
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: editButton.leadingAnchor, constant: -8)
        ])
    }
    
    func configure(with user: User, indexPath: IndexPath, delegate: UserCellDelegate) {
        nameLabel.text = user.name
        self.indexPath = indexPath
        self.delegate = delegate
    }
    
    @objc private func editButtonTapped() {
        guard let indexPath = indexPath else { return }
        delegate?.didTapEdit(at: indexPath)
    }
    
    @objc private func deleteButtonTapped() {
        guard let indexPath = indexPath else { return }
        delegate?.didTapDelete(at: indexPath)
    }
}
