//
//  SettingsScreen.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/21/26.
//

import SwiftUI

struct SettingsScreen: View {
    @Binding var isPresented: Bool
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent {
                        Text(appVersion)
                            .font(.custom("JetBrainsMono-Regular", size: 14))
                            .foregroundStyle(.orange)
                    } label: {
                        Label("Version", systemImage: "app.badge")
                            .foregroundStyle(.gray)
                    }
                    
                    LabeledContent {
                        Text(buildNumber)
                            .font(.custom("JetBrainsMono-Regular", size: 14))
                            .foregroundStyle(.orange)
                    } label: {
                        Label("Build", systemImage: "hammer")
                            .foregroundStyle(.gray)
                    }
                } header: {
                    Text("About")
                        .font(.custom("JetBrainsMono-Regular", size: 16))
                }
                
                Section {
                    Link(destination: URL(string: "https://www.uvcodex.com/ovnivision/privacy-policy")!) {
                        Label {
                            Text("Privacy Policy")
                        } icon: {
                            Image(systemName: "hand.raised").foregroundStyle(.gray)
                        }
                    }
                    Link(destination: URL(string: "https://www.uvcodex.com/ovnivision/terms-of-service")!) {
                        Label {
                            Text("Terms of Service")
                        } icon: {
                            Image(systemName: "doc.text").foregroundStyle(.gray)
                        }
                    }
                } header: {
                    Text("Legal")
                        .font(.custom("JetBrainsMono-Regular", size: 16))
                }
            }
            .listStyle(.insetGrouped)
            .font(.custom("JetBrainsMono-Regular", size: 14))
            .safeAreaBar(edge: .top) {
                ZStack {
                    HStack {
                        Text("SETTINGS")
                            .font(.custom("JetBrainsMono-Regular", size: 16))
                    }
                    
                    HStack {
                        Spacer()
                        Button {
                            isPresented.toggle()
                        } label: {
                            Image(systemName: "xmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                                .foregroundStyle(.pink)
                                .padding(7.5)
                        }
                        .tint(.red)
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.circle)
                        .frame(width: 35, height: 35)
                    }
                }
                .padding(16)
            }
        }
    }
}

#Preview {
    SettingsScreen(isPresented: .constant(true))
}
