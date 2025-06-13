//
//  ImagePreviewViewController+CollectionView.swift
//  SLFoundation
//
//  Created by fenglianyi on 2024/6/24.
//

import Foundation

extension ImagePreviewViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imageList.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ImagePreviewViewCell.self), for: indexPath) as? ImagePreviewViewCell else { return ImagePreviewViewCell() }
        if let item = imageList[safe: indexPath.row] {
            cell.bindData(item: item)
        }
        cell.closeHandler = { [weak self] in
            guard let self = self else { return }
            self.closePage()
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? ImagePreviewViewCell {
            cell.reset()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        reloadIndexAndIndicatorView()
    }
}
