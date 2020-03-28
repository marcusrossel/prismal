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
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        geometryView.backgroundColor = .black
        setupLayoutConstraints()
    }
    
    // MARK: - Requirements
    
    /// Do not call this initializer! This view does not support storyboards or XIB.
    required init?(coder aDecoder: NSCoder) { fatalError("View doesn't support storyboard or XIB.") }
}

// MARK: - Auto Layout

extension MainViewController {
    
    private func setupLayoutConstraints() {
        geometryView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(geometryView)
        
        let guide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            geometryView.topAnchor.constraint(equalTo: guide.topAnchor),
            geometryView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            geometryView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            geometryView.trailingAnchor.constraint(equalTo: guide.trailingAnchor)
        ])
    }
}
