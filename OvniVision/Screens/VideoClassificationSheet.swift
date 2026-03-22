//
//  VideoClassificationSheet.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/21/26.
//

import SwiftUI

struct VideoClassificationSheet: View {
    let video: AppVideo
    @Environment(VideosRepository.self) var videosApi
    @Environment(\.dismiss) private var dismiss
    
    @State private var selected: Set<VideoClassification> = []
    
    var body: some View {
        VStack {
            List(VideoClassification.allCases, id: \.self) { classification in
                Button {
                    if selected.contains(classification) {
                        selected.remove(classification)
                    } else {
                        selected.insert(classification)
                    }
                } label: {
                    HStack {
                        if selected.contains(classification) {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.blue)
                                .padding(.horizontal, 16)
                            
                            Text(classification.displayName.uppercased())
                                .foregroundStyle(.primary)
                                .fontWeight(.semibold)
                            
                        } else {
                            Image(systemName: "circlebadge")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .fontWeight(.thin)
                                .foregroundStyle(.gray)
                                .padding(.horizontal, 16)
                            
                            Text(classification.displayName.uppercased())
                                .foregroundStyle(.gray)
                            
                        }
                    }
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
            
            Button {
                videosApi.setClassifications(video, classifications: selected)
                dismiss()
            } label: {
                Text("SAVE")
                    .font(.custom("JetBrainsMono-Regular", size: 18))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .tint(.blue)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .safeAreaBar(edge: .top) {
            ZStack {
                HStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 16).overlay {
                        Text("CLASSIFICATION")
                            .font(.custom("JetBrainsMono-Regular", size: 16))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 180, height: 35)
                    .foregroundStyle(.ultraThickMaterial)
                }
                
                HStack {
                    Spacer()
                    Button {
                        dismiss()
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
        .onAppear {
            selected = videosApi.videos.first(where: { $0.id == video.id })?.classifications ?? video.classifications
        }
        
        .ignoresSafeArea()
    }
}

#Preview {
    let mockVideo = AppVideo(
        id: 1, name: "Preview", createdAt: Date(),
        duration: 0, thumbnail: nil,
        fileURL: URL(fileURLWithPath: ""),
        classifications: [.ufo, .uav]
    )
    VideoClassificationSheet(video: mockVideo)
        .environment(VideosRepository.shared)
}
