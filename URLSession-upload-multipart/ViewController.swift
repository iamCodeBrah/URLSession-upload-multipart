//
//  ViewController.swift
//  URLSession-upload-multipart
//
//  Created by YouTube on 2022-10-22.
//

import UIKit
        
class ViewController: UIViewController, URLSessionTaskDelegate {
    
    let url: URL = URL(string: "http://localhost:5000/upload")!
    
    let boundary: String = "Boundary-\(UUID().uuidString)"
    
    // TODO: - Add your own images
    let imageArray: [Data] = [
        UIImage(named: "1")!.jpegData(compressionQuality: 0.99)!,
        UIImage(named: "2")!.jpegData(compressionQuality: 0.99)!,
    ]
    
    private let percentLabel: UILabel = {
       let label = UILabel()
        label.textColor = .label
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 48, weight: .regular)
        label.text = "Not uploading"
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemPurple
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Upload", style: .plain, target: self, action: #selector(didTapUpload))
        
        self.view.addSubview(percentLabel)
        self.percentLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            percentLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            percentLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            percentLabel.widthAnchor.constraint(equalToConstant: 400),
            percentLabel.heightAnchor.constraint(equalToConstant: 120),
        ])
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {

        DispatchQueue.main.async { [weak self] in
            let uploadProgressFloat: Float = Float(totalBytesSent)
             / Float(totalBytesExpectedToSend)
            let uploadProgressInt: Int = Int(uploadProgressFloat*100)
            self?.percentLabel.text = "\(uploadProgressInt)/100%"
        }
        
    }

    @objc private func didTapUpload() {
        let requestBody = self.multipartFormDataBody(self.boundary, "CodeBrah", self.imageArray)
        let request = self.generateRequest(httpBody: requestBody)
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        
        session.dataTask(with: request) { data, resp, error in
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
    
    private func multipartFormDataBody(_ boundary: String, _ fromName: String, _ images: [Data]) -> Data {
        
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
                body.append(image)
                body.append(lineBreak)
            }
        }
        
        body.append("--\(boundary)--\(lineBreak)") // End multipart form and return
        return body
    }
    
}

