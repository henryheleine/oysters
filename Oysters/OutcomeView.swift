//
//  OutcomeView.swift
//  Oysters
//
//  Created by Henry Heleine on 3/18/25.
//

import Foundation
import SwiftUI

struct OutcomeView: View {
    @ObservedObject var viewModel: ViewModel
    @State var content: String?
    
    var body: some View {
        VStack {
            Text("Response:").padding(15)
            if let content = content {
                Text(content).accessibilityLabel(content).padding([.bottom, .leading, .trailing], 15)
            } else {
                ProgressView().colorScheme(.light).padding(.bottom, 15)
            }
        }
        .background(Color.outcome)
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .foregroundStyle(Color(UIColor.darkGray))
        .padding([.leading, .trailing], 15)
        .onReceive(viewModel.$response) { response in
            if let response = response {
                content = response.content
            }
        }
    }
}
