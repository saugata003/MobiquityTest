//
//  UIViewController+Additions.swift
//  IMM-iOS
//
//  Created by Saugata Chakraborty on 2/14/17.
//  Copyright © 2017 OIT. All rights reserved.
//

import UIKit
import MBProgressHUD
import Alamofire
extension UIViewController {
    func noInternetConnectionError() {
        if !(NetworkReachabilityManager()?.isReachable)! {
            let alertController = UIAlertController(title: BLANK_STRING, message: ErrorCodes[NO_INTERNET_ERROR_CODE]!, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
                exit(0)})
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    func isDeviceTokenPresent() -> Bool {
        if KeyChainDB.fetch(keyName: FIRE_BASE_TOKEN_KEY, type: KeyChainItem.self)?.value != nil {
            return true
        } else {
//            let alertController = UIAlertController(title: BLANK_STRING, message: ErrorCodes[BLANK_DEVICE_TOKEN_ERROR_CODE]!, preferredStyle: .alert)
//            let OKAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
//                exit(0)})
//            alertController.addAction(OKAction)
//            self.present(alertController, animated: true, completion: nil)
//            return false
            return false
        }
    }
    func alert(message: String, title: String = BLANK_STRING, completion: (() -> Swift.Void)? = nil) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: completion)
        }
    }

    func update(message: String, title: String = BLANK_STRING, completion: (() -> Swift.Void)? = nil) {
        DispatchQueue.main.async {
            let updateTitle = "Update Available"
            let alertController = UIAlertController(title: updateTitle, message: message, preferredStyle: .alert)
            let UpdateAction = UIAlertAction(title: "Update Now!", style: .default, handler: {(_ action: UIAlertAction) -> Void in
                if let url = URL(string: AppstroreLink),
                    UIApplication.shared.canOpenURL(url) {
                    self.removeAllUserdefault()
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            })
            alertController.addAction(UpdateAction)
            self.present(alertController, animated: true, completion: completion)
        }
    }

    func showProgressHUD(_ currentView: UIView? = nil, _ message: String = BLANK_STRING) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            DispatchQueue.main.async {
                MBProgressHUD.showAdded(to: self.view, animated: true)
                // This Code will be needed in future
//                let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                MBProgressHUD.showAdded(to: (appDelegate.window!.rootViewController?.view)!, animated: true)
            }
        }
    }

    func hideProgressHUD(_ currentView: UIView? = nil) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                // This Code will be needed in future
//                let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                MBProgressHUD.hide(for: (appDelegate.window!.rootViewController?.view)!, animated: true)
            }
        }
    }

    func showProgressHUDInView(_ currentView: UIView? = nil, _ message: String = BLANK_STRING) {
        var displayOnView = currentView
        if displayOnView == nil {
            displayOnView = self.view
        }
        let hud = MBProgressHUD.showAdded(to: displayOnView!, animated: true)
        hud.label.text = message
        hud.isUserInteractionEnabled = false
    }

    func hideProgressHUDInView(_ currentView: UIView? = nil) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            DispatchQueue.main.async {
                var displayOnView = currentView
                if displayOnView == nil {
                    displayOnView = self.view
                }
                MBProgressHUD.hide(for: displayOnView!, animated: true)
            }
        }
    }
    // This method may be used in future
//    pop back n viewcontroller
//    func popBackController(_ controller: Int) {
//        if let viewControllers: [UIViewController] = self.navigationController?.viewControllers {
//            guard viewControllers.count < controller else {
//                self.navigationController?.popToViewController(viewControllers[viewControllers.count - controller], animated: true)
//                return
//            }
//        }
//    }

    func popToLoginPage() {
        if self.revealViewController() != nil {
            KeyChainDB.removeFromKeychain(keyName: "DateOfJoining")
            if let revealVC = self.revealViewController() {
                let nc = revealVC.rearViewController as? UINavigationController
                let frontNVC = (nc?.topViewController as? SidebarMenuViewController)?.frontNVC
                if frontNVC?.viewControllers.last is DashboardViewController || frontNVC?.viewControllers.last is BorrowerListViewController || frontNVC?.viewControllers.last is SignupPaymentViewController {
                    return
                } else {
                    _ = frontNVC?.popToRootViewController(animated: true)
                }
            }
        } else {
            if let viewControllers: [UIViewController] = self.navigationController?.viewControllers {
                if !viewControllers.isEmpty {
                    DispatchQueue.main.async {
                        if KeyChainDB.fetch(keyName: "sessionToken", type: KeyChainItem.self) == nil {
                            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                                return
                            }
                            appDelegate.didLogout = true
                            self.removeAllUserdefault()
                            self.navigationController?.popToRootViewController(animated: true)
                        } else if !(viewControllers[viewControllers.count-numberOfViewControllerToBePopped] is LoginViewController) && !(viewControllers[viewControllers.count-numberOfViewControllerToBePopped] is IntroductionViewController) && !(viewControllers[viewControllers.count-numberOfViewControllerToBePopped] is SignupPaymentViewController) && !(viewControllers[viewControllers.count-numberOfViewControllerToBePopped] is SignupOTPViewController) && !(viewControllers.last is SignupPaymentViewController) {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
    }

    func removeAllUserdefault() {
        let userInfo = UserInfo.sharedInstance
        userInfo.borrowerLedgerArray.removeAll()
        userInfo.borrowerInterstStatementArray.removeAll()
        userInfo.borrowerActiveLoansArray.removeAll()
        userInfo.reportSelectedOption = 0
        Utilities.removeAllUserData()
    }

    func logout(_ errorCodeValue: String) {
        if errorCodeValue == INVALID_USER_ERROR_CODE && self.revealViewController() != nil {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            appDelegate.didLogout = true
            removeAllUserdefault()
            DispatchQueue.main.async {
                _ = self.revealViewController().navigationController?.popToRootViewController(animated: true)
                return
            }

        } else if errorCodeValue == INVALID_USER_ERROR_CODE && self.revealViewController() == nil {
            removeAllUserdefault()
            if let viewControllers: [UIViewController] = self.navigationController?.viewControllers {
                if !viewControllers.isEmpty {
                    DispatchQueue.main.async {
                        self.navigationController?.popToRootViewController(animated: true)
                        return
                    }
                }
            }
        }
    }
    func setUpLenderDashboard() {
        if let revealVC = self.revealViewController() {
            popToRootScreen(revealVC)
        } else {
            guard let lenderDashboardNavigationController: UINavigationController = Helpers.storyBoardObject(true).instantiateViewController(withIdentifier: "LenderDashboardNavigationController") as? UINavigationController else { return }
            guard let sidebarMenuViewController: UINavigationController = Helpers.storyBoardObject(true).instantiateViewController(withIdentifier: "SidebarMenuNavigationViewController") as? UINavigationController else { return }
            let swRevealVC = SWRevealViewController.init(rearViewController: sidebarMenuViewController, frontViewController: lenderDashboardNavigationController)
            self.navigationController?.pushViewController(swRevealVC!, animated: true)
        }
    }
    func setUpBorrowerDashboard() {
        if let revealVC = self.revealViewController() {
            popToRootScreen(revealVC)
        } else {
            guard let borrowerDashboardNavigationController: UINavigationController = Helpers.storyBoardObject(true).instantiateViewController(withIdentifier: "BorrowerDashboardNavigationController") as? UINavigationController else { return }
            guard let sidebarMenuViewController: UINavigationController = Helpers.storyBoardObject(true).instantiateViewController(withIdentifier: "SidebarMenuNavigationViewController") as? UINavigationController else { return }
            let swRevealVC = SWRevealViewController.init(rearViewController: sidebarMenuViewController, frontViewController: borrowerDashboardNavigationController)
            self.navigationController?.pushViewController(swRevealVC!, animated: true)
        }
    }
    func setBorrowerFilterScreen() {
        guard let borrowerFilterViewController: UINavigationController = Helpers.storyBoardObject(true).instantiateViewController(withIdentifier: "BorrowerFilterNavigationController") as? UINavigationController else { return }
        guard let sidebarMenuViewController: UINavigationController = Helpers.storyBoardObject(true).instantiateViewController(withIdentifier: "SidebarMenuNavigationViewController") as? UINavigationController else { return }
        let swRevealVC = SWRevealViewController.init(rearViewController: sidebarMenuViewController, frontViewController: borrowerFilterViewController)
        self.navigationController?.pushViewController(swRevealVC!, animated: true)
    }
    func popToRootScreen(_ revealVC: SWRevealViewController) {
        let nc = revealVC.rearViewController as? UINavigationController
        let frontNVC = (nc?.topViewController as? SidebarMenuViewController)?.frontNVC
        _ = frontNVC?.popToRootViewController(animated: true)
    }
}

enum AppStoryboard: String {
    case Main, Dashboard
    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: .main)
    }
    func viewController<T: UIViewController>(controllerClass: T.Type) -> T {
        let storyboardID = controllerClass.storyboardID
        return instance.instantiateViewController(withIdentifier: storyboardID) as! T
    }
}

extension UIViewController {
    class var storyboardID: String {
        return "\(self)"
    }
    static func instantiate(from appStoryboard: AppStoryboard) -> Self {
        return appStoryboard.viewController(controllerClass: self)
    }
}
