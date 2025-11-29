//
//  UIHelpers.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2025-10-04.
//

import UIKit
import SwiftUI

//extension UIApplication {
//    func topViewController(
//        base: UIViewController? = UIApplication.shared
//            .connectedScenes
//            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
//            .first?.rootViewController
//    ) -> UIViewController? {
//        if let nav = base as? UINavigationController {
//            return topViewController(base: nav.visibleViewController)
//        }
//        if let tab = base as? UITabBarController {
//            return topViewController(base: tab.selectedViewController)
//        }
//        if let presented = base?.presentedViewController {
//            return topViewController(base: presented)
//        }
//        return base
//    }
//}

extension UIApplication {
    func topViewController(base: UIViewController? = UIApplication.shared.connectedScenes
                                    .compactMap { $0 as? UIWindowScene }
                                    .first?.windows.first?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }

    // Optional: Helper to find a specific type of VC
    func topViewController<T: UIViewController>(of type: T.Type) -> T? {
        return topViewController() as? T
    }
}

/// Extension to make using the custom corner radius simpler.
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners) )
    }
}

/// A custom shape for applying corner radius to specific corners.
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        // Uses UIKit's UIBezierPath to calculate the path for specific corners
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

//Custom Colors 
extension Color {
    // Primary action color (the deep purple/blue for the button)
    static let primaryPurple = Color(red: 0.35, green: 0.28, blue: 0.98)
    // Light background color for the main screen
    static let lightGrayBackground = Color(UIColor.systemGray6)
    //    // Success state color (the green for the large checkmark)
    static let successGreen = Color(red: 0.20, green: 0.80, blue: 0.35)
    
    static let accentBlue = Color(red: 0.3, green: 0.4, blue: 0.9)
    // New color: Light fill for the success badge background
    static let lightSuccessBackground = Color.successGreen.opacity(0.15)
    // New color: Light fill for the accent badge background
    static let lightAccentBackground = Color.accentBlue.opacity(0.15)
}

//Custom TextField Style 
// A custom style to make text fields look like the design.
struct CustomTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.white)
            .cornerRadius(12)
            .overlay( // Adds a subtle gray border
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
    }
}

// A reusable component for the icon and text list items, now including a circular badge.
struct FeatureRow: View {
    let iconName: String
    let iconColor: Color
    let text: String

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // Icon with Circular Badge
            ZStack {
                // 1. Background Circle (Light accent fill)
                Circle()
                    .fill(Color.lightAccentBackground)
                    .frame(width: 40, height: 40)
                // 3. The Feature Icon
                Image(systemName: iconName)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
            }
            .frame(width: 40, height: 40) // Give ZStack a fixed frame
            
            // Description text
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
        }
    }
}
