//
//  VideoControlsViewPreview.swift
//  Rx_Uikit_study
//
//  Created by 杨东举 on 2025/5/3.
//


import SwiftUI
import UIKit
import RxSwift
import RxCocoa

struct VideoControlsViewPreview: UIViewRepresentable {
    
    class Coordinator {
        let disposeBag = DisposeBag()
        var timer: Timer?
        var isPlaying = false
        var currentProgress: Float = 0.0
        
        func simulateVideoPlayback(controlsView: VideoControlsView) {
            // 设置初始状态
            controlsView.updatePlayingState(false)
            controlsView.updateTime(current: "00:00", duration: "05:00")
            controlsView.updateProgress(0.0)
            
            // 模拟播放进度更新
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self, self.isPlaying else { return }
                
                self.currentProgress += 0.001
                if self.currentProgress > 1.0 {
                    self.currentProgress = 0.0
                }
                
                let currentSeconds = Int(self.currentProgress * 300)
                let currentTime = String(format: "%02d:%02d", currentSeconds / 60, currentSeconds % 60)
                
                controlsView.updateTime(current: currentTime, duration: "05:00")
                controlsView.updateProgress(self.currentProgress)
            }
        }
        
        func togglePlayPause(controlsView: VideoControlsView) {
            isPlaying.toggle()
            controlsView.updatePlayingState(isPlaying)
        }
        
        deinit {
            timer?.invalidate()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> VideoControlsView {
        let controlsView = VideoControlsView()
        
        // 绑定事件
        controlsView.playPauseTapped
            .subscribe(onNext: { _ in
                context.coordinator.togglePlayPause(controlsView: controlsView)
            })
            .disposed(by: context.coordinator.disposeBag)
        
        controlsView.sliderSeekTo
            .subscribe(onNext: { value in
                print("进度条拖拽到: \(value)")
                // 更新当前进度
                context.coordinator.currentProgress = value
            })
            .disposed(by: context.coordinator.disposeBag)
        
        // 开始模拟
        context.coordinator.simulateVideoPlayback(controlsView: controlsView)
        
        return controlsView
    }
    
    func updateUIView(_ uiView: VideoControlsView, context: Context) {
        // 如果需要更新视图的话可以在这里实现
    }
}

struct VideoControlsView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.yellow
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                VideoControlsViewPreview()
                    .frame(height: 80)
                    .padding(.bottom, 20)
            }
        }
        .previewLayout(.fixed(width: 375, height: 200))
    }
}
