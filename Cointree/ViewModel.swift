import Parsing
import SwiftUI
import UIKit
import Vision
import VisionKit

final class CointreeViewModel: ObservableObject {
  var documentScanner: VNDocumentCameraViewController?
  var documentScannerDelegate: DocumentScannerDelegate?
  
  @Published var dollarAmount: Double = 5652.34
  @Published var co2removed: Double = 47802
  @Published var eligibleAmount: Int?
  
  var kwh: Double?
  
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
    0.206 * Double(kwh)
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
