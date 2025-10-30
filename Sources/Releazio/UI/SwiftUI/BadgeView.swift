//
//  BadgeView.swift
//  Releazio
//
//  Created by Releazio Team on 05.10.2025.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

/// SwiftUI view for update badge indicator
public struct BadgeView: View {
    
    // MARK: - Properties
    
    /// Badge color
    private let badgeColor: Color
    
    /// Badge size
    private let size: CGFloat
    
    /// Action when badge is tapped
    private let onTap: (() -> Void)?
    
    // MARK: - Initialization
    
    /// Initialize badge view
    /// - Parameters:
    ///   - color: Badge color (default: yellow)
    ///   - size: Badge diameter size (default: 12)
    ///   - onTap: Action to perform when badge is tapped
    public init(
        color: Color? = nil,
        size: CGFloat = 12,
        onTap: (() -> Void)? = nil
    ) {
        self.badgeColor = color ?? .yellow
        self.size = size
        self.onTap = onTap
    }
    
    // MARK: - Body
    
    public var body: some View {
        Circle()
            .fill(badgeColor)
            .frame(width: size, height: size)
            .contentShape(Circle())
            .onTapGesture {
                onTap?()
            }
    }
}


