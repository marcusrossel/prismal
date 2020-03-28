//
//  Coordinator.swift
//  Prismal
//
//  Created by Marcus Rossel on 16.11.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - Coordinator
/// A coordinator is a type used for navigating between and managing controllers.
protocol Coordinator {
   
   /// A coordinator uses a navigation controller to manage the displaying of content.
   var navigationController: UINavigationController { get }
   
   /// Causes control to be handed over to the coordinator.
   /// Usually this should cause the coordinator to push a basal view controller.
   func run()
}

// MARK: - Root Coordinator
/// A type of coordinator that can provide a view controller that serves as the app's root view
/// controller.
protocol RootCoordinator {
   
   /// The view controller used by the coordinator to manage the displaying of content.
   /// The controller should be suitable to be an app's root view controller.
   var rootViewController: UIViewController { get }
   
   /// Causes control to be handed over to the coordinator.
   /// Usually this should cause the coordinator to push a basal view controller.
   func start()
}
