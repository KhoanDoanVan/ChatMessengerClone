//
//  CurrentLocationSheet.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 23/9/24.
//

import SwiftUI
import MapKit

struct CurrentLocationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var search: String = ""
    @StateObject private var viewModel = CurrentLocationSheetViewModel()
    @State private var cameraPosition: MapCameraPosition = .region(.userRegion)
    @State private var tapSearch: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchable()
                Spacer()
                if !tapSearch {
                    VStack {
                        map()
                        startShareButton()
                    }
                }
            }
            .padding(8)
            .navigationTitle("Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                doneButton()
            }
        }
    }
    
    /// Map display
    private func map() -> some View {
        Map(position: $cameraPosition) {
            Annotation("Your location", coordinate: viewModel.location) {
                ZStack {
                    Circle()
                        .frame(width: 25, height: 25)
                        .foregroundStyle(.white)
                        .clipShape(Circle())
                        .overlay {
                            Circle()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.blue)
                                .clipShape(Circle())
                        }
                }
            }
        }
        .overlay {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Button {
                            
                        } label: {
                            Image(systemName: "mappin")
                                .padding(10)
                                .font(.title)
                                .foregroundStyle(.black)
                                .background(Color(.systemBlue))
                                .clipShape(Circle())
                        }
                        Button {
                            
                        } label: {
                            Image(systemName: "location.fill")
                                .padding(10)
                                .font(.title2)
                                .foregroundStyle(.black)
                                .background(Color(.systemBlue))
                                .clipShape(Circle())
                        }
                    }
                    .padding()
                }
            }
        }
        .clipShape(
            .rect(cornerRadius: 20)
        )
        .onAppear {
            viewModel.checkIfLocationServicesIsEnable()
        }
    }
    
    /// Searchable
    private func searchable() -> some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("", text: $search, prompt: Text("Find a place or address").bold())
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .clipShape(
            .rect(cornerRadius: 10)
        )
    }
    
    /// Done Button
    private func doneButton() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                dismiss()
            } label: {
                Text("Done")
                    .bold()
            }
        }
    }
    
    /// Share button
    private func startShareButton() -> some View {
        Button {
            
        } label: {
            Text("Start sharing live location")
                .bold()
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white)
                .padding(.vertical, 10)
                .background(Color(.systemBlue))
                .clipShape(
                    .rect(cornerRadius: 10)
                )
        }
    }
}

#Preview {
    NavigationStack {
        CurrentLocationSheet()
    }
}
