数据流程：
1. VideoPlayerViewModel 产生播放进度
2. → VideoPlayerViewController
3. → controlsView.updateProgress()
4. → progressSubject
5. → VideoControlsViewModel
6. → progressSlider.rx.value
b. 用户手动拖动
当用户拖动滑块时，UISlider 自身会更新 value 属性，这会自动触发 progressSlider.rx.value 的变化，从而触发 input.seekTo。

如果用户正在手动拖动，那么应该屏蔽VideoPlayerViewModel触发的progressSlider.rx.value，否则进度条会抖动
