//
//  HostingConfigurationViewController.swift
//  SwiftDemoLab
//
//  Created by lihailong on 2025/6/25.
//

import UIKit
import SwiftUI
import SnapKit

private enum HealthSection: Int, CaseIterable {
    case healthLink
    case importFiles
    case workoutList
}

private struct StaticData {
    lazy var healthLinkItems = HealthLinkCellData.sampleData
    lazy var importFilesItems = HealthImportFilesData.sampleData
    lazy var workoutListItems = HealthWorkoutListData.sampleData
}


class HostingConfigurationViewController: UIViewController {
    private var data = StaticData()
    private var collectionView: UICollectionView!
    
    override func loadView() {
        setupCollectionView()
        view = collectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SwiftUI in Cells"
        view.maximumContentSizeCategory = .extraExtraExtraLarge
    }
    
    private struct LayoutMetrics {
        static let horizontalMargin = 16.0
        static let sectionSpacing = 10.0
        static let cornerRadius = 10.0
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewCompositionalLayout { [unowned self] sectionIndex, layoutEnvironment in
            switch HealthSection(rawValue: sectionIndex)! {
            case.healthLink:
                return createHealthLinkSection()
            case .importFiles:
                return createImportFilesSection()
            case .workoutList:
                return createWorkoutListSection(layoutEnvironment)
            }
        }
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.allowsSelection = false
        collectionView.dataSource = self
    }
    
    private func createHealthLinkSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(8)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = .zero
        section.contentInsets.leading = LayoutMetrics.horizontalMargin
        section.contentInsets.trailing = LayoutMetrics.horizontalMargin
        section.contentInsets.bottom = LayoutMetrics.sectionSpacing
        return section
    }
    
    private func createImportFilesSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(8)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = .zero
        section.contentInsets.leading = LayoutMetrics.horizontalMargin
        section.contentInsets.trailing = LayoutMetrics.horizontalMargin
        section.contentInsets.bottom = LayoutMetrics.sectionSpacing
        return section
    }
    
    private func createWorkoutListSection(_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
        section.contentInsets = .zero
        section.contentInsets.leading = LayoutMetrics.horizontalMargin
        section.contentInsets.trailing = LayoutMetrics.horizontalMargin
        section.contentInsets.bottom = LayoutMetrics.sectionSpacing
        return section
    }
    
    private var healthLinkCellRegistration: UICollectionView.CellRegistration<UICollectionViewCell, HealthLinkCellData> = {
        .init { cell, indexPath, item in
            if #available(iOS 16.0, *) {
                cell.contentConfiguration = UIHostingConfiguration {
                    HealthLinkCell(data: item)
                }
                .margins(.horizontal, LayoutMetrics.horizontalMargin)
                .background {
                    RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadius, style: .continuous)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                }
            }
        }
    }()
    
    private var importFilesCellRegistration: UICollectionView.CellRegistration<UICollectionViewCell, HealthImportFilesData> = {
        .init { cell, indexPath, item in
            if #available(iOS 16.0, *) {
                cell.contentConfiguration = UIHostingConfiguration {
                    HealthImportFilesView()
                }
                .margins(.horizontal, LayoutMetrics.horizontalMargin)
                .background {
                    RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadius, style: .continuous)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                }
            }
        }
    }()
    
    private var workoutListCellRegistration: UICollectionView.CellRegistration<UICollectionViewCell, HealthWorkoutListData> = {
        .init { cell, indexPath, item in
            if #available(iOS 16.0, *) {
                cell.contentConfiguration = UIHostingConfiguration {
                    HealthWorkoutListView()
                }
                .margins(.horizontal, LayoutMetrics.horizontalMargin)
                .background {
                    RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadius, style: .continuous)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                }
            }
        }
    }()
}


extension HostingConfigurationViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        HealthSection.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch HealthSection(rawValue: section)! {
        case .healthLink:
            return data.healthLinkItems.count
        case .importFiles:
            return data.importFilesItems.count
        case .workoutList:
            return data.workoutListItems.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch HealthSection(rawValue: indexPath.section)! {
        case .healthLink:
            let item = data.healthLinkItems[indexPath.item]
            return collectionView.dequeueConfiguredReusableCell(using: healthLinkCellRegistration, for: indexPath, item: item)
        case .importFiles:
            let item = data.importFilesItems[indexPath.item]
            return collectionView.dequeueConfiguredReusableCell(using: importFilesCellRegistration, for: indexPath, item: item)
        case .workoutList:
            let item = data.workoutListItems[indexPath.item]
            return collectionView.dequeueConfiguredReusableCell(using: workoutListCellRegistration, for: indexPath, item: item)
        }
    }
}
