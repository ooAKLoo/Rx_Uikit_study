//
//  VideoGestureHandler.swift
//  Rx_Uikit_study
//
//  Created by 杨东举 on 2025/5/4.
//


import UIKit
import AVFAudio

class VideoGestureHandler: NSObject, UIGestureRecognizerDelegate {
    weak var delegate: GestureHandlerDelegate?
    
    enum GestureType {
        case seek
        case brightness
        case volume
        case speed
        case none
    }
    
    private var currentGestureType: GestureType = .none
    private var panStartPoint: CGPoint?
    private var totalSeekOffset: Double = 0
    private var initialBrightness: CGFloat = 0
    private var initialVolume: Float = 0
    private var initialSpeed: Float = 1.0
    private var currentSpeed: Float = 1.0
    private var isLongPressing: Bool = false
    
    private var lastUsedSpeed: Float = PlayerConfiguration.Gesture.initialSpeedMultiplier // 默认值
    
    func setupGestures(on view: UIView) -> [UIGestureRecognizer] {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        
        singleTap.numberOfTapsRequired = 1
        doubleTap.numberOfTapsRequired = 2
        longPress.minimumPressDuration = PlayerConfiguration.Gesture.longPressDuration
        
        singleTap.require(toFail: doubleTap)
        
        longPress.delegate = self
        pan.delegate = self
        
        return [singleTap, doubleTap, longPress, pan]
    }
    
    @objc private func handleSingleTap(_ gesture: UITapGestureRecognizer) {
        delegate?.didToggleControls()
        delegate?.didBeginGesture(currentGestureType)
    }
    
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        delegate?.didTogglePlayPause()
        delegate?.didBeginGesture(currentGestureType)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            delegate?.didBeginGesture(currentGestureType)
            isLongPressing = true
            initialSpeed = lastUsedSpeed
            currentSpeed = initialSpeed
            // 使用统一的方法，一次性处理UI隐藏和速度显示
            delegate?.didStartSpeedAdjustment(initialSpeed: currentSpeed)
            //            delegate?.didUpdateSpeed(currentSpeed)
        case .ended, .cancelled:
            isLongPressing = false
            // 保存当前速度值以供下次使用
            lastUsedSpeed = currentSpeed
            // 先结束手势调整（隐藏指示器）
            delegate?.didEndGestureAdjustment(.speed)
            // 然后才恢复正常速度
            delegate?.didUpdateSpeedWithoutIndicator(PlayerConfiguration.Speed.normal)
        default:
            break
        }
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: gesture.view)
        let location = gesture.location(in: gesture.view)
        
        switch gesture.state {
        case .began:
            delegate?.didBeginGesture(currentGestureType)
            panStartPoint = location
            totalSeekOffset = 0
            
            if isLongPressing {
                currentGestureType = .speed
                initialSpeed = currentSpeed
            } else {
                currentGestureType = .none
                initialBrightness = UIScreen.main.brightness
                let audioSession = AVAudioSession.sharedInstance()
                initialVolume = audioSession.outputVolume
            }
            
        case .changed:
            if isLongPressing {
                handleSpeedAdjustment(translation: translation)
            } else {
                handleNormalPan(translation: translation, location: location, in: gesture.view!)
            }
            
        case .ended, .cancelled:
            
            if isLongPressing {
                // 保存当前调整后的速度
                lastUsedSpeed = currentSpeed
            }
            
            if !isLongPressing {
                completeGesture()
                
                if currentGestureType != .none {
                    delegate?.didEndGestureAdjustment(currentGestureType)
                }
            }
            resetGestureState()
            
        default:
            break
        }
    }
    
    private func handleSpeedAdjustment(translation: CGPoint) {
        delegate?.didBeginGesture(currentGestureType)
        let speedDelta = Float(translation.x) / PlayerConfiguration.Gesture.speedAdjustmentRate
        let newSpeed = initialSpeed + speedDelta
        currentSpeed = min(PlayerConfiguration.Speed.maximum, max(PlayerConfiguration.Speed.minimum, newSpeed))
        delegate?.didUpdateSpeed(currentSpeed)
    }
    
    private func handleNormalPan(translation: CGPoint, location: CGPoint, in view: UIView) {
        delegate?.didBeginGesture(currentGestureType)
        if currentGestureType == .none {
            determineGestureType(translation: translation, location: location, in: view)
        }
        
        switch currentGestureType {
        case .seek:
            handleSeekGesture(translation: translation)
        case .brightness:
            handleBrightnessGesture(translation: translation, in: view)
        case .volume:
            handleVolumeGesture(translation: translation, in: view)
        default:
            break
        }
    }
    
    private func determineGestureType(translation: CGPoint, location: CGPoint, in view: UIView) {
        guard abs(translation.x) > PlayerConfiguration.Gesture.minimumPanThreshold ||
                abs(translation.y) > PlayerConfiguration.Gesture.minimumPanThreshold else { return }
        
        if abs(translation.x) > abs(translation.y) {
            currentGestureType = .seek
        } else {
            let isLeftSide = location.x < view.bounds.width / 2
            currentGestureType = isLeftSide ? .brightness : .volume
        }
    }
    
    private func handleSeekGesture(translation: CGPoint) {
        let offset = Double(translation.x) / 100.0 * PlayerConfiguration.Gesture.seekOffsetMultiplier
        totalSeekOffset = offset
        
        // 实时通知delegate显示indicator
        delegate?.didUpdateSeekOffset(offset)
    }
    
    private func handleBrightnessGesture(translation: CGPoint, in view: UIView) {
        let deltaY = translation.y / view.bounds.height
        let newBrightness = max(0, min(1, initialBrightness - deltaY))
        UIScreen.main.brightness = newBrightness
        delegate?.didUpdateBrightness(Float(newBrightness))
    }
    
    private func handleVolumeGesture(translation: CGPoint, in view: UIView) {
        let deltaY = translation.y / view.bounds.height
        let newVolume = max(0, min(1, initialVolume - Float(deltaY)))
        delegate?.didUpdateVolume(newVolume)
    }
    
    private func completeGesture() {
        switch currentGestureType {
        case .seek:
            if abs(totalSeekOffset) > 1.0 {
                delegate?.didRequestSeek(offset: totalSeekOffset)
            }
        default:
            break
        }
    }
    
    private func resetGestureState() {
        panStartPoint = nil
        totalSeekOffset = 0
        currentGestureType = .none
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
