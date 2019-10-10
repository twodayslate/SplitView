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
    let removeButton = UIBarButtonItem(title: "Remove", style: .plain, target: self, action: #selector(removeView(_:)))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        
        let toolbar = UIToolbar()
        stack.addArrangedSubview(toolbar)
        
        toolbar.items = [
            UIBarButtonItem(title: "Rotate", style: .plain, target: self, action: #selector(rotate(_:))),
            UIBarButtonItem(title: "Toggle Snapping", style: .plain, target: self, action: #selector(toggleSnap(_:))),
            UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addView(_:))),
            removeButton
        ]
        
        splitView = SplitView()
        splitView.backgroundColor = .black
        stack.addArrangedSubview(splitView)
        
        browser.layer.cornerRadius = 15.0
        browser.backgroundColor = .systemBackground
        browser.layer.masksToBounds = true
        label.backgroundColor = .systemBackground
        label.layer.cornerRadius = 15.0
        label.layer.masksToBounds = true
        
        splitView.addSplitSubview(browser)
        splitView.addSplitSubview(label)
        
        self.view.addSubview(stack)
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[stack]-|", options: .alignAllCenterY, metrics: nil, views: ["stack": stack]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stack]|", options: .alignAllCenterY, metrics: nil, views: ["stack": stack]))
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
    
    @objc func toggleSnap(_ sender: UIBarButtonItem) {
        if splitView.snap.isEmpty {
            sender.title = "Turn off Snapping"
            splitView.snap.append(SplitViewSnapBehavior.quarter)
        } else {
            sender.title = "Turn on Snapping"
            splitView.snap.removeAll()
        }
    }
    
    @objc func addView(_ sender: UIBarButtonItem) {
        
        let label = UILabel()
        label.text = splitView.splitSubviews.count.description
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 50.0)
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = .systemBackground
        label.layer.cornerRadius = 15.0
        label.layer.masksToBounds = true
        
        splitView.addSplitSubview(label)
        
        removeButton.isEnabled = true
    }
    
    @objc func removeView(_ sender: UIBarButtonItem) {
        splitView.removeSplitSubview(splitView.splitSubviews.last!)
        if splitView.splitSubviews.count <= 0 {
            removeButton.isEnabled = false
        }
    }
}
