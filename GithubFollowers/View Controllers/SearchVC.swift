//
//  SearchVC.swift
//  GithubFollowers
//
//  Created by Chris Song on 2020-01-06.
//  Copyright © 2020 Chris Song. All rights reserved.
//

import UIKit

class SearchVC: UIViewController {
    let logoImageView = UIImageView()
    let usernameTextField = GFTextField()
    let getFollowersButton = GFButton(backgroundColor: .systemGreen, title: "Get Followers")
    let getUserInfoButton = GFButton(backgroundColor: .systemBlue, title: "Get User Info")
    
    private var logoImageViewTopConstraint: NSLayoutConstraint!
    private var logoImageViewHeightConstraint: NSLayoutConstraint!
    
    private var isUsernameEntered: Bool { return !usernameTextField.text!.isEmpty}
    
    private let inset: CGFloat = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubviews(logoImageView, usernameTextField, getFollowersButton, getUserInfoButton)
        configureLogoImageView()
        configureTextField()
        configureButtons()
        createDismissKeyboardTapGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        usernameTextField.text = ""
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func configureLogoImageView() {
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.image = Images.ghLogo
        
        let topConstraintConstant = DeviceTypes.isiPhoneSE || DeviceTypes.isiPhone8Zoomed ? CGFloat(20) : CGFloat(80)
        let heightConstant = DeviceTypes.isiPhoneSE || DeviceTypes.isiPhone8Zoomed ? CGFloat(150) : CGFloat(200)
        
        logoImageViewTopConstraint = logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: topConstraintConstant)
        logoImageViewHeightConstraint = logoImageView.heightAnchor.constraint(equalToConstant: heightConstant)
        
        NSLayoutConstraint.activate([
            logoImageViewTopConstraint,
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageViewHeightConstraint,
            logoImageView.widthAnchor.constraint(equalTo: logoImageView.heightAnchor, multiplier: 1)
        ])
    }
    
    private func configureTextField() {
        usernameTextField.delegate = self
        
        NSLayoutConstraint.activate([
            usernameTextField.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: inset),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset),
            usernameTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureButtons() {
        getFollowersButton.addTarget(self, action: #selector(pushFollowerListVC), for: .touchUpInside)
        getUserInfoButton.addTarget(self, action: #selector(pushUserInfoVC), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            getUserInfoButton.bottomAnchor.constraint(equalTo: getFollowersButton.topAnchor, constant: -20),
            getUserInfoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset),
            getUserInfoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset),
            getUserInfoButton.heightAnchor.constraint(equalToConstant: inset),
            
            getFollowersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -inset),
            getFollowersButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset),
            getFollowersButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset),
            getFollowersButton.heightAnchor.constraint(equalToConstant: inset)
        ])
    }
    
    private func createDismissKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    @objc func pushUserInfoVC() {
        guard isUsernameEntered else {
            presentGFAlertOnMainThread(title: GFError.noUserNameEntered.rawValue, message: "Please try again with a username", buttonTitle: "OK")
            return
        }
        guard let username = usernameTextField.text else { return }
        let user = Follower(login: username, avatarUrl: "")
        let userInfoVC = UserInfoVC(follower: user, isFromHome: true)
        navigationController?.pushViewController(userInfoVC, animated: true)
    }
    
    @objc func pushFollowerListVC() {
        guard isUsernameEntered else {
            presentGFAlertOnMainThread(title: GFError.noUserNameEntered.rawValue, message: "Please try again with a username", buttonTitle: "OK")
            return
        }
        
        guard let username = usernameTextField.text else { return }
        let followerListVC = FollowerListVC(username: username)
        
        NetworkManager.shared.getUserInfo(for: username) { result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    if CoreDataManager.shared.checkForRedudantUser(username: user.login) == false {
                        CoreDataManager.shared.saveToUser(user: user)
                    } else {
                        return
                    }
                }
            case .failure(let error):
                self.presentGFAlertOnMainThread(title: "Something bad happened while saving user information", message: error.rawValue, buttonTitle: "Hmm OK")
            }
        }

        navigationController?.pushViewController(followerListVC, animated: true)
    }
}

extension SearchVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        pushFollowerListVC()
        textField.resignFirstResponder()
        return true
    }
}
