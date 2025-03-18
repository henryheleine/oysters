//
//  OutcomeView.swift
//  Oysters
//
//  Created by Henry Heleine on 3/18/25.
//

import Foundation
import SwiftUI

struct OutcomeView: View {
    private var outcome: String?
    
    init (outcome: String?) {
        self.outcome = outcome
    }
    
    var body: some View {
        Text("Response:")
        if let outcome = outcome {
            ScrollView {
                Text(outcome)
            }
        } else {
            ProgressView()
        }
    }
}
