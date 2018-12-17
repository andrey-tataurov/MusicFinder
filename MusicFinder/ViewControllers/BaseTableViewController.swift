//
//  Created by Andrey Tataurov on 10/18/18.
//  Copyright © 2018 Andrey Tataurov. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController {
    
    fileprivate lazy var formatter: DateFormatter = self.lazyDateFormatter()
    fileprivate var spinnerView: UIView = UIView()
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        spinnerView = lazySpinnerView()
        let currentDateTime = formatter.string(from: Date())
        let viewControllerName = String(describing: self)
        
        print("\(currentDateTime) Screen: \(viewControllerName)")
    }
    
    fileprivate func lazyDateFormatter() -> DateFormatter {
        
        let formatter = DateFormatter()
        
        formatter.dateStyle = .short
        formatter.timeStyle = .long
        
        return formatter
    }
    
    fileprivate func lazySpinnerView() -> UIView {
        
        let spinnerView = UIView(frame: self.view.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let activityIndicator = UIActivityIndicatorView.init(style: .whiteLarge)
        activityIndicator.startAnimating()
        activityIndicator.center = spinnerView.center
        
        spinnerView.addSubview(activityIndicator)
        
        return spinnerView
    }
}

extension BaseTableViewController {
    
    public func displaySpinner() {
        DispatchQueue.main.async {
            self.view.addSubview(self.spinnerView)
        }
    }
    
    func hideSpinner() {
        DispatchQueue.main.async {
            self.spinnerView.removeFromSuperview()
        }
    }
}
