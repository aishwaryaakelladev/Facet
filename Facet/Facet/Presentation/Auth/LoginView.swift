internal import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var session: SessionStore
    @StateObject private var viewModel = LoginViewModel(
        loginUseCase: LoginUseCase(repository: LocalAuthRepository())
    )
    @State private var showDemoHint = false
    @FocusState private var focusedField: Field?

    private enum Field { case username, password }

    var body: some View {
        ZStack {
            backgroundGradient
            ScrollView {
                VStack(spacing: 32) {
                    Spacer().frame(height: 60)
                    logoSection
                    formCard
                    demoHintSection
                    Spacer()
                }
                .padding(.horizontal, 24)
            }
        }
        .ignoresSafeArea()
        .onAppear { viewModel.onLoginSuccess = { session.login($0) } }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color(hex: "6C47FF").opacity(0.08), Color(hex: "C850C0").opacity(0.05), Color(.systemBackground)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    // MARK: - Logo

    private var logoSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color(hex: "6C47FF"), Color(hex: "C850C0")],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .frame(width: 88, height: 88)
                    .shadow(color: Color(hex: "6C47FF").opacity(0.4), radius: 20, y: 8)
                Text("F")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            Text("Welcome to Facet")
                .font(.title.bold())
            Text("Sign in to continue")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Form card

    private var formCard: some View {
        VStack(spacing: 20) {
            // Username field
            HStack(spacing: 12) {
                Image(systemName: "person")
                    .foregroundStyle(Color(hex: "6C47FF"))
                    .frame(width: 20)
                TextField("Username", text: $viewModel.username)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($focusedField, equals: .username)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .password }
            }
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))

            // Password field
            HStack(spacing: 12) {
                Image(systemName: "lock")
                    .foregroundStyle(Color(hex: "6C47FF"))
                    .frame(width: 20)
                SecureField("Password", text: $viewModel.password)
                    .focused($focusedField, equals: .password)
                    .submitLabel(.go)
                    .onSubmit { viewModel.login() }
            }
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))

            // Error message
            if case .error(let msg) = viewModel.state {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill")
                    Text(msg)
                }
                .font(.caption)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            // Login button
            Button(action: viewModel.login) {
                Group {
                    if case .loading = viewModel.state {
                        ProgressView().tint(.white)
                    } else {
                        Text("Sign In").fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
            }
            .foregroundStyle(.white)
            .background(
                LinearGradient(
                    colors: viewModel.canSubmit
                        ? [Color(hex: "6C47FF"), Color(hex: "C850C0")]
                        : [Color.gray.opacity(0.4), Color.gray.opacity(0.4)],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .disabled(!viewModel.canSubmit)
            .animation(.easeInOut(duration: 0.2), value: viewModel.canSubmit)
        }
        .padding(24)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.07), radius: 20, y: 8)
        .animation(.easeInOut(duration: 0.2), value: viewModel.state == .idle)
    }

    // MARK: - Demo hint

    private var demoHintSection: some View {
        VStack(spacing: 8) {
            Button {
                withAnimation(.spring(response: 0.3)) { showDemoHint.toggle() }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: showDemoHint ? "chevron.up.circle" : "chevron.down.circle")
                    Text("Demo credentials")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            if showDemoHint {
                VStack(alignment: .leading, spacing: 6) {
                    credentialRow(icon: "person.fill", label: "End User", user: "user", pass: "user123")
                    credentialRow(icon: "shield.fill",  label: "Admin",    user: "admin", pass: "admin123")
                }
                .padding(14)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
    }

    private func credentialRow(icon: String, label: String, user: String, pass: String) -> some View {
        Button {
            viewModel.username = user
            viewModel.password = pass
        } label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(Color(hex: "6C47FF"))
                    .frame(width: 16)
                Text(label).font(.caption.bold())
                Spacer()
                Text("\(user) / \(pass)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fontDesign(.monospaced)
            }
        }
        .foregroundStyle(.primary)
    }
}

#Preview {
    LoginView()
        .environmentObject(SessionStore())
}
