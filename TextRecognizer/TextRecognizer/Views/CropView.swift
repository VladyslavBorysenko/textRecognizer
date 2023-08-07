//
//  CropView.swift
//  TextRecognizer
//
//  Created by Vlad Borisenko on 8/8/23.
//

import SwiftUI

struct CropView: View {
    // Initialise to a size proportional to the screen dimensions.
    @Binding var width: CGFloat
    @Binding var height: CGFloat
    @Binding var xPosition: CGFloat
    @Binding var yPosition: CGFloat
    
    var body: some View {
        // This is the view that's going to be resized.
        GeometryReader(content: { geometry in
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
                                xPosition = geometry.frame(in: .global).minX
                                yPosition = geometry.frame(in: .global).minY
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
        })
    }
}
