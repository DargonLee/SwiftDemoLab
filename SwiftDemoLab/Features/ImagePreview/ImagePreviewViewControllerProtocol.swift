//
//  ImagePreviewViewControllerProtocol.swift
//  SLFoundation
//
//  Created by fenglianyi on 2024/6/25.
//

import Foundation

public protocol ImagePreviewViewControllerDelegate: AnyObject {
    // delegate
    func imagePreviewDeleteImage(_ imagePreview: ImagePreviewViewController, item: ImageItem)
    func imagePreviewFinallyImageList(_ imagePreview: ImagePreviewViewController, items: [ImageItem])
    
    func imagePreviewShowSetCover(_ imagePreview: ImagePreviewViewController, item: ImageItem, itemList: [ImageItem]) -> Bool
    func imagePreviewShowDelete(_ imagePreview: ImagePreviewViewController, item: ImageItem, itemList: [ImageItem]) -> Bool
}

extension ImagePreviewViewControllerDelegate {
    public func imagePreviewDeleteImage(_ imagePreview: ImagePreviewViewController, item: ImageItem) { }
    public func imagePreviewFinallyImageList(_ imagePreview: ImagePreviewViewController, items: [ImageItem]) { }
    
    public func imagePreviewShowSetCover(_ imagePreview: ImagePreviewViewController, item: ImageItem, itemList: [ImageItem]) -> Bool { false }
    public func imagePreviewShowDelete(_ imagePreview: ImagePreviewViewController, item: ImageItem, itemList: [ImageItem]) -> Bool { true }
}

