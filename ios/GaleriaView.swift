import UIKit
import ExpoModulesCore
import ImageViewer_swift
import SDWebImage

class GaleriaView: ExpoView {
  func getChildImageView() -> UIImageView? {
    guard let reactSubviews = self.reactSubviews() else { return nil }
    
    for reactSubview in reactSubviews {
      for subview in reactSubview.subviews {
        if let imageView = subview as? UIImageView {
          return imageView
        }
      }
    }
    
    return nil
  }
  
  override func insertReactSubview(_ subview: UIView!, at atIndex: Int) {
    super.insertReactSubview(subview, at: atIndex)
    setupImageView()
  }
  
  
  var theme: Theme = .dark  { didSet { setupImageView() } }
  var urls: [String]? { didSet { setupImageView() } }
  var initialIndex: Int? { didSet { setupImageView() } }
  var closeIconName: String?
  var rightNavItemIconName: String?
  let onPressRightNavItemIcon = EventDispatcher()
  
  func setupImageView() {
    let viewerTheme = theme.toImageViewerTheme()
    guard let childImage = getChildImageView() else {
      return
    }
    
    if let urls = self.urls, let initialIndex = self.initialIndex {
      setupImageViewerWithUrls(childImage, urls: urls, initialIndex: initialIndex, viewerTheme: viewerTheme)
    } else {
      setupImageViewerWithSingleImage(childImage, viewerTheme: viewerTheme)
    }
  }
  
  private func setupImageViewerWithUrls(_ childImage: UIImageView, urls: [String], initialIndex: Int, viewerTheme: ImageViewerTheme) {
    let urlObjects = urls.compactMap(URL.init(string:))
    var options: [ImageViewerOption] = [.theme(viewerTheme)]
    let iconColor = theme.iconColor()
    
    if let closeIconName = closeIconName, let closeIconImage = UIImage(systemName: closeIconName)?.withTintColor(iconColor, renderingMode: .alwaysOriginal) {
      let closeIconOption = ImageViewerOption.closeIcon(closeIconImage)
      options.append(closeIconOption)
    }
   
  
    if let rightIconName = rightNavItemIconName, let rightIconImage = UIImage(systemName: rightIconName)?.withTintColor(iconColor, renderingMode: .alwaysOriginal) {
      let rightNavItemOption = ImageViewerOption.rightNavItemIcon(rightIconImage, onTap: { index in
        self.onPressRightNavItemIcon(["index": index])
      })
      options.append(rightNavItemOption)
    }
    
    childImage.setupImageViewer(urls: urlObjects, initialIndex: initialIndex, options: options)
  }
  
  private func setupImageViewerWithSingleImage(_ childImage: UIImageView, viewerTheme: ImageViewerTheme) {
    guard let img = childImage.image else {
      print("Missing image in childImage: \(childImage)")
      return
    }
    childImage.setupImageViewer(images: [img], options: [.theme(viewerTheme)])
  }
}


enum Theme: String, Enumerable {
  case dark
  case light
  
  func toImageViewerTheme() -> ImageViewerTheme {
    switch self {
      case .dark:
        return .dark
      case .light:
        return .light
    }
  }
  func iconColor() -> UIColor {
    switch self {
      case .dark:
        return .white
      case .light:
        return .black
    }
  }
}
