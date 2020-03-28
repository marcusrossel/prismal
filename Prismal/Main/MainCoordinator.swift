//
//  MainCoordinator.swift
//  Prismal
//
//  Created by Marcus Rossel on 16.11.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

final class MainCoordinator: RootCoordinator {
   
   var rootViewController: UIViewController { return navigationController }
   
   private lazy var navigationController = UINavigationController()
   
   private lazy var mainViewController: MainViewController = {
      let controller = MainViewController()
      
      controller.navigationItem.title = "Prismal"
      controller.navigationItem.rightBarButtonItem = UIBarButtonItem(
         title: "Options", style: .plain, target: self, action: #selector(didPressOptionsButton)
      )
      
      return controller
   }()
   
   init() { }
   
   func start() {
      navigationController.setViewControllers([mainViewController], animated: true)
   }
   
   @objc private func didPressOptionsButton() {
      let optionsController = makeOptionsViewController()
      navigationController.pushViewController(optionsController, animated: true)
   }
   
   private func makeOptionsViewController() -> OptionsViewController {
      
   }
}
