//
//  LoadingCircle.swift
//  SafeSpace
//
//  Created by Aryan Neb on 2025-02-25.
//
//  Reusing code from https://gist.github.com/sebsto/d91b29a8017c5a0800aa668ac208a2c7

import SwiftUI

struct LoadingCircleView: View {
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(hex: "#FBF1DA").opacity(0.5), lineWidth: 4)
            Circle()
                .trim(from: 0, to: 0.2)
                .stroke(Color(hex: "#B3DA95"), lineWidth: 4)
                .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: self.isLoading)
                .onAppear() {
                    self.isLoading = true
                }
        }
        .background(
            Circle()
                .fill(Color(hex: "#FBF1DA"))
                .shadow(color: Color(hex: "#1D2E0F").opacity(0.1), radius: 3, x: 0, y: 1)
        )
        .padding()
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingCircleView()
    }
}
