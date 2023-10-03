//
//  ResultConracts.swift
//  OcrStudyCase
//
//  Created by Omer on 3.10.2023.
//


import Foundation

typealias VoidCallback = (() -> Void)
typealias Callback<T> = ((T) -> Void)

protocol ResultViewModelProtocol {
    func getOCRText(_ encodeImageText: String)
    var callbackFoundText: Callback<String>? { get set }
    var showProgress: VoidCallback? { get set }
    var hideProgress: VoidCallback? { get set }
    func matchSearchWordBetweenDetectWords(detectedText:String) -> [String]
}
