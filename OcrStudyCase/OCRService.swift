//
//  OCRService.swift
//  OcrStudyCase
//
//  Created by Omer on 3.10.2023.
//

import Foundation
import Alamofire
protocol OCRServiceProtocol {
    func detect(encodeImage: String, completion: @escaping (OCRResponseModel?) -> Void)
}
final class OCRService: OCRServiceProtocol {
    static let shared = OCRService()

    private let apiKey = "AIzaSyDnUFTNsCgcHNfO9W57Itx2YCQRxCej1k8"
    private var apiURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(apiKey)")!
    }

    func detect(encodeImage: String, completion: @escaping (OCRResponseModel?) -> Void) {
        callGoogleVisionAPI(with: encodeImage, completion: completion)
    }
    private func callGoogleVisionAPI(
        with base64EncodedImage: String,
        completion: @escaping (OCRResponseModel?) -> Void) {
            let parameters: Parameters = [
                "requests": [
                    [
                        "image": [
                            "content": base64EncodedImage
                        ],
                        "features": [
                            [
                                "type": "TEXT_DETECTION"
                            ]
                        ]
                    ]
                ]
            ]
            let headers: HTTPHeaders = [
                "X-Ios-Bundle-Identifier": Bundle.main.bundleIdentifier ?? ""
            ]

            
          
            
            Alamofire.request(
                apiURL,
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default,
                headers: headers)
                .responseJSON { response in
                    if response.result.isFailure {
                        completion(nil)
                        return
                    }
                    //print(response.result.debugDescription)
                    guard let _ = response.result.value else {
                        completion(nil)
                        return
                    }
                    // Decode the JSON data into a `GoogleCloudOCRResponse` object.
                    let ocrResponse = try? JSONDecoder().decode(GoogleCloudOCRResponse.self, from: response.data!)  //(GoogleCloudOCRResponse.self, from: data as! Data)
                    completion(ocrResponse?.responses[0])
            }
        }
}
