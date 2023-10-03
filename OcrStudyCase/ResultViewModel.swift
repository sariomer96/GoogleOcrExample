//
//  ResultViewModel.swift
//  OcrStudyCase
//
//  Created by Omer on 3.10.2023.
//

import Foundation

final class ResultViewModel: ResultViewModelProtocol {

    var encodeImageText: String?
    var callbackFoundText: Callback<String>?
    var showProgress: VoidCallback?
    var hideProgress: VoidCallback?

    func getOCRText(_ encodeImageText: String) {
        showProgress?()
        self.encodeImageText = encodeImageText
        OCRService.shared.detect(encodeImage: encodeImageText) { [weak self] deneme in
            guard let self = self else { return }
            self.hideProgress?()
            guard let response = deneme else { return }
            guard let detectedText = response.annotations?[0].text else { return }
            self.callbackFoundText?(detectedText)
        }
    }

    func matchSearchWordBetweenDetectWords() {
        // TODO: Will be add.
        
        
        
    }
}
