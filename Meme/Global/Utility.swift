//
//  Utility.swift
//  Meme
//
//  Created by DAO on 2024/9/16.
//

import UIKit

struct Utility {
    static func getImageURL(named imageName: String) -> URL? {
        guard let image = UIImage(named: imageName) else {
            print("Can't find image: \(imageName)")
            return nil
        }
        
        let temporaryDirectoryURL = FileManager.default.temporaryDirectory
        let imageURL = temporaryDirectoryURL.appendingPathComponent("\(imageName).png")
        
        do {
            if let imageData = image.pngData() {
                try imageData.write(to: imageURL)
                return imageURL
            }
        } catch {
            print("An error occurred while saving the image: \(error)")
        }
        
        return nil
    }
    
    static func getLocalizedString(for key: String, language: String) -> String {
        let localeIdentifier = Locale.identifier(fromComponents: [NSLocale.Key.languageCode.rawValue: language])
        let locale = Locale(identifier: localeIdentifier)
        
        return String(localized: String.LocalizationValue(key), locale: locale)
    }
    
    static func showShareSheet(items: [Any], parentVC: UIViewController) {
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        // for iPad
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = parentVC.view
            popoverController.sourceRect = CGRect(x: parentVC.view.bounds.midX, y: parentVC.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        parentVC.present(activityViewController, animated: true, completion: nil)
    }
}

