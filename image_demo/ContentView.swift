//import SwiftUI
//import PhotosUI
//
//struct ContentView: View {
//    @State private var selectedImage: UIImage?
//    @State private var isPickerShowing = false
//    @State private var isUploading = false
//    @State private var showAlert = false
//    @State private var alertMessage = ""
//    @State private var imageTitle = ""
//    @State private var uploadedImages: [ImageInfo] = []
//    
//    // 服务器地址
//    private let serverUrl = "http://192.168.1.8:8080" // 请替换为你的服务器IP地址
//    
//    var body: some View {
//        NavigationStack {
//            VStack {
//                // 标题输入
//                TextField("图片标题", text: $imageTitle)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding()
//                
//                // 选择的图片预览
//                if let selectedImage = selectedImage {
//                    Image(uiImage: selectedImage)
//                        .resizable()
//                        .scaledToFit()
//                        .frame(height: 300)
//                        .padding()
//                } else {
//                    Rectangle()
//                        .fill(Color.gray.opacity(0.3))
//                        .frame(height: 300)
//                        .overlay(
//                            Text("无选中图片")
//                                .foregroundColor(.gray)
//                        )
//                        .padding()
//                }
//                
//                // 按钮区域
//                HStack {
//                    // 选择图片按钮
//                    Button(action: {
//                        isPickerShowing = true
//                    }) {
//                        Text("选择图片")
//                            .padding()
//                            .background(Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(8)
//                    }
//                    
//                    // 上传按钮
//                    Button(action: {
//                        uploadImage()
//                    }) {
//                        Text("上传图片")
//                            .padding()
//                            .background(selectedImage != nil ? Color.green : Color.gray)
//                            .foregroundColor(.white)
//                            .cornerRadius(8)
//                    }
//                    .disabled(selectedImage == nil || isUploading || imageTitle.isEmpty)
//                }
//                .padding()
//                
//                if isUploading {
//                    ProgressView("上传中...")
//                        .padding()
//                }
//                
//                // 已上传图片列表
//                List {
//                    ForEach(uploadedImages) { imageInfo in
//                        VStack(alignment: .leading) {
//                            Text(imageInfo.title)
//                                .font(.headline)
//                            Text("ID: \(imageInfo.id)")
//                                .font(.caption)
//                        }
//                    }
//                }
//                .listStyle(PlainListStyle())
//            }
//            .navigationTitle("图片上传")
//            .sheet(isPresented: $isPickerShowing) {
//                ImagePicker(selectedImage: $selectedImage)
//            }
//            .alert("提示", isPresented: $showAlert) {
//                Button("确定", role: .cancel) { }
//            } message: {
//                Text(alertMessage)
//            }
//        }
//    }
//    
//    // 上传图片到服务器
//    func uploadImage() {
//        guard let selectedImage = selectedImage, !imageTitle.isEmpty else { return }
//        
//        isUploading = true
//        
//        // 将图片转换为JPEG数据
//        guard let imageData = selectedImage.jpegData(compressionQuality: 0.8) else {
//            showAlert(message: "图片转换失败")
//            isUploading = false
//            return
//        }
//        
//        // 创建multipart请求
//        let boundary = UUID().uuidString
//        let url = URL(string: "\(serverUrl)/api/images?title=\(imageTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        
//        // 准备请求体
//        var body = Data()
//        
//        // 添加文件部分
//        body.append("--\(boundary)\r\n".data(using: .utf8)!)
//        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
//        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
//        body.append(imageData)
//        body.append("\r\n".data(using: .utf8)!)
//        
//        // 结束请求体
//        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
//        
//        request.httpBody = body
//        
//        // 发送请求
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            DispatchQueue.main.async {
//                isUploading = false
//                
//                if let error = error {
//                    showAlert(message: "上传失败: \(error.localizedDescription)")
//                    return
//                }
//                
//                guard let data = data else {
//                    showAlert(message: "服务器没有返回数据")
//                    return
//                }
//                
//                do {
//                    let imageInfo = try JSONDecoder().decode(ImageInfo.self, from: data)
//                    uploadedImages.append(imageInfo)
//                    // 修复这里的问题 - selectedImage是可选类型，可以赋值为nil
//                    self.selectedImage = nil
//                    imageTitle = ""
//                    showAlert(message: "上传成功")
//                } catch {
//                    showAlert(message: "解析响应失败: \(error.localizedDescription)")
//                }
//            }
//        }.resume()
//    }
//    
//    func showAlert(message: String) {
//        alertMessage = message
//        showAlert = true
//    }
//}
//
//// 图片信息模型
//struct ImageInfo: Codable, Identifiable {
//    let id: String
//    let title: String
//    let filename: String
//    let description: String?
//    let width: Int?
//    let height: Int?
//    let created_at: String
//}
//
//// 图片选择器
//struct ImagePicker: UIViewControllerRepresentable {
//    @Binding var selectedImage: UIImage?
//    @Environment(\.presentationMode) var presentationMode
//    
//    func makeUIViewController(context: Context) -> PHPickerViewController {
//        var configuration = PHPickerConfiguration()
//        configuration.filter = .images
//        configuration.selectionLimit = 1
//        
//        let picker = PHPickerViewController(configuration: configuration)
//        picker.delegate = context.coordinator
//        return picker
//    }
//    
//    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
//        // 不需要实现
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    class Coordinator: NSObject, PHPickerViewControllerDelegate {
//        let parent: ImagePicker
//        
//        init(_ parent: ImagePicker) {
//            self.parent = parent
//        }
//        
//        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//            parent.presentationMode.wrappedValue.dismiss()
//            
//            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else {
//                return
//            }
//            
//            provider.loadObject(ofClass: UIImage.self) { image, error in
//                DispatchQueue.main.async {
//                    self.parent.selectedImage = image as? UIImage
//                }
//            }
//        }
//    }
//}
