//
//  UIHelpers.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2025-10-04.
//

import UIKit
import SwiftUI


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


    func topViewController<T: UIViewController>(of type: T.Type) -> T? {
        return topViewController() as? T
    }
}


extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners) )
    }
}


struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
       
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

//Custom Colors 
extension Color {
  
    static let primaryPurple = Color(red: 0.35, green: 0.28, blue: 0.98)

    static let lightGrayBackground = Color(UIColor.systemGray6)
    
    static let successGreen = Color(red: 0.20, green: 0.80, blue: 0.35)
    
    static let accentBlue = Color(red: 0.3, green: 0.4, blue: 0.9)
 
    static let lightSuccessBackground = Color.successGreen.opacity(0.15)
   
    static let lightAccentBackground = Color.accentBlue.opacity(0.15)
}


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


struct FeatureRow: View {
    let iconName: String
    let iconColor: Color
    let text: String

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // Icon with Circular Badge
            ZStack {
              
                Circle()
                    .fill(Color.lightAccentBackground)
                    .frame(width: 40, height: 40)
        
                Image(systemName: iconName)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
            }
            .frame(width: 40, height: 40) // Give ZStack a fixed frame
            
      
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
        }
    }
}
