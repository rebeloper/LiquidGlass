//
//  LiquidGlass+ViewModifiers.swift
//  LiquidGlass
//
//  Created by Alex Nagy on 10.06.2025.
//

import SwiftUI

@available(iOS 15.0, macOS 14.0, watchOS 10.0, tvOS 15.0, visionOS 1.0, *)
public struct LiquidGlassBackgroundModifier: ViewModifier {
    
    public enum GlassBackgroundDisplayMode {
        case always
        case automatic
    }
    
    public enum GradientStyle {
        case normal
        case reverted
    }
    
    let displayMode: GlassBackgroundDisplayMode
    let radius: CGFloat
    let color: Color
    let material: Material
    let gradientOpacity: Double
    let gradientStyle: GradientStyle
    let strokeWidth: CGFloat
    let shadowColor: Color
    let shadowOpacity: Double
    let shadowRadius: CGFloat
    let shadowX: CGFloat
    let shadowY: CGFloat
    
    public init(
        displayMode: GlassBackgroundDisplayMode,
        radius: CGFloat,
        color: Color,
        material: Material = .ultraThinMaterial,
        gradientOpacity: Double = 0.5,
        gradientStyle: GradientStyle = .normal,
        strokeWidth: CGFloat = 1.5,
        shadowColor: Color = .white,
        shadowOpacity: Double = 0.5,
        shadowRadius: CGFloat? = nil,
        shadowX: CGFloat = 0,
        shadowY: CGFloat = 5
    ) {
        self.displayMode = displayMode
        self.radius = radius
        self.color = color
        self.material = material
        self.gradientOpacity = gradientOpacity
        self.gradientStyle = gradientStyle
        self.strokeWidth = strokeWidth
        self.shadowColor = shadowColor
        self.shadowOpacity = shadowOpacity
        self.shadowRadius = shadowRadius ?? radius
        self.shadowX = shadowX
        self.shadowY = shadowY
    }
    
    public func body(content: Content) -> some View {
        content
            .background(material)
            .cornerRadius(radius)
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: gradientColors()),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: strokeWidth
                    )
            )
            .shadow(color: shadowColor.opacity(shadowOpacity), radius: shadowRadius, x: shadowX, y: shadowY)
    }
    
    private func gradientColors() -> [Color] {
        switch gradientStyle {
        case .normal:
            return [
                color.opacity(gradientOpacity),
                .clear,
                .clear,
                color.opacity(gradientOpacity)
            ]
        case .reverted:
            return [
                .clear,
                color.opacity(gradientOpacity),
                color.opacity(gradientOpacity),
                .clear
            ]
        }
    }
}

@available(iOS 15.0, macOS 14.0, watchOS 10.0, tvOS 15.0, visionOS 1.0, *)
public struct BlobGlassModifier: ViewModifier {
    // Parameters
    let color: Color
    let blobIntensity: CGFloat
    let animationSpeed: Double
    let complexity: Int
    let material: Material
    let gradientOpacity: Double
    let shadowOpacity: Double
    
    @State private var animationProgress: CGFloat = 0.0
    
    public init(
        color: Color,
        blobIntensity: CGFloat,
        animationSpeed: Double,
        complexity: Int,
        material: Material,
        gradientOpacity: Double,
        shadowOpacity: Double
    ) {
        self.color = color
        self.blobIntensity = min(max(blobIntensity, 0.1), 1.0) // Constrain between 0.1 and 1.0
        self.animationSpeed = animationSpeed
        self.complexity = min(max(complexity, 4), 12) // Constrain between 4 and 12
        self.material = material
        self.gradientOpacity = gradientOpacity
        self.shadowOpacity = shadowOpacity
    }
    
    public func body(content: Content) -> some View {
        content
            .clipShape(
                BlobShape(
                    complexity: complexity,
                    animationProgress: animationProgress,
                    intensity: blobIntensity
                )
            )
            .background(
                BlobShape(
                    complexity: complexity,
                    animationProgress: animationProgress,
                    intensity: blobIntensity
                )
                .fill(material)
                .overlay(
                    BlobShape(
                        complexity: complexity,
                        animationProgress: animationProgress,
                        intensity: blobIntensity
                    )
                    .stroke(
                        LinearGradient(
                            colors: [
                                color.opacity(gradientOpacity),
                                color.opacity(0),
                                color.opacity(gradientOpacity),
                                color.opacity(0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                )
                .shadow(
                    color: color.opacity(shadowOpacity),
                    radius: 10,
                    x: 0,
                    y: 5
                )
            )
            .onAppear {
                withAnimation(
                    Animation
                        .linear(duration: 10 / animationSpeed)
                        .repeatForever(autoreverses: true)
                ) {
                    animationProgress = 1.0
                }
            }
    }
}

@available(iOS 15.0, macOS 14.0, watchOS 10.0, tvOS 15.0, visionOS 1.0, *)
public struct BlobShape: Shape {
    
    var controlPoints: [UnitPoint]
    var animationProgress: CGFloat
    var intensity: CGFloat
    
    public init(complexity: Int = 8, animationProgress: CGFloat = 0.0, intensity: CGFloat = 0.5) {
        self.controlPoints = BlobShape.generateControlPoints(count: complexity)
        self.animationProgress = animationProgress
        self.intensity = intensity
    }
    
    public var animatableData: CGFloat {
        get { animationProgress }
        set { animationProgress = newValue }
    }
    
    public func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let minDimension = min(rect.width, rect.height)
        let radius = minDimension / 2
        
        let points = controlPoints.map { unitPoint -> CGPoint in
            let angle = 2 * .pi * unitPoint.x + (animationProgress * 2 * .pi)
            let distortionAmount = sin(angle * 3 + animationProgress * 4) * intensity * 0.2
            let blobRadius = radius * (1 + distortionAmount)
            let pointX = center.x + cos(angle) * blobRadius
            let pointY = center.y + sin(angle) * blobRadius
            return CGPoint(x: pointX, y: pointY)
        }
        
        var path = Path()
        guard points.count > 2 else { return path }
        
        path.move(to: points[0])
        
        let count = points.count
        for i in 0..<count {
            let prev = points[(i - 1 + count) % count]
            let curr = points[i]
            let next = points[(i + 1) % count]
            let next2 = points[(i + 2) % count]
            
            // Calculate control points for smoothness
            let control1 = CGPoint(
                x: curr.x + (next.x - prev.x) / 6,
                y: curr.y + (next.y - prev.y) / 6
            )
            let control2 = CGPoint(
                x: next.x - (next2.x - curr.x) / 6,
                y: next.y - (next2.y - curr.y) / 6
            )
            
            path.addCurve(to: next, control1: control1, control2: control2)
        }
        
        path.closeSubpath()
        return path
    }
    
    private static func generateControlPoints(count: Int) -> [UnitPoint] {
        var points = [UnitPoint]()
        let angleStep = 1.0 / CGFloat(count)
        
        for i in 0..<count {
            let angle = CGFloat(i) * angleStep
            points.append(UnitPoint(x: angle, y: angle))
        }
        
        return points
    }
}
