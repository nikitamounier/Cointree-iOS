import Alamofire
import Parsing
import SwiftUI
import UIKit
import Vision
import VisionKit

final class CointreeViewModel: ObservableObject {
  var documentScanner: VNDocumentCameraViewController?
  var documentScannerDelegate: DocumentScannerDelegate?
  
  @Published var eligibleAmount: Double?
  
  var profile: Profile? {
    willSet {
      do {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("cointree-profile")
        try JSONEncoder().encode(newValue).write(to: url)
      } catch {
        print("error encoding")
      }
    }
  }
  
  var kwh: Double?
  
  struct Profile: Codable, Equatable, Identifiable {
    var walletID: String
    var dollarsReceived: Double
    var co2Removed: Double
    
    var id: String { walletID }
  }
  
  init() {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let url = paths[0].appendingPathComponent("cointree-profile")

    do {
      let profile = try JSONDecoder().decode(Profile.self, from: Data(contentsOf: url))
      self.profile = profile
      objectWillChange.send()
    } catch {
      print("couldn't decode profile")
    }
  }
  
  func startDocumentScanner() {
    self.documentScannerDelegate = DocumentScannerDelegate(
      savedDocument: { [unowned self] image in
        self.documentScanner?.dismiss(animated: true)
        let potentialkwh = self.analyseImage(image)
        if let kwh = potentialkwh {
          self.eligibleAmount = self.calculateEligibleAmount(kwh)
        }
      },
      canceled: {
        
      },
      failed: { err in
        
      }
    )
    
    self.documentScanner = VNDocumentCameraViewController()
    self.documentScanner?.delegate = self.documentScannerDelegate
    let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
    windowScene?.keyWindow?.rootViewController?.present(self.documentScanner!, animated: true)
  }
  
  private func analyseImage(_ image: UIImage) -> Int? {
    guard let cgImage = image.cgImage else { return nil }
    
    let requestHandler = VNImageRequestHandler(cgImage: cgImage)
    
    var kwh: Int?
    
    let request = VNRecognizeTextRequest { request, potentialError in
      guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
      let recognisedStrings = observations
        .compactMap { $0.topCandidates(1).first?.string }
        .joined(separator: "")
      
      do {
        let number = try invoiceParser.parse(recognisedStrings)
        kwh = number
      } catch {
        print(error)
      }
    }
    
    try! requestHandler.perform([request])
    
    print(kwh ?? "none")
    return kwh
  }
  
  private func calculateEligibleAmount(_ kwh: Int) -> Double {
    0.206 * Double(kwh) * 77.1
  }
  
  func receiveMoney() {
    
    let job = ["wallet": "4831843023948", "amount": "23", "jobDescription": "Solar panel"]
    
    var semaphore = DispatchSemaphore (value: 0)

    let parameters = "{\n    \"wallet\": \"\(profile!.walletID)\",\n    \"amount\": \"\(Int(eligibleAmount!))\",\n    \"jobDescription\": \"Solar panel installation\"\n}"
    let postData = parameters.data(using: .utf8)

    var request = URLRequest(url: URL(string: "https://jobs-cointree.herokuapp.com/job/create")!,timeoutInterval: Double.infinity)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    request.httpMethod = "POST"
    request.httpBody = postData

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      guard let data = data else {
        print(String(describing: error))
        semaphore.signal()
        return
      }
      print(String(data: data, encoding: .utf8)!)
      semaphore.signal()
    }

    task.resume()
    semaphore.wait()

    
    self.profile?.dollarsReceived += eligibleAmount!
    Task { @MainActor in eligibleAmount = nil }
  }
}


let invoiceParser = Parse {
  Skip { Prefix { !$0.isNumber } }
  Digits(1...)
  Whitespace()
  Skip {
    OneOf {
      "kW"
      "kw"
      "KW"
      "Kw"
    }
  }
  Skip { Rest() }
}

final class DocumentScannerDelegate: NSObject, VNDocumentCameraViewControllerDelegate {
  let savedDocument: (UIImage) -> Void
  let canceled: () -> Void
  let failed: (Error) -> Void
  
  init(
    savedDocument: @escaping (UIImage) -> Void,
    canceled: @escaping () -> Void,
    failed: @escaping (Error) -> Void
  ) {
    self.savedDocument = savedDocument
    self.canceled = canceled
    self.failed = failed
  }
  
  func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
    self.savedDocument(scan.imageOfPage(at: 0))
  }
  
  func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
    self.canceled()
  }
  
  func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
    self.failed(error)
  }
}

let contractABI = #"[{ "inputs": [], "stateMutability": "nonpayable", "type": "constructor" }, { "inputs": [ { "internalType": "string", "name": "", "type": "string" } ], "name": "balances", "outputs": [ { "internalType": "uint256", "name": "", "type": "uint256" } ], "stateMutability": "view", "type": "function" }, { "inputs": [ { "internalType": "string", "name": "name", "type": "string" } ], "name": "createCompany", "outputs": [], "stateMutability": "nonpayable", "type": "function" }, { "inputs": [ { "internalType": "string", "name": "name", "type": "string" } ], "name": "deposit", "outputs": [], "stateMutability": "payable", "type": "function" }, { "inputs": [ { "internalType": "uint256", "name": "amount", "type": "uint256" }, { "internalType": "string", "name": "name", "type": "string" } ], "name": "distribute", "outputs": [], "stateMutability": "nonpayable", "type": "function" }, { "inputs": [ { "internalType": "string", "name": "name", "type": "string" } ], "name": "getBalance", "outputs": [ { "internalType": "uint256", "name": "", "type": "uint256" } ], "stateMutability": "view", "type": "function" }, { "inputs": [], "name": "getCompanies", "outputs": [ { "internalType": "string[]", "name": "", "type": "string[]" } ], "stateMutability": "view", "type": "function" }, { "stateMutability": "payable", "type": "receive" }]"#

struct Job: Codable {
  let wallet: String
  let amount: Int
  let jobDescription: String
}
