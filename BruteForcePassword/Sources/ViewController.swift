//
//  ViewController.swift
//  BruteForcePassword
//
//  Created by Игорь Николаев on 13.02.2023.
//

import UIKit

class ViewController: UIViewController {

    //: MARK: - UI Elements

    private lazy var buttonChangeColor: UIButton = {
        let button = UIButton(configuration: .filled(), primaryAction: nil)
        button.configuration?.title = "Change Color"
        button.configuration?.attributedTitle?.font = UIFont(name: "Futura", size: 15)
        button.configuration?.cornerStyle = .capsule
        button.configuration?.buttonSize = .large
        button.configuration?.baseBackgroundColor = .systemMint
        button.addTarget(self, action: #selector(onBut(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var buttonPassword: UIButton = {
        let button = UIButton(configuration: .filled(), primaryAction: nil)
        button.configuration?.title = "Change Password"
        button.configuration?.attributedTitle?.font = UIFont(name: "Futura", size: 15)
        button.configuration?.cornerStyle = .capsule
        button.configuration?.buttonSize = .large
        button.configuration?.baseBackgroundColor = .systemPink
        button.addTarget(self, action: #selector(bruteForce(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var labelPassword: UILabel = {
        let label = UILabel()
        label.text = "Password"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Futura", size: 45.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var textFieldPassword: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.textAlignment = .center
        textField.backgroundColor = .white
        textField.font = .systemFont(ofSize: 15)
        textField.clipsToBounds = true
        textField.layer.cornerRadius = 25
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .medium
        activityIndicator.color = .systemGreen
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()

    private lazy var stackTop: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 100
        stack.addArrangedSubview(labelPassword)
        stack.addArrangedSubview(textFieldPassword)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var stackLow: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 15
        stack.addArrangedSubview(buttonChangeColor)
        stack.addArrangedSubview(buttonPassword)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var stackGeneral: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 150
        stack.addArrangedSubview(stackTop)
        stack.addArrangedSubview(stackLow)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    //: MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        viewColor()
        setupHierarchy()
        setupLayout()
    }

    //MARK: - Actions

    var isBlack = false {
        didSet {
            if isBlack {
                self.view.backgroundColor = .systemIndigo
            } else {
                self.view.backgroundColor = .systemYellow
            }
        }
    }

    @objc func onBut(_ sender: Any) {
        isBlack.toggle()
    }

    @objc func bruteForce(_ sender: Any) {
        self.bruteForce(passwordToUnlock: "1!gr")
    }

    //: MARK: - Setups

    func viewColor() {
        view.backgroundColor = .systemYellow
    }

    private func setupHierarchy() {
        view.addSubview(stackGeneral)
        textFieldPassword.addSubview(activityIndicator)

    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            stackGeneral.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackGeneral.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackGeneral.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            stackGeneral.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),

            activityIndicator.centerYAnchor.constraint(equalTo: textFieldPassword.centerYAnchor),
            activityIndicator.rightAnchor.constraint(equalTo: textFieldPassword.rightAnchor, constant: -20),

        ])
    }
}

extension ViewController {

    func bruteForce(passwordToUnlock: String) {
        let allowedCharacters: [String] = String().printable.map { String($0) }

        var password: String = ""

        // Will strangely ends at 0000 instead of ~~~
        while password != passwordToUnlock { // Increase MAXIMUM_PASSWORD_SIZE value for more
            password = generateBruteForce(password, fromArray: allowedCharacters)
            //             Your stuff here
            print(password)
            // Your stuff here
        }
        print(password)
    }

    func indexOf(character: Character, _ array: [String]) -> Int {
        return array.firstIndex(of: String(character))!
    }

    func characterAt(index: Int, _ array: [String]) -> Character {
        return index < array.count ? Character(array[index]) : Character("")
    }

    func generateBruteForce(_ string: String, fromArray array: [String]) -> String {
        var str: String = string

        if str.count <= 0 {
            str.append(characterAt(index: 0, array))
        } else {
            str.replace(at: str.count - 1,
                        with: characterAt(index: (indexOf(character: str.last!, array) + 1) % array.count, array))
            if indexOf(character: str.last!, array) == 0 {
                str = String(generateBruteForce(String(str.dropLast()), fromArray: array)) + String(str.last!)
            }
        }
        return str
    }
}

extension String {
    var digits: String { return "0123456789" }
    var lowercase: String { return "abcdefghijklmnopqrstuvwxyz" }
    var uppercase: String { return "ABCDEFGHIJKLMNOPQRSTUVWXYZ" }
    var punctuation: String { return "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~" }
    var letters: String { return lowercase + uppercase }
    var printable: String { return digits + letters + punctuation }

    mutating func replace(at index: Int, with character: Character) {
        var stringArray = Array(self)
        stringArray[index] = character
        self = String(stringArray)
    }
}
