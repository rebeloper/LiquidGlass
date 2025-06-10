//
//  LiquidGlass+View.swift
//  LiquidGlass
//
//  Created by Alex Nagy on 10.06.2025.
//

import SwiftUI

@available(iOS 15.0, macOS 14.0, watchOS 10.0, tvOS 15.0, visionOS 1.0, *)
public extension View {
    /// Applies a customizable glass/frosted effect to the view
    /// - Parameters:
    ///   - displayMode: Controls when the effect is displayed (.always or .automatic)
    ///   - radius: Corner radius of the glass effect
    ///   - color: Base color for the effect's gradient and highlights
    ///   - material: The material style to use for the glass effect
    ///   - gradientOpacity: Opacity level for the gradient overlay
    ///   - gradientStyle: Direction style of the gradient (.normal or .reverted)
    ///   - strokeWidth: Width of the border stroke
    ///   - shadowColor: Color of the drop shadow
    ///   - shadowOpacity: Opacity level for the shadow
    ///   - shadowRadius: Blur radius for the shadow (defaults to corner radius if nil)
    ///   - shadowX: Horizontal offset of the shadow
    ///   - shadowY: Vertical offset of the shadow
    /// - Returns: A view with the glass effect applied
    func glass(
        displayMode: LiquidGlassBackgroundModifier.GlassBackgroundDisplayMode = .always,
        radius: CGFloat = 32,
        color: Color = .white,
        material: Material = .ultraThinMaterial,
        gradientOpacity: Double = 0.5,
        gradientStyle: LiquidGlassBackgroundModifier.GradientStyle = .normal,
        strokeWidth: CGFloat = 1.5,
        shadowColor: Color = .white,
        shadowOpacity: Double = 0.5,
        shadowRadius: CGFloat? = nil,
        shadowX: CGFloat = 0,
        shadowY: CGFloat = 5
    ) -> some View {
        #if os(visionOS)
        return self.glassBackgroundEffect()
        #else
        return modifier(LiquidGlassBackgroundModifier(
            displayMode: displayMode,
            radius: radius,
            color: color,
            material: material,
            gradientOpacity: gradientOpacity,
            gradientStyle: gradientStyle,
            strokeWidth: strokeWidth,
            shadowColor: shadowColor,
            shadowOpacity: shadowOpacity,
            shadowRadius: shadowRadius,
            shadowX: shadowX,
            shadowY: shadowY
        ))
        #endif
    }
    
    /// Applies a liquefied glass effect with animation to the view
    /// - Parameters:
    ///   - color: Base color for the jelly effect
    ///   - blobIntensity: Controls how pronounced the blob deformation is (0.0-1.0)
    ///   - animationSpeed: Controls the speed of the animation (1.0 is default)
    ///   - complexity: Number of control points that define the blob shape (4-12 recommended)
    ///   - material: The material style to use for the glass effect
    ///   - gradientOpacity: Opacity level for the gradient overlay
    ///   - shadowOpacity: Opacity level for the shadow
    /// - Returns: A view with animated jelly glass effect applied
    func liquefiedGlass(
        color: Color = .blue,
        blobIntensity: CGFloat = 0.5,
        animationSpeed: Double = 1.0,
        complexity: Int = 8,
        material: Material = .ultraThinMaterial,
        gradientOpacity: Double = 0.5,
        shadowOpacity: Double = 0.3
    ) -> some View {
        let modifier = BlobGlassModifier(
            color: color,
            blobIntensity: blobIntensity,
            animationSpeed: animationSpeed,
            complexity: complexity,
            material: material,
            gradientOpacity: gradientOpacity,
            shadowOpacity: shadowOpacity
        )
        
        return self.modifier(modifier)
    }
}
