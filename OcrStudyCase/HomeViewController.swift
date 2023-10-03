//
//  ViewController.swift
//  OcrStudyCase
//
//  Created by Omer on 2.10.2023.
//

import UIKit
import AVFoundation

class HomeViewController: UIViewController {
    @IBOutlet weak var cameraView: UIView!
    
    /// Variables
    var captureSession = AVCaptureSession()
    let output = AVCapturePhotoOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    var captureDevice: AVCaptureDevice?
    var isFlashOn: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        // Do any additional setup after loading the view.
    }

    @IBAction func takePhotoClick(_ sender: Any) {
        takeAPhoto()
    }
    

    private func initView() {
   
        requestAccessForCameraUsage()
        setupLayers()

    }

    private func setupLayers() {

        previewLayer.frame = cameraView.bounds
        cameraView.layer.addSublayer(previewLayer)
    }




    func prepareCamera() {
        getDeviceAndBeginSession(with: .back)
    }

    func requestAccessForCameraUsage() {
        CameraPermissionManager.shared.requestAccess(.cameraUsage) { [weak self] accessGranted in
            guard let self = self else { return }
            if accessGranted {
                self.prepareCamera()

            } else {
                self.showSettingsAlert(message: "OCR Case Study must obtain camera permission to conduct photo searches.")
            }
        }
    }

    func showSettingsAlert(message: String) {
        
        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        self.present(alert, animated: true)
    
    }

    // MARK: - Private Methods
    private func getDeviceAndBeginSession(with position: AVCaptureDevice.Position) {
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) {
           
            beginSession(with: device)
        }
    }

 

    private func beginSession(with device: AVCaptureDevice) {
        stopCaptureSession()
        captureDevice = device
        beginConfigurationForCaptureSession()

        do {
            try addFocusFeature(to: device)
            try addInputToSession(with: device)
            addOutputToSession()
            configurePreviewLayer()
            commitAndStartCaptureSession()
        } catch {
            print(error.localizedDescription)
        }
    }

    private func configurePreviewLayer() {
        //previewLayer.videoGravity = .resizeAspectFill
        previewLayer.session = captureSession
    }

    private func commitAndStartCaptureSession() {
        self.captureSession.commitConfiguration()
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }

    private func beginConfigurationForCaptureSession() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }

    private func addInputToSession(with device: AVCaptureDevice) throws {
        let input = try AVCaptureDeviceInput(device: device)
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
    }

    private func addOutputToSession() {
            if captureSession.canAddOutput(output) {
                captureSession.addOutput(output)
            }
        }

    func stopCaptureSession() {
        if captureSession.isRunning {
            captureDevice = nil
            captureSession.stopRunning()
            removeInputsFromSession()
            removeOutputsFromSession()
        }
    }

    func takeAPhoto() {
        if let captureDevice = captureDevice {
           

            let flashMode: AVCaptureDevice.FlashMode = isFlashOn ? .on : .off
            let photoSettings = getPhotoSettings(camera: captureDevice, flashMode: flashMode)
            output.capturePhoto(with: photoSettings, delegate: self)
        }
    }

     func removeInputsFromSession() {
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                self.captureSession.removeInput(input)
            }
        }
    }

        private func getPhotoSettings(camera: AVCaptureDevice, flashMode: AVCaptureDevice.FlashMode) -> AVCapturePhotoSettings {
            let settings = AVCapturePhotoSettings()
            if camera.hasFlash {
                settings.flashMode = flashMode
            }
            return settings
        }


    private func removeOutputsFromSession() {
        for output in captureSession.outputs {
            self.captureSession.removeOutput(output)
        }
    }


    private func addFocusFeature(to device: AVCaptureDevice) throws {
        try device.lockForConfiguration()
        if device.isFocusModeSupported(.continuousAutoFocus) {
            device.focusMode = .continuousAutoFocus
        } else if device.isFocusModeSupported(.autoFocus) {
            device.focusMode = .autoFocus
        }
        device.unlockForConfiguration()
    }
 
}

// MARK: - AVCapturePhotoCaptureDelegate
extension HomeViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else { return }
        guard let image = UIImage(data: data) else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ResultViewController") as! ResultViewController
        controller.resultImage = image
        controller.modalPresentationStyle = .fullScreen
        self.navigationController?.present(controller, animated: true)
        // TODO: will push vc and show image
//        showPhoto(with: image, contentMode: .scaleAspectFill)
    }
}

//// MARK: - TextField Delegate
//extension HomeViewController: UITextFieldDelegate {
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        self.setSearchWorldLabel(textField.text)
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//          textField.resignFirstResponder()
//          return true
//      }
//    
//}

