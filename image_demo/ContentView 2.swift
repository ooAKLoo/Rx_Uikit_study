//
//  ContentView 2.swift
//  Rx_Uikit_study
//
//  Created by 杨东举 on 2025/5/16.
//


import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var isPickerShowing = false
    @State private var isUploading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var imageTitle = ""
    @State private var uploadedImages: [ImageInfo] = []
    
    // 服务器地址
    private let serverUrl = "http://192.168.1.8:8080" // 请替换为你的服务器IP地址
    
    var body: some View {
        NavigationStack {
            VStack {
                // 标题输入
                TextField("图片标题", text: $imageTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                // 选择的图片预览
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .padding()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 300)
                        .overlay(
                            Text("无选中图片")
                                .foregroundColor(.gray)
                        )
                        .padding()
                }
                
                // 按钮区域
                HStack {
                    // 选择图片按钮
                    Button(action: {
                        isPickerShowing = true
                    }) {
                        Text("选择图片")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    // 上传按钮
                    Button(action: {
                        print("上传按钮被点击")
                        uploadImage()
                    }) {
                        Text("上传图片")
                            .padding()
                            .background(selectedImage != nil ? Color.green : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
//                    .disabled(selectedImage == nil || isUploading || imageTitle.isEmpty)
                }
                .padding()
                
                if isUploading {
                    ProgressView("上传中...")
                        .padding()
                }
                
                // 已上传图片列表
                List {
                    ForEach(uploadedImages) { imageInfo in
                        VStack(alignment: .leading) {
                            Text(imageInfo.title)
                                .font(.headline)
                            Text("ID: \(imageInfo.id)")
                                .font(.caption)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("图片上传")
            .sheet(isPresented: $isPickerShowing) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .alert("提示", isPresented: $showAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                print("ContentView已加载")
            }
        }
    }
    
    // 上传图片到服务器
    func uploadImage() {
        guard let selectedImage = selectedImage, !imageTitle.isEmpty else { 
            print("没有选择图片或标题为空")
            return 
        }
        
        print("开始上传图片，标题: \(imageTitle)")
        isUploading = true
        
        // 将图片转换为JPEG数据
        guard let imageData = selectedImage.jpegData(compressionQuality: 0.8) else {
            print("图片转换JPEG失败")
            showAlert(message: "图片转换失败")
            isUploading = false
            return
        }
        
        print("图片大小: \(imageData.count / 1024) KB")
        
        // 创建multipart请求
        let boundary = UUID().uuidString
        let urlString = "\(serverUrl)/api/images?title=\(imageTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        print("请求URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("URL创建失败: \(urlString)")
            showAlert(message: "URL创建失败")
            isUploading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        print("准备构建请求体")
        // 准备请求体
        var body = Data()
        
        // 添加文件部分
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // 结束请求体
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        print("请求体大小: \(body.count / 1024) KB")
        
        // 输出完整请求内容
        print("请求方法: \(request.httpMethod ?? "未设置")")
        if let headers = request.allHTTPHeaderFields {
            print("请求头: \(headers)")
        }
        
        // 输出请求体前100字节的十六进制表示(用于调试)
        let bodyPreview = body.prefix(100)
        let hexString = bodyPreview.map { String(format: "%02x", $0) }.joined(separator: " ")
        print("请求体前100字节: \(hexString)")
        
        print("开始发送网络请求...")
        // 发送请求
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isUploading = false
                print("网络请求完成")
                
                if let error = error {
                    print("上传错误: \(error.localizedDescription)")
                    showAlert(message: "上传失败: \(error.localizedDescription)")
                    return
                }
                
                // 检查HTTP响应
                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTP状态码: \(httpResponse.statusCode)")
                    print("HTTP响应头: \(httpResponse.allHeaderFields)")
                    
                    // 检查非成功状态码
                    if httpResponse.statusCode < 200 || httpResponse.statusCode >= 300 {
                        print("HTTP错误: 状态码 \(httpResponse.statusCode)")
                        
                        // 尝试解析错误信息
                        if let data = data, let errorText = String(data: data, encoding: .utf8) {
                            print("服务器错误响应: \(errorText)")
                            showAlert(message: "服务器返回错误: \(errorText)")
                        } else {
                            showAlert(message: "服务器返回错误状态码: \(httpResponse.statusCode)")
                        }
                        return
                    }
                }
                
                guard let data = data else {
                    print("服务器没有返回数据")
                    showAlert(message: "服务器没有返回数据")
                    return
                }
                
                print("收到数据大小: \(data.count) 字节")
                
                // 尝试打印服务器响应的原始文本
                if let responseText = String(data: data, encoding: .utf8) {
                    print("服务器响应: \(responseText)")
                }
                
                do {
                    let imageInfo = try JSONDecoder().decode(ImageInfo.self, from: data)
                    print("解析成功: \(imageInfo)")
                    uploadedImages.append(imageInfo)
                    self.selectedImage = nil
                    imageTitle = ""
                    showAlert(message: "上传成功")
                } catch {
                    print("JSON解析错误: \(error)")
                    print("尝试解析的JSON数据: \(String(data: data, encoding: .utf8) ?? "无法解码为文本")")
                    showAlert(message: "解析响应失败: \(error.localizedDescription)")
                }
            }
        }
        
        // 开始任务
        task.resume()
        print("网络请求已发起")
    }
    
    func showAlert(message: String) {
        alertMessage = message
        showAlert = true
        print("显示警告: \(message)")
    }
}

// 图片信息模型
struct ImageInfo: Codable, Identifiable {
    let id: String
    let title: String
    let filename: String
    let description: String?
    let width: Int?
    let height: Int?
    let created_at: String
}

// 图片选择器
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // 不需要实现
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            print("图片选择器: 已选择图片")
            
            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else {
                print("图片选择器: 没有选择图片或不支持的格式")
                return
            }
            
            provider.loadObject(ofClass: UIImage.self) { image, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("图片选择器: 加载图片错误 \(error)")
                    } else if let image = image as? UIImage {
                        print("图片选择器: 成功加载图片, 尺寸: \(image.size)")
                        self.parent.selectedImage = image
                    } else {
                        print("图片选择器: 加载的对象不是UIImage")
                    }
                }
            }
        }
    }
}
