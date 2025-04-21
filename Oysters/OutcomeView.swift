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
        VStack {
            Text("Response:")
                .padding(.bottom, 2)
                .padding(.top, 10)
            if let content = content {
                Text(content)
                    .accessibilityLabel(content)
                    .padding([.bottom, .leading, .trailing], 15)
            } else {
                ProgressView()
            }
        }
        .background(Color.outcome)
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .foregroundStyle(Color.background)
        .padding([.leading, .trailing], 15)
        .onReceive(model.$response) { response in
            if let response = response {
                content = response.content
            }
        }
    }
}
