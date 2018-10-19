//
//  Created by Andrey Tataurov on 10/18/18.
//  Copyright © 2018 Andrey Tataurov. All rights reserved.
//

import Foundation

struct Track: Codable {
    
    let trackName: String
    let artistName: String
    let collectionName: String?
    let collectionPrice: Decimal
    let trackPrice: Decimal
    let releaseDate: String
}
