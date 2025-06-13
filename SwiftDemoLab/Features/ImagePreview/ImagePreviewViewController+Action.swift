//
//  ImagePreviewViewController+Action.swift
//  SLFoundation
//
//  Created by fenglianyi on 2024/6/25.
//

import Foundation

extension ImagePreviewViewController {
    func bindAction() {
        deleteButton.setHandleClick { [weak self] button in
            guard let self = self else { return }
            button?.isUserInteractionEnabled = false
            if preViewIndex >= 0, preViewIndex < self.imageList.count {
                let item = self.imageList.remove(at: preViewIndex)
                self.deleteHandle?(item)
                self.delegate?.imagePreviewDeleteImage(self, item: item)
                self.collectionView.deleteItems(at: [IndexPath(row: preViewIndex, section: 0)])
                DispatchQueue.main.async {
                    self.reloadIndexAndIndicatorView()
                    button?.isUserInteractionEnabled = true
                }
                self.hasEdit = true
                if imageList.isEmpty {
                    self.closePage()
                }
            }
        }
        
        setCoverButton.setHandleClick { [weak self] button in
            guard let self = self else { return }
            self.setCoverButton.isHidden = true
            self.hasEdit = true
            if preViewIndex >= 0, preViewIndex < self.imageList.count {
                for (index, item) in self.imageList.enumerated() {
                    if preViewIndex == index {
                        item.type = .cover
                    } else {
                        item.type = .normal
                    }
                }
            }
        }
    }
    
    func reloadIndexAndIndicatorView() {
        preViewIndex = Int(collectionView.contentOffset.x/view.xy_width)
        preViewIndex = min(preViewIndex, imageList.count - 1)
        indicatorView.reloadData(current: preViewIndex, totalCount: imageList.count)
        if let imageItem = imageList[safe: preViewIndex] {
            setCoverButton.isHidden = !(delegate?.imagePreviewShowSetCover(self, item: imageItem, itemList: imageList) ?? true)
            if inputContext.showDelete {
                deleteButton.isHidden = !(delegate?.imagePreviewShowDelete(self, item: imageItem, itemList: imageList) ?? true)
            }
        }
    }
}
