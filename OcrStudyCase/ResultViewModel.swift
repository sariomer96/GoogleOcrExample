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
    var matchedWords:Set<String> = []
    func getOCRText(_ encodeImageText: String) {
        showProgress?()
        self.encodeImageText = encodeImageText
        OCRService.shared.detect(encodeImage: encodeImageText) { [weak self] responses in
            guard let self = self else { return }
            self.hideProgress?()
            guard let response = responses else { return }
            guard let detectedText = response.annotations?[0].text else { return }
            self.callbackFoundText?(detectedText)
        }
    }

    func matchSearchWordBetweenDetectWords(detectedText:String) -> [String] {
        // TODO: Will be add.
        let wordList = Constants.shared.words
        
        var txt = detectedText.replacingOccurrences(of: "\n", with: " ")
        let detectedTxt = txt.components(separatedBy: " ")
       
        print(wordList)
        print(detectedText)
        for item in wordList {
            
            
            for text in detectedTxt {
                
               let lowerText =  text.lowercased()
            //    print("lower txt \(lowerText)  \(item)")
                if lowerText == item {
                    print("MATCHED!!")
                    matchedWords.insert(lowerText)
                    
                }
            }
        }
       
        let match = Array(matchedWords)
      
        return match
        
    }
}
