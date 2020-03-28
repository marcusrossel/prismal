//
//  AppCoordinator.swift
//  Prismal
//
//  Created by Marcus Rossel on 14.11.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

// MARK: - App Coordinator

/// The coordinator sitting at the root of the entire app.
final class AppCoordinator: RootCoordinator {
   
   /// The window in which the coordinator will manage content.
   private let window: UIWindow
   
   /// The root coordinator managing the app's controllers.
   private(set) lazy var mainCoordinator: MainCoordinator = MainCoordinator()
   
   /// The view controller assigned as the window's root view controller.
   private(set) lazy var rootViewController: UIViewController = mainCoordinator.rootViewController
   
   /// Initializes an app coordinator from the window in which it will display its content.
   init(window: UIWindow) {
      self.window = window
   }
   
   /// Hands controller over to the app coordinator, which effectively starts the app.
   func start() {
      // Sets up and presents the window.
      window.rootViewController = rootViewController
      window.makeKeyAndVisible()
      
      mainCoordinator.start()
   }
}
