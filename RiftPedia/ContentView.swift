import SwiftUI

extension Color {
    static let appAccent = Color("Accent")
    static let appBackground = Color("Background")
    static let appButton = Color("Button")
    static let appLabel = Color("Label")
}

struct ContentView: View {
    // Add animation states
    @State private var isLogoAnimated = false
    @State private var isTextAnimated = false
    @State private var isButtonAnimated = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Enhanced Background with Gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.appBackground,
                        Color.appBackground.opacity(0.9),
                        Color.appBackground.opacity(0.8)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Optional: Animated particles in background
                ParticlesView()
                    .opacity(0.1)
                
                VStack(spacing: 20) {
                    // Enhanced Logo
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .padding(.top, 20)
                        .shadow(color: .appAccent.opacity(0.3), radius: 15)
                        .scaleEffect(isLogoAnimated ? 1 : 0.8)
                        .opacity(isLogoAnimated ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isLogoAnimated)
                    
                    VStack(spacing: 15) {
                        // Enhanced Welcome Title - FIXED VERSION
                        HStack(spacing: 0) {
                            Text("Welcome to")
                                .font(.title)
                                .fontWeight(.medium)
                                .foregroundColor(.appLabel)
                                .opacity(0.9)
                            
                            Text(" RiftPedia")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.appAccent)
                                .shadow(color: .appAccent.opacity(0.3), radius: 2, x: 0, y: 1)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        // Enhanced Description
                        Text("Explore League of Legends lore, champions, and player stats all in one place!")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.appLabel.opacity(0.8))
                            .padding(.horizontal, 30)
                            .padding(.top, 5)
                            .animation(.easeOut(duration: 0.5), value: isTextAnimated)
                    }
                    .offset(y: isTextAnimated ? 0 : 50)
                    .opacity(isTextAnimated ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.3), value: isTextAnimated)
                    
                    Spacer()
                    
                    // Enhanced Get Started Button
                    NavigationLink(destination: GetStartedPage()) {
                        HStack {
                            Text("Get Started")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title2)
                        }
                        .foregroundColor(.appBackground)
                        .frame(width: 300, height: 60)
                        .background(
                            ZStack {
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.appButton,
                                        Color.appButton.opacity(0.8)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                
                                // Subtle shine effect
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                .white.opacity(0.2),
                                                .clear
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                        )
                        .cornerRadius(15)
                        .shadow(color: Color.appButton.opacity(0.5), radius: 10, x: 0, y: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .buttonStyle(BouncyButton())
                    .offset(y: isButtonAnimated ? 0 : 50)
                    .opacity(isButtonAnimated ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.6), value: isButtonAnimated)
                    .padding(.bottom, 70)
                }
                .padding()
            }
        }
        .onAppear {
            isLogoAnimated = true
            isTextAnimated = true
            isButtonAnimated = true
        }
    }
}

// Bouncy Button Style
struct BouncyButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// Particle Effect View
struct ParticlesView: View {
    @State private var time: CGFloat = 0
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<30) { i in
                Circle()
                    .fill(Color.appAccent.opacity(0.3))
                    .frame(width: 4, height: 4)
                    .position(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: (CGFloat(i) * 20 + time * 50).truncatingRemainder(dividingBy: geometry.size.height)
                    )
            }
        }
        .onReceive(timer) { _ in
            withAnimation(.linear(duration: 0.1)) {
                time += 0.1
            }
        }
    }
}

// Optional: Custom View Modifier for Card Style
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.appBackground)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
    }
}
