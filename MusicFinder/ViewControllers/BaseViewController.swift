//
//  Created by Andrey Tataurov on 10/18/18.
//  Copyright © 2018 Andrey Tataurov. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    fileprivate lazy var formatter: DateFormatter = self.lazyDateFormatter()

    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)

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
}
