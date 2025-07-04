//
//  AppStoreViewController.swift
//  SwiftDemoLab
//
//  Created by lihailong on 2025/7/4.
//

import UIKit
import SnapKit

// MARK: - 数据模型
struct AppItem: Hashable {
    let id = UUID()
    let name: String
    let category: String
    let color: UIColor
    let heightRatio: CGFloat // 不同布局的高度比例
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: AppItem, rhs: AppItem) -> Bool {
        lhs.id == rhs.id
    }
}

enum SectionType: Int, CaseIterable {
    case featured
    case mediumList
    case smallGrid
    case largeGrid
    
    var columnCount: Int {
        switch self {
        case .featured: return 1
        case .mediumList: return 1
        case .smallGrid: return 2
        case .largeGrid: return 2
        }
    }
}

struct SectionLayout: Hashable {
    let id = UUID()
    let type: SectionType
    let title: String
    let items: [AppItem]
}

// MARK: - 自定义 Cell
private class LayoutAppCell: UICollectionViewCell {
    static let reuseIdentifier = "LayoutAppCell"
    
    private let imageView = UIView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 2
        return label
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(categoryLabel)
        
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
        }
        
        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func configure(with item: AppItem) {
        titleLabel.text = item.name
        categoryLabel.text = item.category
        imageView.backgroundColor = item.color
        
        // 根据布局类型调整图片高度
        imageView.snp.remakeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(imageView.snp.width).multipliedBy(item.heightRatio)
        }
    }
}

// MARK: - Section Header
class SectionHeader: UICollectionReusableView {
    static let reuseIdentifier = "SectionHeader"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 主控制器
class AppStoreViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<SectionLayout, AppItem>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupCollectionView()
        configureDataSource()
        applyInitialSnapshot()
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createCompositionalLayout()
        )
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 注册 Cell 和 Header
        collectionView.register(LayoutAppCell.self, forCellWithReuseIdentifier: LayoutAppCell.reuseIdentifier)
        collectionView.register(
            SectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeader.reuseIdentifier
        )
    }
    
    // MARK: - 创建多样化布局
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
            guard let self = self,
                  let sectionType = self.dataSource.sectionIdentifier(for: sectionIndex)?.type
            else { return nil }
            
            switch sectionType {
            case .featured:
                return self.createFeaturedSection()
            case .mediumList:
                return self.createMediumListSection()
            case .smallGrid:
                return self.createSmallGridSection()
            case .largeGrid:
                return self.createLargeGridSection()
            }
        }
    }
    
    private func createFeaturedSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.92),
            heightDimension: .absolute(300)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.interGroupSpacing = 20
        section.contentInsets = .init(top: 20, leading: 0, bottom: 40, trailing: 0)
        
        // 添加 Header
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(50)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func createMediumListSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.92),
            heightDimension: .absolute(80)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitem: item,
            count: 3
        )
        group.interItemSpacing = .fixed(10)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 20
        section.contentInsets = .init(top: 10, leading: 0, bottom: 40, trailing: 0)
        
        let header = createSectionHeader()
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func createSmallGridSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.92),
            heightDimension: .absolute(200)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: 2
        )
        group.interItemSpacing = .fixed(15)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 20
        section.contentInsets = .init(top: 10, leading: 0, bottom: 40, trailing: 0)
        
        let header = createSectionHeader()
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func createLargeGridSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(0.5)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 0, bottom: 15, trailing: 0)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.92),
            heightDimension: .absolute(320)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitem: item,
            count: 2
        )
        group.interItemSpacing = .fixed(15)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .none
        section.contentInsets = .init(top: 10, leading: 16, bottom: 40, trailing: 16)
        
        let header = createSectionHeader()
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(50)
        )
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }
    
    // MARK: - 数据源配置
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<SectionLayout, AppItem>(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, item in
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: LayoutAppCell.reuseIdentifier,
                    for: indexPath
                ) as! LayoutAppCell
                cell.configure(with: item)
                return cell
            }
        )
        
        // 配置 Section Header
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader,
                  let section = self?.dataSource.sectionIdentifier(for: indexPath.section) else {
                return nil
            }
            
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SectionHeader.reuseIdentifier,
                for: indexPath
            ) as! SectionHeader
            
            header.titleLabel.text = section.title
            return header
        }
    }
    
    // MARK: - 生成假数据
    private func createMockData() -> [SectionLayout] {
        let categories = ["游戏", "效率", "教育", "娱乐", "社交", "摄影"]
        let appNames = [
            "空间解谜", "像素冒险", "量子计算", "星空探索", "深海寻宝",
            "时间管理", "笔记专家", "思维导图", "任务大师", "日历计划",
            "语言学习", "数学挑战", "科学实验", "历史之旅", "艺术创作",
            "音乐工厂", "电影世界", "美食天地", "旅行日记", "健身助手"
        ]
        
        var sections = [SectionLayout]()
        
        // 特色横幅区
        let featuredItems = (0..<5).map { _ in
            AppItem(
                name: appNames.randomElement()!,
                category: "精选应用",
                color: UIColor(
                    red: .random(in: 0...1),
                    green: .random(in: 0...1),
                    blue: .random(in: 0...1),
                    alpha: 1
                ),
                heightRatio: 0.6
            )
        }
        sections.append(SectionLayout(
            type: .featured,
            title: "本周精选",
            items: featuredItems
        ))
        
        // 中等列表区
        let mediumItems = (0..<10).map { _ in
            AppItem(
                name: appNames.randomElement()!,
                category: categories.randomElement()!,
                color: UIColor(
                    red: .random(in: 0.7...1),
                    green: .random(in: 0.7...1),
                    blue: .random(in: 0.7...1),
                    alpha: 1
                ),
                heightRatio: 1.0
            )
        }
        sections.append(SectionLayout(
            type: .mediumList,
            title: "热门推荐",
            items: mediumItems
        ))
        
        // 小网格区
        let smallGridItems = (0..<8).map { _ in
            AppItem(
                name: appNames.randomElement()!,
                category: categories.randomElement()!,
                color: UIColor(
                    red: .random(in: 0.5...0.8),
                    green: .random(in: 0.5...0.8),
                    blue: .random(in: 0.5...0.8),
                    alpha: 1
                ),
                heightRatio: 1.0
            )
        }
        sections.append(SectionLayout(
            type: .smallGrid,
            title: "快速上手",
            items: smallGridItems
        ))
        
        // 大网格区
        let largeGridItems = (0..<6).map { _ in
            AppItem(
                name: appNames.randomElement()!,
                category: categories.randomElement()!,
                color: UIColor(
                    red: .random(in: 0.3...0.6),
                    green: .random(in: 0.3...0.6),
                    blue: .random(in: 0.3...0.6),
                    alpha: 1
                ),
                heightRatio: 1.5
            )
        }
        sections.append(SectionLayout(
            type: .largeGrid,
            title: "不容错过",
            items: largeGridItems
        ))
        
        return sections
    }
    
    private func applyInitialSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<SectionLayout, AppItem>()
        let sections = createMockData()
        
        snapshot.appendSections(sections)
        sections.forEach { section in
            snapshot.appendItems(section.items, toSection: section)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - CollectionView Delegate
extension AppStoreViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        print("选中应用: \(item.name)")
    }
}
