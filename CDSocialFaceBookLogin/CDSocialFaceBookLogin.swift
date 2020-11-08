//
//  CDSocialFaceBookLogin.swift
//
//  Created by Shirude Prajakta on 06/11/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit

public protocol CDSocialFaceBookLoginDelegate: class {
    func didSignInToFacebook()
    func didSignOutFromFaceBook()
}

public class CDSocialFaceBookLogin: NSObject {

    static let shared = CDSocialFaceBookLogin()
    weak var delegate: CDSocialFaceBookLoginDelegate?

    private override init(){}

}

extension CDSocialFaceBookLogin {
    public func getFBLoginButton() -> FBButton {
        return FBButton()
    }

    public func getFBUserDataDict() -> Dictionary<String,AnyObject>? {
        if let dict = UserDefaults.standard.object(forKey: "FBUser") as? [String : AnyObject]  {
            return dict
        }
        return nil
    }

}

extension CDSocialFaceBookLogin {
    public func signInToFaceBook() {
       let loginManager = LoginManager()
        loginManager.logIn(permissions: [ .publicProfile ], viewController: nil) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                self.getFBUserData()
            }
        }
    }

    public func getFBUserData(){
        if((AccessToken.current) != nil){
            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    let dict = result as! [String : AnyObject]
                    print(result!)
                    print(dict)
                    UserDefaults.standard.set(dict, forKey: "FBUser")
                    self.delegate?.didSignInToFacebook()
                }
            })
        }
    }

    public func logoutFromFaceBook() {
        LoginManager().logOut()
        UserDefaults.standard.removeObject(forKey: "FBUser")
        self.delegate?.didSignOutFromFaceBook()
    }

}
