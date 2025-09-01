//
//  ContentView.swift
//  Random
//
//  Created by Prank on 1/9/25.
//

import SwiftUI

struct ContentView: View {
    @State private var rotationAngle: Double = 0
    @State private var isSpinning: Bool = false
    @State private var selectedNumber: Int = 0
    @State private var showResult: Bool = false
    @State private var finalAngle: Double = 0
    
    let numbers = Array(0...99)
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("🎯 VÒNG QUAY MAY MẮN")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Từ 0 đến 99")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                ZStack {
                    // Wheel background
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [.white, .gray.opacity(0.3)]),
                                center: .center,
                                startRadius: 50,
                                endRadius: 150
                            )
                        )
                        .frame(width: 300, height: 300)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    // Wheel sections
                    ForEach(0..<100, id: \.self) { index in
                        let angle = Double(index) * 3.6 // 360/100 = 3.6 degrees per section
                        
                        Path { path in
                            path.move(to: CGPoint(x: 150, y: 150))
                            path.addArc(
                                center: CGPoint(x: 150, y: 150),
                                radius: 140,
                                startAngle: .degrees(angle - 1.8),
                                endAngle: .degrees(angle + 1.8),
                                clockwise: false
                            )
                            path.closeSubpath()
                        }
                        .fill(index % 2 == 0 ?
                              Color.orange.opacity(0.8) :
                              Color.red.opacity(0.8))
                        .overlay(
                            Text("\(index)")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.white)
                                .position(
                                    x: 150 + cos(angle * .pi / 180) * 100,
                                    y: 150 + sin(angle * .pi / 180) * 100
                                )
                        )
                    }
                }
                .frame(width: 300, height: 300)
                .rotationEffect(.degrees(rotationAngle))
                .animation(
                    isSpinning ?
                    .easeOut(duration: 3.0) :
                    .default,
                    value: rotationAngle
                )
                
                // Pointer
                Triangle()
                    .fill(Color.yellow)
                    .frame(width: 20, height: 30)
                    .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 2)
                    .offset(y: -165)
                
                // Result display
                if showResult {
                    VStack(spacing: 10) {
                        Text("🎉 KẾT QUẢ 🎉")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("\(selectedNumber)")
                            .font(.system(size: 48, weight: .heavy))
                            .foregroundColor(.primary)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.yellow.opacity(0.3))
                                    .shadow(radius: 5)
                            )
                    }
                    .scaleEffect(showResult ? 1.0 : 0.5)
                    .opacity(showResult ? 1.0 : 0.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showResult)
                }
                
                // Spin button
                Button(action: spinWheel) {
                    HStack {
                        Image(systemName: isSpinning ? "arrow.clockwise" : "play.fill")
                            .rotationEffect(.degrees(isSpinning ? 360 : 0))
                            .animation(
                                isSpinning ?
                                .linear(duration: 1).repeatForever(autoreverses: false) :
                                .default,
                                value: isSpinning
                            )
                        
                        Text(isSpinning ? "Đang quay..." : "QUAY NGAY!")
                            .fontWeight(.bold)
                    }
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: isSpinning ?
                                             [.gray, .gray.opacity(0.7)] :
                                             [.green, .blue]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                    .scaleEffect(isSpinning ? 0.95 : 1.0)
                }
                .disabled(isSpinning)
                
                Spacer()
            }
            .padding()
        }
    }
    
    func spinWheel() {
        guard !isSpinning else { return }
        
        // Hide previous result
        showResult = false
        isSpinning = true
        
        // Generate random number and calculate angle
        selectedNumber = Int.random(in: 0...99)
        let randomSpins = Double.random(in: 5...8) // Random number of full spins
        let targetAngle = Double(selectedNumber) * 3.6 // Each number is 3.6 degrees apart
        
        // Calculate final rotation angle
        finalAngle = (randomSpins * 360) + (360 - targetAngle) // Subtract because wheel spins clockwise but we want pointer to point to number
        rotationAngle += finalAngle
        
        // Show result after spinning
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            isSpinning = false
            showResult = true
        }
    }
}

// Custom triangle shape for pointer
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        
        return path
    }
}

#Preview {
    ContentView()
}

