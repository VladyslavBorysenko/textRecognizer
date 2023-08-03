//
//  ContentView.swift
//  TextRecognizer
//
//  Created by Vlad Borisenko on 8/3/23.
//

import SwiftUI

private enum Constants {
    static let padding: CGFloat = 40
    static let imageSize: CGFloat = 27
    static let bigCircleSize: CGFloat = 45
    static let smallCircleSize: CGFloat = 35
    static let hudBackgroundOpacity: Double = 0.7
    static let cirlceLineWidth: CGFloat = 3
}

struct CameraView: View {
    var body: some View {
        HStack {
            Image(systemName: "bolt.fill")
                .font(Font.system(size: Constants.imageSize))
                .foregroundColor(.white)
                .padding(.leading, Constants.padding)
            Spacer()
            ZStack{
                Circle()
                    .stroke(lineWidth: Constants.cirlceLineWidth)
                    .frame(width: Constants.bigCircleSize, height: Constants.bigCircleSize)
                    .foregroundColor(.white)
                Circle()
                    .frame(width: Constants.smallCircleSize, height: Constants.smallCircleSize)
                    .foregroundColor(.green)
            }
            Spacer()
            Image(systemName: "photo")
                .font(Font.system(size: Constants.imageSize))
                .foregroundColor(.white)
                .padding(.trailing, Constants.padding)
            
        }
        .padding()
        .background(Color.gray.opacity(Constants.hudBackgroundOpacity))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
