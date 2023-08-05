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
    static let bigCircleSize: CGFloat = 55
    static let smallCircleSize: CGFloat = 45
    static let hudBackgroundOpacity: Double = 0.7
    static let cirlceLineWidth: CGFloat = 3
    static let cornerRadius: CGFloat = 10
    static let bannerTopPadding: CGFloat = 50
}

struct CameraView: View {
    @ObservedObject var cameraService: CameraService = CameraService()
    var body: some View {
        ZStack{
            CameraPreviewHolder(cameraService: cameraService)
                .ignoresSafeArea()
            VStack {
                InfoBanner(title: "Take a picture of your question")
                    .background(Color.black.opacity(Constants.hudBackgroundOpacity))
                    .cornerRadius(Constants.cornerRadius)
                    .padding(.top, Constants.bannerTopPadding)
                Spacer()
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
                .background(Color.black.opacity(Constants.hudBackgroundOpacity))
            }
        }
    }
}

struct InfoBanner: View {
    let title: String
    var body: some View {
        Text(title)
            .foregroundColor(.white)
            .padding(.horizontal, 40)
            .padding(.vertical, 10)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
