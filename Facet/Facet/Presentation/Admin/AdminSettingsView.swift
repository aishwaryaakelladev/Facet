internal import SwiftUI

struct AdminSettingsView: View {
    // Persisted via UserDefaults — swap for Keychain in production
    @AppStorage("facet_gist_id")    var gistId:      String = ""
    @AppStorage("facet_github_pat") var githubToken: String = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                gistSection
                tokenSection
                howToSection
            }
            .navigationTitle("Admin Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.fontWeight(.semibold)
                }
            }
        }
    }

    private var gistSection: some View {
        Section {
            TextField("e.g. abc123def456", text: $gistId)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        } header: {
            Text("GitHub Gist ID")
        } footer: {
            Text("Found in the URL: gist.github.com/username/**GIST_ID**")
        }
    }

    private var tokenSection: some View {
        Section {
            SecureField("ghp_xxxxxxxxxxxxxxxxxxxx", text: $githubToken)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        } header: {
            Text("GitHub Personal Access Token")
        } footer: {
            Text("Create at GitHub → Settings → Developer Settings → Tokens (classic). Requires **gist** scope only.")
        }
    }

    private var howToSection: some View {
        Section("How it works") {
            Label("Publish sends a PATCH to the GitHub Gist API", systemImage: "arrow.up.circle")
            Label("End users see changes instantly — no App Store update", systemImage: "bolt.circle")
            Label("Token is stored locally on this device only", systemImage: "lock.circle")
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
    }
}

#Preview {
    AdminSettingsView()
}
