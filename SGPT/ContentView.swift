//
//  ContentView.swift
//  SGPT
//
//  Created by HoJun Lee on 2023/03/03.
//

import SwiftUI
import CoreData
import AVFoundation
import DeclarativeConnectKit

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    @State var audioPlayer: AVAudioPlayer?
    @State var someText = "Text is displayed here..."
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text(someText)
                Spacer()
                Button {
                    do {
                        if let fileURL = Bundle.main.url(forResource: "JUNGIN", withExtension: "mp3"){
                            
                            let audioData = try Data(contentsOf: fileURL)
                            let audioFilename = fileURL.lastPathComponent
                            
                            let param: Params = ["model": "whisper-1"]
                            let attachedData = MultipartData(name: "file", fileData: audioData, fileName: audioFilename, mimeType: "audio/mp3")
                            
                            Task {
                                do {
                                    let dispatcher = DeclarativeConnectKit(baseURL: "https://api.openai.com")
                                    let dispatchObject = Whisper.transcriptions(body: param, multipartData: [attachedData])
                                    let value = try await dispatcher.dispatch(dispatchObject)
                                    someText = value.text
                                }
                                catch {
                                    print("request error")
                                }
                            }
                        }
                    }
                    catch {
                        print("error: \(error.localizedDescription)")
                    }
                } label: {
                    Text("Network")
                }
                Spacer()
                Spacer()
            }
            .task {
//                do {
////                    let response = try await sendOpenAIRequest()
//                    let response = try await sendOpenAIWhisperRequest()
//                    print(response)
//                    self.someText = response
//                } catch {
//                    print("Error: \(error)")
//                }
            }
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

extension ContentView {
    func sendOpenAIRequest() async throws -> String {
        
        let requestBody: Params = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "user", "content": "외로운 밤에 읽을 만한 시 써줘"]
            ]
        ]
        
        let dispatcher = DeclarativeConnectKit(baseURL: "https://api.openai.com")
        let dispatchObject = GPT.ChatCompletion(body: requestBody)
        let value = try await dispatcher.dispatch(dispatchObject)
        print(value)
        return value.choices.first?.message.content ?? "empty"
    }
    
    func sendOpenAIWhisperRequest() async throws -> String {
        // 요청 생성
        let url = URL(string: "https://api.openai.com/v1/audio/transcriptions")!
        
        do {
            if let fileURL = Bundle.main.url(forResource: "JUNGIN", withExtension: "mp3") {
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("Bearer \(SGPTApp.authenticationKey)", forHTTPHeaderField: "Authorization")
                let boundary = UUID().uuidString
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

                // HTTP body 생성
                var body = Data()
                let modelField = "model"
                let modelValue = "whisper-1"
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(modelField)\"\r\n\r\n".data(using: .utf8)!)
                body.append("\(modelValue)\r\n".data(using: .utf8)!)
                let fileField = "file"
                let fileName = fileURL.lastPathComponent
                let fileData = try Data(contentsOf: fileURL)
                let fileType = "audio/mpeg"
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(fileField)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: \(fileType)\r\n\r\n".data(using: .utf8)!)
                body.append(fileData)
                body.append("\r\n".data(using: .utf8)!)
                body.append("--\(boundary)--\r\n".data(using: .utf8)!)
                request.httpBody = body

                // URLSession을 사용하여 요청 보내기
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw NSError(domain: NSURLErrorDomain, code: NSURLErrorBadServerResponse, userInfo: nil)
                }
                let openAIResponse = try JSONDecoder().decode(Whisper.self, from: data)
                return openAIResponse.text
            } else {
                print("fileURL error")
            }
        }
        catch {
            print("fileURL error")
        }
        return "fail to whisper"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
