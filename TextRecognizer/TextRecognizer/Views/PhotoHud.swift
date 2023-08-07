//
//  PhotoHud.swift
//  TextRecognizer
//
//  Created by Vlad Borisenko on 8/8/23.
//

import SwiftUI

struct PhotoHud: View {
    @EnvironmentObject var cameraService: CameraService
    @Binding var isPhotoTaken: Bool
    
    var body: some View {
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
                .onTapGesture {
                    cameraService.takePhoto {
                        isPhotoTaken = true
                    }
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
