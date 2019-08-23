//
//  ViewController.swift
//  app
//
//  Created by Zachary Gorak on 8/23/19.
//  Copyright © 2019 Zac Gorak. All rights reserved.
//

import UIKit
import SplitView
import WebKit


class ViewController: UIViewController {

    var splitView: SplitView!
    
    let browser = WKWebView()
    let label = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        
        let toolbar = UIToolbar()
        stack.addArrangedSubview(toolbar)
        
        toolbar.items = [
            UIBarButtonItem(title: "Rotate", style: .plain, target: self, action: #selector(rotate(_:)))
        ]
        
        splitView = SplitView()
        stack.addArrangedSubview(splitView)
        
        splitView.addView(browser)
        splitView.addView(label)
        
        self.view.addSubview(stack)
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollview]|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))
        
        // TODO: make it so this isn't necessary
        toolbar.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let url = URL(string: "https://zac.gorak.us/")!
        
        browser.load(URLRequest(url: url))
        
        DispatchQueue.init(label: "background", qos: .userInitiated).async {
            let source = (try? String(contentsOf: url)) ?? "UNABLE TO GET SOURCE"
            DispatchQueue.main.async {
                self.label.text = source
            }
        }
        
    }
    
    @objc func rotate(_ sender: UIBarButtonItem) {
        print("rotate")
        if self.splitView.axis == .horizontal {
            self.splitView.axis = .vertical
        } else {
            self.splitView.axis = .horizontal
        }
    }
}
