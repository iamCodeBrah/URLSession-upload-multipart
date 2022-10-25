//
//  ViewController.swift
//  URLSession-upload-multipart
//
//  Created by YouTube on 2022-10-22.
//

import UIKit
    
class ViewController: UIViewController {
    
    let url: URL = URL(string: "http://localhost:5000/upload")!
    
    let boundary: String = "Boundary-\(UUID().uuidString)"
    
    // TODO: - Add more images of your own
    let imageArray: [UIImage] = [
        UIImage(named: "1")!,
        UIImage(named: "2")!,
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemPurple
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Upload", style: .plain, target: self, action: #selector(didTapUpload))
    }

    @objc private func didTapUpload() {
        let requestBody = self.multipartFormDataBody(self.boundary, "CodeBrah", self.imageArray)
        let request = self.generateRequest(httpBody: requestBody)
        
        URLSession.shared.dataTask(with: request) { data, resp, error in
            if let error = error {
                print(error)
                return
            }
            
            print("success")
        }.resume()
        
    }
    
    private func generateRequest(httpBody: Data) -> URLRequest {
        var request = URLRequest(url: self.url)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        request.setValue("multipart/form-data; boundary=" + self.boundary, forHTTPHeaderField: "Content-Type")
        return request
    }
    
    private func multipartFormDataBody(_ boundary: String, _ fromName: String, _ images: [UIImage]) -> Data {
        
        let lineBreak = "\r\n"
        var body = Data()
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"fromName\"\(lineBreak + lineBreak)")
        body.append("\(fromName + lineBreak)")
        
        for image in images {
            if let uuid = UUID().uuidString.components(separatedBy: "-").first {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"imageUploads\"; filename=\"\(uuid).jpg\"\(lineBreak)")
                body.append("Content-Type: image/jpeg\(lineBreak + lineBreak)")
                body.append(image.jpegData(compressionQuality: 0.99)!)
                body.append(lineBreak)
            }
        }
        
        body.append("--\(boundary)--\(lineBreak)") // End multipart form and return
        return body
    }
    
}

