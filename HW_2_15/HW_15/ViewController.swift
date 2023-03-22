
import UIKit
import GPUImage

class ViewController: UIViewController {
    
    @IBOutlet weak var fotoVideoView: UIView! // для фото / видо контента
    
    @IBOutlet weak var segmentedControlGet: UISegmentedControl! // переключаитель фото / видео
    
    // MARK: - segmentedControl
    var getIndex = Int()
    @IBAction func segmentedControlChoiceButton(_ sender: Any) { // думала про вариант менять видимость элементов переключателем (проще, но что то смущает)
        
        getIndex = segmentedControlGet.selectedSegmentIndex
        
        switch (getIndex) {
        case 0:
            removeContentView()
            segmentedControlChoiceButtonFoto()
        case 1:
            removeContentView()
            segmentedControlChoiceButtonVideo()
        default:
            break
        }
    }
    
    // segmented controller - foto
    var imageView = UIImageView()
    let image = UIImage(named: "fotoFruit.jpg")
    
    func segmentedControlChoiceButtonFoto() {
        imageView = UIImageView(image: image!)
        imageView.frame = fotoVideoView.bounds
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        fotoVideoView.addSubview(imageView)
    }
    
    // segmented controller - video
    
    let pathURL = URL(fileURLWithPath: Bundle.main.path(forResource: "videoFruit", ofType: "mp4")!)
    var player = AVPlayer()
    var playerLayer = AVPlayerLayer() // воспроизведение без фильтров (на слое)
    
    let filteredView = GPUImageView()
    var imageMovie = GPUImageMovie()
    
    func segmentedControlChoiceButtonVideo() {
        
        imageMovie.removeAllTargets()
        
        player = AVPlayer(url: pathURL)
        playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.frame = fotoVideoView.bounds
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        fotoVideoView.layer.addSublayer(playerLayer)
        
        player.play()
    }
    
    // delete content (foto / video)
    func removeContentView() {
        for contentView in fotoVideoView.subviews {
            contentView.removeFromSuperview()
        }
    }
    
    func removeVideoBeforeNewFilter(){
        
    }
    // MARK: - filter UIPickerView
    @IBOutlet weak var filterPicker: UIPickerView! // выбор фильтра
    
    let filterPickerData = ["No filter", "Color Adjustments", "Сombination of 3 filters", "Visual Effects", "Visual Effects of 2 filters", "LUT"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        self.filterPicker.delegate = self
        self.filterPicker.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        segmentedControlChoiceButtonFoto()
    }
  
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return filterPickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return filterPickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        
      
        
        switch (getIndex) {
        case 0:
            switch(row) {
            case 0:
                segmentedControlChoiceButtonFoto()
            case 1:
                fotoColorAbjustmentsSaturationFilter()
            case 2:
                fotoСombinationThreeFilters()
            case 3:
                fotoPosterizeFilter()
            case 4:
                fotoVisualEffectsTwoFilters()
            case 5:
                fotoLuts()
            default:
                break
            }
        case 1:
            switch(row) {
            case 0:
                segmentedControlChoiceButtonVideo()
            case 1:
                videoColorAbjustmentsSaturationFilter()
            case 2:
                videoСombinationThreeFilters()
            case 3:
                videoPosterizeFilter()
            case 4:
                videoVisualEffectsTwoFilters()
            case 5:
                videoLuts()
            default:
                break
            }
        default:
            break
        }

        
          // self.view.endEditing(true)
       }
}

// MARK: - filters

extension ViewController {
    
    // MARK: - foto filter 1
    func fotoColorAbjustmentsSaturationFilter() {
        print("Color Adjustments - foto")
       
        let picture = GPUImagePicture(image: image)
       
        let fotoSaturationFilter = GPUImageSaturationFilter() // saturation: The degree of saturation or desaturation to apply to the image (0.0 - 2.0, with 1.0 as the default)
        fotoSaturationFilter.saturation = 2.0
        
        picture?.addTarget(fotoSaturationFilter)
        fotoSaturationFilter.useNextFrameForImageCapture()
        picture?.processImage()
        imageView.image = fotoSaturationFilter.imageFromCurrentFramebuffer()
    }
    
    // MARK: - video filter 1
    func videoColorAbjustmentsSaturationFilter() {
        print("Color Adjustments - video")
        
        let playerItem = AVPlayerItem(url: pathURL)
        player.replaceCurrentItem(with: playerItem)
        imageMovie = GPUImageMovie(playerItem: playerItem)
        
        filteredView.frame = fotoVideoView.bounds
        filteredView.contentMode = .scaleAspectFill
    
        fotoVideoView.addSubview(filteredView)
        
        // определим что за фильтр и его параметр
        let filter = GPUImageSaturationFilter()
        filter.saturation = 2.0
        
        imageMovie.playAtActualSpeed = true
        imageMovie.addTarget(filter) // addTarget - добавляет цель для получения уведомлений о появлении новых кадров
        filter.addTarget(filteredView)
        imageMovie.startProcessing()
        player.play()
    }
    
    // MARK: - foto filter 2
    func fotoСombinationThreeFilters() {
        print("Сombination of 3 filters - foto")
        
        let picture = GPUImagePicture(image: image)
        let f1 = GPUImageEmbossFilter()
        f1.intensity = 0.3 // intensity: The strength of the embossing, from 0.0 to 4.0, with 1.0 as the normal level
        let f2 = GPUImagePolkaDotFilter()
        f2.fractionalWidthOfAPixel = 0.01 // fractionalWidthOfAPixel: How large the dots are, as a fraction of the width and height of the image (0.0 - 1.0, default 0.05)
        
        let f3 = GPUImageToonFilter()
        f3.quantizationLevels = 4.0 // quantizationLevels: The number of color levels to represent in the final image. Default is 10.0
        picture?.addTarget(f1)
        f1.addTarget(f2)
        f2.addTarget(f3)
        
        f3.useNextFrameForImageCapture()
        picture?.processImage()
        
        imageView.image = f3.imageFromCurrentFramebuffer()
    }
    // MARK: - video filter 2
    func videoСombinationThreeFilters() {
        print("Сombination of 3 filters - video")
        
        let playerItem = AVPlayerItem(url: pathURL)
        player.replaceCurrentItem(with: playerItem)
        imageMovie = GPUImageMovie(playerItem: playerItem)
        
        filteredView.frame = fotoVideoView.bounds
        filteredView.contentMode = .scaleAspectFill
    
        fotoVideoView.addSubview(filteredView)
        
        // определим что за фильтр и его параметр
        let f1 = GPUImageEmbossFilter()
        f1.intensity = 0.3
        let f2 = GPUImagePolkaDotFilter()
        f2.fractionalWidthOfAPixel = 0.01
        let f3 = GPUImageToonFilter()
        f3.quantizationLevels = 4.0
        imageMovie.addTarget(f1)
        f1.addTarget(f2)
        f2.addTarget(f3)
        
        imageMovie.playAtActualSpeed = true
        f3.addTarget(filteredView)
        
        imageMovie.startProcessing()
        player.play()
    }
    
    // MARK: - foto filter 3
    func fotoPosterizeFilter() {
        print("Visual Effects - foto")
       
        let picture = GPUImagePicture(image: image)
        let fotoPosterizeFilter = GPUImagePosterizeFilter() //colorLevels: The number of color levels to reduce the image space to. This ranges from 1 to 256, with a default of 10.
        fotoPosterizeFilter.colorLevels = 2
        picture?.addTarget(fotoPosterizeFilter)
        fotoPosterizeFilter.useNextFrameForImageCapture()
        picture?.processImage()
        imageView.image = fotoPosterizeFilter.imageFromCurrentFramebuffer()
    }
    // MARK: - video filter 3
    func videoPosterizeFilter() {
        print("Visual Effects - video")
       
        let playerItem = AVPlayerItem(url: pathURL)
        player.replaceCurrentItem(with: playerItem)
        imageMovie = GPUImageMovie(playerItem: playerItem)
        
        filteredView.frame = fotoVideoView.bounds
        filteredView.contentMode = .scaleAspectFill
    
        fotoVideoView.addSubview(filteredView)
        
        // определим что за фильтр и его параметр
        let fotoPosterizeFilter = GPUImagePosterizeFilter()
        fotoPosterizeFilter.colorLevels = 2
        
        imageMovie.playAtActualSpeed = true
        imageMovie.addTarget(fotoPosterizeFilter) // addTarget - добавляет цель для получения уведомлений о появлении новых кадров
        fotoPosterizeFilter.addTarget(filteredView)
        imageMovie.startProcessing()
        player.play()
    }

    // MARK: - foto filter 4
    func fotoVisualEffectsTwoFilters() {
        print("Visual Effects of 2 filters - foto")
        
        let picture = GPUImagePicture(image: image)
        
        let f1 = GPUImageSphereRefractionFilter()
        f1.center = CGPoint(x: 0.5, y: 0.5) // center: The center about which to apply the distortion, with a default of (0.5, 0.5)
        f1.radius = 1 // radius: The radius of the distortion, ranging from 0.0 to 1.0, with a default of 0.25
        f1.refractiveIndex = 2.5 // refractiveIndex: Индекс преломления для сферы по умолчанию 0,71
        
        let f2 = GPUImageHalftoneFilter()
        f2.fractionalWidthOfAPixel = 0.001 // fractionalWidthOfAPixel: How large the halftone dots are, as a fraction of the width and height of the image (0.0 - 1.0, default 0.05)
        
        picture?.addTarget(f1)
        f1.addTarget(f2)
        f2.useNextFrameForImageCapture()
        picture?.processImage()
        imageView.image = f2.imageFromCurrentFramebuffer()
    }
    
    // MARK: - video filter 4
    func videoVisualEffectsTwoFilters() {
        print("Visual Effects of 2 filters - video")
       
        let playerItem = AVPlayerItem(url: pathURL)
        player.replaceCurrentItem(with: playerItem)
        imageMovie = GPUImageMovie(playerItem: playerItem)
        
        filteredView.frame = fotoVideoView.bounds
        filteredView.contentMode = .scaleAspectFill
    
        fotoVideoView.addSubview(filteredView)
        
        // определим что за фильтр и его параметр
        let f1 = GPUImageSphereRefractionFilter()
        f1.center = CGPoint(x: 0.5, y: 0.5)
        f1.radius = 1
        f1.refractiveIndex = 2.5
        
        let f2 = GPUImageHalftoneFilter()
        f2.fractionalWidthOfAPixel = 0.001
        
        imageMovie.addTarget(f1)
        f1.addTarget(f2)
        
        imageMovie.playAtActualSpeed = true
        f2.addTarget(filteredView)
       
        imageMovie.startProcessing()
        player.play()
    }
    
    // MARK: - foto filter 5
    func fotoLuts() {
        print("LUT - foto")
        
        let picture = GPUImagePicture(image: image)
        let lut = GPUImagePicture(image: UIImage(named: "LUT"))!
        
        // так как LUT фильтр, тоже картинка, как и обрабатываемое изображение, то действуют немного другие правила
        let f = GPUImageLookupFilter()
        lut.addTarget(f, atTextureLocation: 1)
        picture!.addTarget(f, atTextureLocation: 0)
        
        f.useNextFrameForImageCapture() //фильтр применись
        
        lut.processImage()
        picture!.processImage()
        
        imageView.image = f.imageFromCurrentFramebuffer()
    }
    
    // MARK: - video filter 5
   
    func videoLuts() {
        print("LUT - video")

        let playerItem = AVPlayerItem(url: pathURL)
        player.replaceCurrentItem(with: playerItem)
        imageMovie = GPUImageMovie(playerItem: playerItem)

        filteredView.frame = fotoVideoView.bounds
        filteredView.contentMode = .scaleAspectFill

        fotoVideoView.addSubview(filteredView)

        // определим что за фильтр и его параметр
        let lut = GPUImagePicture(image: UIImage(named: "LUT"))!
        let filter = GPUImageLookupFilter()
        let filter2 = GPUImageFilter()

        lut.addTarget(filter, atTextureLocation: 0)
        
        filter.useNextFrameForImageCapture()

        lut.processImage()

        filter.addTarget(filter2, atTextureLocation: 1)
        imageMovie.addTarget(filter2, atTextureLocation: 2)


        filter2.addTarget(filteredView)
        imageMovie.startProcessing()
        player.play()
    }
    
//    func videoLuts() {
//        print("LUT - video")
//
//        let playerItem = AVPlayerItem(url: pathURL)
//        player.replaceCurrentItem(with: playerItem)
//        imageMovie = GPUImageMovie(playerItem: playerItem)
//
//        filteredView.frame = fotoVideoView.bounds
//        filteredView.contentMode = .scaleAspectFill
//
//        fotoVideoView.addSubview(filteredView)
//
//        // определим что за фильтр и его параметр
//        let lut = GPUImagePicture(image: UIImage(named: "LUT"))!
//        let filter = GPUImageLookupFilter()
//
//        lut.addTarget(filter, atTextureLocation: 1)
//        imageMovie.addTarget(filter, atTextureLocation: 0)
//
//        filter.useNextFrameForImageCapture()
//        lut.processImage()
//
//        imageMovie.playAtActualSpeed = true
//        imageMovie.addTarget(filter) // addTarget - добавляет цель для получения уведомлений о появлении новых кадров
//        filter.addTarget(filteredView)
//        imageMovie.startProcessing()
//        player.play()
//    }
    
//    func videoLuts() {
//        print("LUT - video")
//
//        let playerItem = AVPlayerItem(url: pathURL)
//        player.replaceCurrentItem(with: playerItem)
//        imageMovie = GPUImageMovie(playerItem: playerItem)
//
//        filteredView.frame = fotoVideoView.bounds
//        filteredView.contentMode = .scaleAspectFill
//
//        fotoVideoView.addSubview(filteredView)
//
//        // определим что за фильтр и его параметр
//        let lut = GPUImagePicture(image: UIImage(named: "LUT"))!
//        let filter = GPUImageLookupFilter()
//        let filter2 = GPUImageFilter()
//
//        lut.addTarget(filter, atTextureLocation: 0)
//        filter.useNextFrameForImageCapture()
//
//        lut.processImage()
//
//        filter.addTarget(filter2, atTextureLocation: 1)
//        imageMovie.addTarget(filter2, atTextureLocation: 2)
//
//
//      //  imageMovie.addTarget(filter)
//        filter2.addTarget(filteredView)
//        imageMovie.startProcessing()
//        player.play()
//    }
}
