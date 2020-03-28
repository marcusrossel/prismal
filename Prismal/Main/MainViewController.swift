//
//  MainViewController.swift
//  Prismal
//
//  Created by Marcus Rossel on 14.11.18.
//  Copyright © 2018 Marcus Rossel. All rights reserved.
//

import UIKit

final class MainViewController: UIViewController {

   let geometryView = GeometryView()
   
   /// Creates a main view controller.
   init() {
      // Phase 2.
      super.init(nibName: nil, bundle: nil)
      
      // Phase 3.
      geometryView.backgroundColor = .black
      setupLayoutConstraints()
   }
   
   // MARK: - Requirements
   
   /// Do not call this initializer! This view does not support storyboards or XIB.
   required init?(coder aDecoder: NSCoder) { fatalError("View doesn't support storyboard or XIB.") }
}

// MARK: - Auto Layout

extension MainViewController {
   
   /// Sets up all of the necessary constraints for the controller to have a sensible layout.
   private func setupLayoutConstraints() {
      geometryView.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(geometryView)
      
      let guide = view.safeAreaLayoutGuide
      
      geometryView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
      geometryView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
      geometryView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
      geometryView.bottomAnchor.constraint(equalTo: sliderStack.topAnchor, constant: -8).isActive = true
      
      sliderStack.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 8).isActive = true
      sliderStack.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -8).isActive = true
      sliderStack.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -8).isActive = true
   }
}
