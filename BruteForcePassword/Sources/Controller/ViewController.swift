//
//  ViewController.swift
//  BruteForcePassword
//
//  Created by Игорь Николаев on 13.02.2023.
//

import UIKit
import Foundation

class ViewController: UIViewController {

    //: MARK: - UI Elements

    private lazy var buttonChangeColor: UIButton = {
        let button = UIButton(configuration: .filled(), primaryAction: nil)
        button.configuration?.title = "Color"
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
        button.configuration?.title = "Start/pause"
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
        label.font = UIFont(name: "Futura", size: 35.0)
        label.numberOfLines = 2
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
        textField.layer.cornerRadius = 15
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .medium
        activityIndicator.color = .systemGreen
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

    var isColor = false {
        didSet {
            self.view.backgroundColor = isColor ? .systemIndigo : .systemYellow
        }
    }

    var isStop = false {
        didSet {
            if isStop {
                self.bruteForce(passwordToUnlock: textFieldPassword.text ?? "")
                self.activityIndicator.startAnimating()
            }
        }
    }

    @objc func onBut(_ sender: Any) {
        isColor.toggle()
    }

    @objc func bruteForce(_ sender: Any) {
        isStop.toggle()
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

//MARK: - Extension

extension ViewController {

    func bruteForce(passwordToUnlock: String) {
        let queue = DispatchQueue(label: "queue", qos: .utility, attributes: .concurrent)

        queue.async {
            var password = ""
            let allowedCharacters: [String] = String().printable.map { String($0) }
            while password != passwordToUnlock && self.isStop {
                password = self.generateBruteForce(password, fromArray: allowedCharacters)
                DispatchQueue.main.async { [self] in
                    labelPassword.text = password
                }
            }
            DispatchQueue.main.async { [self] in
                activityIndicator.stopAnimating()
                textFieldPassword.text = password
                textFieldPassword.isSecureTextEntry = false
                if !isStop {
                    labelPassword.text = "\(password) остановлен"
                    secureTextEntry()
                } else {
                    labelPassword.text = "\(password)\n не взломан."
                    secureTextEntry()
                }
            }
        }
    }

    func secureTextEntry() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.textFieldPassword.isSecureTextEntry = true
        }
    }

    func indexOf(character: Character, _ array: [String]) -> Int {
        return array.firstIndex(of: String(character)) ?? 0
    }

    func characterAt(index: Int, _ array: [String]) -> Character {
        return index < array.count ? Character(array[index]) : Character("")
    }

    func generateBruteForce(_ string: String, fromArray array: [String]) -> String {
        var generate = string
        if generate.count <= 0 {
            generate.append(characterAt(index: 0, array))
        } else {
            generate.replace(at: generate.count - 1,
                             with: characterAt(index: (indexOf(character: generate.last ?? " ", array) + 1) % array.count, array))
            if indexOf(character: generate.last ?? " ", array) == 0 {
                generate = String(generateBruteForce(String(generate.dropLast()), fromArray: array)) + String(generate.last ?? " ")
            }
        }
        return generate
    }
}
