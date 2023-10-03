//
//  ResultViewController.swift
//  OcrStudyCase
//
//  Created by Omer on 3.10.2023.
//

import UIKit

class ResultViewController: UIViewController {

    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var resultWordsTextView: UITextView!
    @IBOutlet weak var resultTitleLabel: UILabel!
    @IBOutlet weak var takenPhotoImageView: UIImageView!
    var activityIndicator: UIActivityIndicatorView!
    var yourScore:String?
    var score = 0
    var scoreRate = 10

    private lazy var resultViewModel: ResultViewModelProtocol = {
        return ResultViewModel()
    }()
    var resultImage: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        initVM()
        applyOCRForImage()
        // Do any additional setup after loading the view.
    }
    
    private func initView() {
        guard let resultImage = resultImage else { return }
        takenPhotoImageView.image = resultImage
        setupActivityIndicator()
    }

    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator.tintColor = UIColor.darkGray
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    private func initVM() {
        
        yourScore = scoreLabel.text
        scoreLabel.text! = " \(String(describing: yourScore))  \(String(score))"
        resultViewModel.callbackFoundText = { [weak self] resultText in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.resultWordsTextView.text = resultText
               print("Bulunan Yazılar \(resultText)")
             let matchedWords = self.resultViewModel.matchSearchWordBetweenDetectWords(detectedText: resultText)
              
                if matchedWords.count > 0 {
                    for item in matchedWords {
                        self.resultTitleLabel.text! += item
                        self.score += self.scoreRate
                        self.scoreLabel.text = " \(self.yourScore ?? "YOUR SCORE:")  \(self.score)"
                    }
                }
                
            }
            
          
        
        }

        resultViewModel.showProgress = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
            }
        }

        resultViewModel.hideProgress = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    private func applyOCRForImage() {
        guard let image = resultImage else { return }
        guard let resizeImage = resize(image: image, to: view.frame.size) else { return }
        guard let encodeImage = base64EncodeImage(resizeImage) else { return }
        resultViewModel.getOCRText(encodeImage)
    }

    private func base64EncodeImage(_ image: UIImage) -> String? {
        return image.pngData()?.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    private func resize(image: UIImage, to targetSize: CGSize) -> UIImage? {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle.
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height + 1)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
    @IBAction func runOCRClick(_ sender: Any) {
        applyOCRForImage()
    }
    
    @IBAction func retakePhotoClick(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
