//
//  ContentView.swift
//  SafeSpace
//
//  Created by Aryan Neb on 2025-02-08.
//

import SwiftUI

struct ContentView: View {
    // A flag to track if the model is downloaded.
    @State private var modelDownloaded: Bool = Bot.isModelDownloaded
    // Download manager to handle downloading.
    @StateObject var downloadManager = DownloadManager()
    // BotWrapper to initialize and interact with the Bot.
    @StateObject var botWrapper = BotWrapper()
    @State private var inputText: String = ""
    
    var body: some View {
        Group {
            if !modelDownloaded {
                // Show the download UI.
                DownloadModelView()
                    .onAppear {
                        // Set the download manager’s completion closure.
                        downloadManager.onDownloadComplete = {
                            modelDownloaded = true
                            Task {
                                await botWrapper.initializeBotIfPossible()
                            }
                        }
                    }
            } else {
                // Show the chat interface.
                VStack {
                    if botWrapper.isLoading {
                        ProgressView("Loading Model...")
                            .padding()
                    } else {
                        ScrollView {
                            Text(botWrapper.output)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        HStack {
                            TextField("Enter your message", text: $inputText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                            Button(action: {
                                Task {
                                    await botWrapper.send(text: inputText)
                                    inputText = ""
                                }
                            }) {
                                Image(systemName: "paperplane.fill")
                                    .font(.title2)
                            }
                            .padding(.trailing)
                        }
                        .padding(.vertical)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            // If the model is already downloaded, ensure our flag is up-to-date.
            modelDownloaded = Bot.isModelDownloaded
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
