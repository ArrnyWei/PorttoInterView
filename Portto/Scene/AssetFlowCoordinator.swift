//
//  AssetFlowCoordinator.swift
//  Portto
//
//  Created by Shih Chi Wei on 2022/4/23.
//

import UIKit

class AssetFlowCoordinator: FlowCoordinator {
    
    override func start() {
    }

    override func next<VC>(from fromVC: UIViewController, to destVC: VC.Type? = nil, bundle: Any? = nil) -> Bool where VC : UIFlowViewController {
        switch destVC {
        case is AssetDetailViewController.Type:
            guard let bundle = bundle as? AssetDecoder.Asset else { return false }
            toDetail(bundle: bundle)
            return true
        default:
            return false
        }
    }

    private func toDetail(bundle: AssetDecoder.Asset) {
        push(type: AssetDetailViewController.self, prepare: { vc in
            let viewModel = AssetDetailViewModel()
            viewModel.asset = bundle
            vc.viewModel = viewModel
        })
    }
}
