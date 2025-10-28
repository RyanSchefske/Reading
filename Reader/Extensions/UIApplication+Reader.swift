//
//  UIApplication+Reader.swift
//  Reader
//
//  Created by GPT Coding Assistant on 11/3/25.
//

import UIKit

extension UIApplication {

    /// Returns the top-most presented view controller in the key window scene.
    func topViewController(base: UIViewController? = nil) -> UIViewController? {
        let baseController: UIViewController?

        if let base = base {
            baseController = base
        } else {
            baseController = connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first(where: { $0.isKeyWindow })?
                .rootViewController
        }

        guard let controller = baseController else {
            return nil
        }

        if let nav = controller as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }

        if let tab = controller as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }

        if let presented = controller.presentedViewController {
            return topViewController(base: presented)
        }

        return controller
    }
}

