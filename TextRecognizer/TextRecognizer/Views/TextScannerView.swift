//
//  TextScannerView.swift
//  TextRecognizer
//
//  Created by Vlad Borisenko on 8/8/23.
//

import SwiftUI

struct TextScannerHud: View {
    @EnvironmentObject var cameraService: CameraService
    @State var croppableImageRect: CGRect
    
    @Binding var isPhotoTaken: Bool
    
    var body: some View {
        GeometryReader(content: { geometry in
            VStack {
                InfoBanner(title: "Crop by adjusting the corner")
                    .background(Color.black.opacity(Constants.hudBackgroundOpacity))
                    .cornerRadius(Constants.cornerRadius)
                    .padding(.top, Constants.bannerTopPadding)
                Spacer()
                HStack {
                    Button(action: {
                        isPhotoTaken = false
                    }, label: {
                        Text("Cancel")
                            .padding(.horizontal, 50)
                            .padding(.vertical, 15)
                            .foregroundColor(.gray)
                            .background(.black)
                    })
                    .cornerRadius(Constants.cornerRadius)
                    
                    Spacer()
                    
                    Button(action: {
                        cameraService.cropImage(
                            toRect: CGRect(x: croppableImageRect.minX, y: croppableImageRect.minY, width: croppableImageRect.width, height: croppableImageRect.height),
                            viewWidth: geometry.size.width, viewHeight: geometry.size.height)
                    }, label: {
                        Text("Confirm")
                            .padding(.horizontal, 50)
                            .padding(.vertical, 15)
                            .foregroundColor(.black)
                            .background(.green)
                    })
                    .cornerRadius(Constants.cornerRadius)
                }
            }
            .padding(30)
        })
    }
}
