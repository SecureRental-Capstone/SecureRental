//
//import AuthenticationServices
//import SwiftUI
//
//struct LandingView: View {
////    @EnvironmentObject private var authenticationService: AuthenticationService
//    @State private var isLoading = true
//    @EnvironmentObject var dbHelper: FireDBHelper
//    
//    var body: some View {
//        ZStack {
//                // c color or any other views you want to add
//            Color.white.ignoresSafeArea()
//            
//            if isLoading {
//                ProgressView()
//            }
//            
//            Group {
//                //TODO: FIX
//                if true {
//                //if authenticationService.isSignedIn {
//                    LaunchView()
//                } else {
//                    VStack {
//                        Spacer() // Add space to push the button towards the center
//                        
//                        Button(action: {
//                            Task {
//                                //TODO: FIX
//                                //await authenticationService.signIn(presentationAnchor: window)
//                                //await dbHelper.signOut
//                            }
//                        }) {
//                            HStack {
//                                Image("Logo")  // Use the name you gave to the image in Assets.xcassets
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(width: 30, height: 30)
//                                Text("Sign in")
//                                    .font(.title2)
//                                    .foregroundColor(.white)
//                            }
//                            .padding()
//                            .background(Color.blue)
//                            .cornerRadius(10)
//                        }
//                        .frame(maxWidth: .infinity)  // Button width will expand
//                        .padding(.horizontal)  // Optional padding to ensure the button is not too wide
//                        
//                        Spacer() // Add space to push the button towards the center
//                    }
//                }
//            }
//            .opacity(isLoading ? 0.5 : 1)
//            .disabled(isLoading)
//        }
//        //TODO: FIX 
////        .task {
////            isLoading = true
////            await authenticationService.fetchSession()
////            if !authenticationService.isSignedIn {
////                await authenticationService.signIn(presentationAnchor: window)
////            }
////            isLoading = false
////        }
//    }
//    
//    private var window: ASPresentationAnchor {
//        if let delegate = UIApplication.shared.connectedScenes.first?.delegate as? UIWindowSceneDelegate,
//           let window = delegate.window as? UIWindow {
//            return window
//        }
//        return ASPresentationAnchor()
//    }
//}
