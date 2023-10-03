//
//  OCRResponseModel.swift
//  OcrStudyCase
//
//  Created by Omer on 3.10.2023.
//

import Foundation

struct OCRResponseModel: Codable {
    let annotations: [Annotation]?

    enum CodingKeys: String, CodingKey {
        case annotations = "textAnnotations"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        annotations = try container.decode([Annotation].self, forKey: .annotations)
    }
}

struct Annotation: Codable {
    let text: String
    enum CodingKeys: String, CodingKey {
        case text = "description"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .text)
    }
}

struct GoogleCloudOCRResponse: Codable {
    let responses: [OCRResponseModel]
    enum CodingKeys: String, CodingKey {
        case responses = "responses"
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        responses = try container.decode([OCRResponseModel].self, forKey: .responses)
    }
}
