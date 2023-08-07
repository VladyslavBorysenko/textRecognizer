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
    @State var isPhotoTaken: Bool = false
    @State var cropViewState = CGSize.zero
    
    var body: some View {
        if isPhotoTaken {
            ZStack {
                Image(uiImage: cameraService.capturedPhoto ?? UIImage())
                    .resizable(resizingMode: .stretch)
                    .ignoresSafeArea()
                    .scaledToFit()
                TextScannerHud()
                    .environmentObject(cameraService)
                CropView()
                    .offset(cropViewState)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                cropViewState = value.translation
                            }
                    )
            }
        } else {
            ZStack {
                CameraPreviewHolder(cameraService: cameraService)
                    .ignoresSafeArea()
                PhotoHud(isPhotoTaken: $isPhotoTaken)
                    .environmentObject(cameraService)
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

struct TextScannerHud: View {
    @EnvironmentObject var cameraService: CameraService
    
    var body: some View {
        VStack {
            InfoBanner(title: "Crop by adjusting the corner")
                .background(Color.black.opacity(Constants.hudBackgroundOpacity))
                .cornerRadius(Constants.cornerRadius)
                .padding(.top, Constants.bannerTopPadding)
            Spacer()
            HStack {
                Button(action: {}, label: {
                    Text("Cancel")
                        .padding(.horizontal, 50)
                        .padding(.vertical, 15)
                        .foregroundColor(.gray)
                        .background(.black)
                })
                .cornerRadius(Constants.cornerRadius)
                
                Spacer()
                
                Button(action: {
                    cameraService.cropImage(toRect: CGRect(x: <#T##CGFloat#>, y: <#T##CGFloat#>, width: <#T##CGFloat#>, height: <#T##CGFloat#>))
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
    }
}

struct CropView: View {
    // Initialise to a size proportional to the screen dimensions.
    @State private(set) var width: CGFloat = UIScreen.main.bounds.size.width / 1.5
    @State private(set) var height: CGFloat = UIScreen.main.bounds.size.height / 7
    
    var body: some View {
        // This is the view that's going to be resized.
        ZStack(alignment: .bottomTrailing) {
            Text("")
                .frame(width: width, height: height)
            // This is the "drag handle" positioned on the lower-left corner of this stack.
            Text("")
                .frame(width: 20, height: 20)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // Enforce minimum dimensions.
                            guard width + value.translation.width < UIScreen.main.bounds.size.width && height + value.translation.height < UIScreen.main.bounds.size.height else { return }
                            width = max(100, width + value.translation.width)
                            height = max(50, height + value.translation.height)
                        }
                )
        }
        .contentShape(Rectangle())
        .frame(width: width, height: height, alignment: .center)
        .overlay {
            Rectangle()
                .foregroundColor(.white.opacity(0))
                .overlay(
                    GeometryReader { geometry in
                        Path { path in
                            let halfCorner: CGFloat = 20
                            
                            path.move(to: CGPoint(x: 0, y: halfCorner))
                            path.addLine(to: CGPoint(x: 0, y: 0))
                            path.addLine(to: CGPoint(x: halfCorner, y: 0))
                            
                            path.move(to: CGPoint(x: geometry.size.width - halfCorner, y: 0))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: 0))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: halfCorner))
                            
                            path.move(to: CGPoint(x: geometry.size.width, y: geometry.size.height - halfCorner))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                            path.addLine(to: CGPoint(x: geometry.size.width - halfCorner, y: geometry.size.height))

                            path.move(to: CGPoint(x: halfCorner, y: geometry.size.height))
                            path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
                            path.addLine(to: CGPoint(x: 0, y: geometry.size.height - halfCorner))

                        }
                        .stroke(.white, lineWidth: 2)
                    }
                )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
