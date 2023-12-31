//
//  CameraPermissionManager.swift
//  OcrStudyCase
//
//  Created by Omer on 3.10.2023.
//

import UIKit
import Photos
import AVFoundation

enum Permission {
    case cameraUsage
    case photoLibraryUsage
}

final class CameraPermissionManager {

    // MARK: - Init Methods
    private init(){}

    // MARK: - Singleton Structure
    public static let shared = CameraPermissionManager()

    // MARK: - Typealias
    typealias completionHandler = (_ accessGranted: Bool) -> Void


    func requestAccess(_ permission: Permission,
                       completionHandler: @escaping completionHandler) {

        switch permission {

        case .cameraUsage:
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                completionHandler(true)
            case .denied:
                completionHandler(false)
            case .restricted, .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    DispatchQueue.main.async {
                        if granted {
                            completionHandler(true)
                        } else {
                            completionHandler(false)
                        }
                    }
                }
            @unknown default:
                break
            }

        case .photoLibraryUsage:
            switch PHPhotoLibrary.authorizationStatus() {
            case .authorized:
                completionHandler(true)
            case .denied:
                completionHandler(false)
            case .restricted, .notDetermined, .limited:
                PHPhotoLibrary.requestAuthorization { status in
                    DispatchQueue.main.async {
                        if status == .authorized{
                            completionHandler(true)
                        }else{
                            completionHandler(false)
                        }
                    }
                }
            @unknown default:
                break
            }
        }
    }
}

