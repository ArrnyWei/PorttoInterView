//
//  FlowCoordinator.swift
//  Ecogenie3
//
//  Created by Enoch Wu on 2020/06/12.
//  Copyright © 2020 NextDrive. All rights reserved.
//

import UIKit
protocol ExtendedViewControllerLifeCycle {
    func viewWillBack(from controller: UIViewController)
}
open class FlowCoordinator: NSObject {
    public var presentedViewController: UIViewController {
        var prensetedVC = entryViewController
        while prensetedVC.presentedViewController != nil {
            prensetedVC = prensetedVC.presentedViewController!
        }
        return prensetedVC
    }
    public weak var currViewController: UIViewController?
    public unowned var entryViewController: UIViewController

    public init(entryViewController: UIViewController) {

        self.entryViewController = entryViewController
        super.init()
        if let flowVC = entryViewController as? UIFlowViewController {
            flowVC.coordinator = self
        }
        self.currViewController = entryViewController
    }

    open func start() {}

    open func exit() {
        ensureInMainQueue {
            self.entryViewController.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }

    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        ensureInMainQueue { [weak self] in
            guard let _self = self else { return }
            _self.entryViewController.dismiss(animated: animated, completion: completion)
            if
                let extendedVC = _self.entryViewController as? ExtendedViewControllerLifeCycle,
                let lastVC = _self.entryViewController.navigationController?.children.last
            {
                extendedVC.viewWillBack(from: lastVC)
            }
        }
    }
    func generate<VC: UIViewController>(type: VC.Type, prepare: ((VC) -> Void)? = nil) -> (VC) {
       let vc = VC(nibName: "\(VC.self)", bundle: .main)

        (vc as? UIFlowViewController)?.coordinator = self
        prepare?(vc)
        return (vc)

    }

    func generateNavigational<VC: UIViewController>(type: VC.Type, prepare: ((VC) -> Void)? = nil, customize: ((UINavigationItem) -> Void)? = nil) -> (VC, UINavigationController) {

        let vc = VC(nibName: "\(VC.self)", bundle: .main)
        (vc as? UIFlowViewController)?.coordinator = self
        let navi = self.navigational(vc, customize: customize)

        prepare?(vc)
        return (vc, navi)
    }

    @discardableResult func next<VC: UIFlowViewController>(from fromVC: UIViewController, to destVC: VC.Type? = nil, bundle: Any? = nil) -> Bool { return false }

    func present<VC: UIFlowViewController>(on targetVC: UIViewController? = nil, type: VC.Type, animated: Bool = true, presentationStyle: UIModalPresentationStyle = .fullScreen, prepare: ((VC) -> Void)? = nil, navigational: Bool = false, customize: ((UINavigationItem) -> Void)? = nil, completion: ((VC) -> Void)? = nil ) {

        ensureInMainQueue {
            var wrappedVC: UIViewController!
            var rawVC: VC!
            if navigational {
                let (vc, navi) = self.generateNavigational(type: type, prepare: prepare, customize: customize)
                rawVC = vc
                wrappedVC = navi
            } else {
                let (vc) = self.generate(type: type, prepare: prepare)
                rawVC = vc
                wrappedVC = rawVC
            }

            wrappedVC.modalPresentationStyle = presentationStyle
            wrappedVC.modalTransitionStyle = .coverVertical
            let targetVC = targetVC ?? self.presentedViewController

            self.traceRootVC(targetVC)
                .present(wrappedVC,
                         animated: animated,
                         completion: { completion?(rawVC) })
        }
    }

    func push<VC: UIFlowViewController>(type: VC.Type, animated: Bool = true, prepare: ((VC) -> Void)? = nil, completion: ((VC) -> Void)? = nil ) {
        ensureInMainQueue { [unowned self] in
            let (vc) = self.generate(type: type, prepare: prepare)
            var naviVC: UINavigationController?

            if let parentNavi = presentedViewController as? UINavigationController {
                naviVC = parentNavi
            } else if let parentNavi = presentedViewController.navigationController {
                naviVC = parentNavi
            } else if entryViewController is UINavigationController {
                naviVC = entryViewController as? UINavigationController
            } else if let _navi = entryViewController.navigationController {
                naviVC = _navi
            }

            if naviVC != nil {
                self.currViewController = vc
                naviVC?.pushViewController(vc, animated: true)
                completion?(vc)
            }
        }
    }

    func back(repeat: Int = 1, animated: Bool = true) {
        if `repeat` == 0 { return }

        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            self?.back(repeat: `repeat` - 1, animated: animated)
        }
        self.entryViewController.navigationController?.popViewController(animated: (`repeat` == 1) ? animated : false )
        if
            let extendedVC = entryViewController as? ExtendedViewControllerLifeCycle,
            let lastVC = entryViewController.navigationController?.children.last
        {
            extendedVC.viewWillBack(from: lastVC)
        }
        CATransaction.commit()
    }

    func reset(callback: @escaping (() -> Void)) {
        func popToRoot() {
            if entryViewController.navigationController?.children.last == entryViewController {
                return
            }
            entryViewController.navigationController?.popToViewController(entryViewController, animated: true)
            if
                let extendedVC = entryViewController as? ExtendedViewControllerLifeCycle,
                let lastVC = entryViewController.navigationController?.children.last
            {
                extendedVC.viewWillBack(from: lastVC)
            }
        }
        if let presentedVC = entryViewController.presentedViewController {
            presentedVC.dismiss(animated: false, completion: {
                popToRoot()
                callback()
            })
        } else {
            popToRoot()
            callback()
        }
    }

    public func resetNavi(viewController: UIViewController) {
        var currVC: UIViewController? = viewController
        var hasNext = true
        while hasNext {
            currVC = currVC?.navigationController?.popViewController(animated: false)
            if currVC == nil { hasNext = false }
        }
    }

    public func navigational(_ vc: UIViewController, customize: ((UINavigationItem) -> Void)? = nil ) -> UINavigationController {
        let navi = UINavigationController(rootViewController: vc)
        // navi.modalPresentationStyle = .fullScreen
        // navi.modalTransitionStyle = .coverVertical
        customize?(vc.navigationItem)
        return navi
    }

    private func traceRootVC(_ currentViewController: UIViewController) -> UIViewController {
        if currentViewController.parent != nil {
            return traceRootVC(currentViewController.parent!)
        } else {
            return currentViewController
        }
    }

    private func ensureInMainQueue(_ block: @escaping () -> Void) {
        if Thread.isMainThread { block() } else {
            DispatchQueue.main.async { block() }
        }
    }
}
