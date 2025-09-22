import SwiftUI
import AuthenticationServices
import Amplify

struct LandingView: View {
    @EnvironmentObject private var authenticationService: AuthenticationService
    @State private var isLoading = true
    @State private var showRoleSelection = false
    @State private var currentUser: User? = User.sampleUser
    @State private var navigateToHome = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                if isLoading {
                    ProgressView()
                }
                
                Group {
                    if navigateToHome, let user = currentUser {
                        HomeView(rootView: .constant(.main), user: user)
                    } else {
                        VStack {
                            Spacer()
                            
                            Button(action: {
                                Task {
                                    await signInAndSetupUser()
                                }
                            }) {
                                HStack {
                                    Image("Logo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                    Text("Sign in")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                            
                            Spacer()
                        }
                    }
                }
                .opacity(isLoading ? 0.5 : 1)
                .disabled(isLoading)
            }
            .fullScreenCover(isPresented: $showRoleSelection) {
                if let user = currentUser {
                    RoleSelectionView(user: user) {
                        navigateToHome = true
                    }
                    .environmentObject(authenticationService)
                }
            }
        }
        .task {
            isLoading = true
            await authenticationService.fetchSession()
            if authenticationService.isSignedIn {
                await loadCurrentUser()
            }
            isLoading = false
        }
    }

    // MARK: - Helpers

    private var window: ASPresentationAnchor {
        if let delegate = UIApplication.shared.connectedScenes.first?.delegate as? UIWindowSceneDelegate,
           let window = delegate.window as? UIWindow {
            return window
        }
        return ASPresentationAnchor()
    }

    private func signInAndSetupUser() async {
        isLoading = true
        do {
            try await authenticationService.signIn(presentationAnchor: window)
            await loadCurrentUser()
        } catch {
            print("Sign-in failed: \(error)")
        }
        isLoading = false
    }

    private func loadCurrentUser() async {
        do {
            let authUser = try await Amplify.Auth.getCurrentUser()
            
            // Fetch role from Cognito (custom attribute)
            let role = try await authenticationService.fetchRole()
            
            // Create your local User object
            currentUser = User(
                name: authUser.username,
                email: "",         // Fetch email from attributes if needed
                username: authUser.username,
                password: "",
                role: role
            )
            
            // If role not set, show RoleSelectionView
            if role == nil {
                showRoleSelection = true
            } else {
                navigateToHome = true
            }
        } catch {
            print("Failed to load user: \(error)")
        }
    }
}
