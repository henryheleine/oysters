//
//  OutcomeView.swift
//  Oysters
//
//  Created by Henry Heleine on 3/18/25.
//

import Foundation
import SwiftUI

struct OutcomeView: View {
    @ObservedObject var model: Model
    @State var content: String?
    
    var body: some View {
        Group {
            Text("Response:")
            if let content = content {
                ScrollView {
                    Text(content)
                }
            } else {
                ProgressView()
            }
        }
        .onReceive(model.$response) { response in
            if let response = response {
                content = response.content
            }
        }
    }
}
