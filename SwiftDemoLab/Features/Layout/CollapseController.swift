//
//  CollapseController.swift
//  SwiftDemoLab
//
//  Created by lihailong on 2025/7/1.
//

import UIKit
import SnapKit

struct Section {
    var title: String
    var items: [String]
    var isExpanded: Bool
}

class CollapseController: UIViewController {
    
    // MARK: - Properties
    private var sections = [
        Section(title: "水果", items: ["苹果", "香蕉", "橙子", "葡萄", "草莓", "蓝莓", "芒果", "菠萝", "柠檬", "西瓜"], isExpanded: false),
        Section(title: "蔬菜", items: ["胡萝卜", "西兰花", "西红柿", "黄瓜", "茄子", "土豆", "洋葱", "菠菜", "白菜", "青椒"], isExpanded: true),
        Section(title: "饮料", items: ["水", "咖啡", "茶", "果汁", "可乐", "雪碧", "牛奶", "豆浆", "绿茶", "红茶"], isExpanded: false),
        Section(title: "主食", items: ["米饭", "面条", "馒头", "包子", "饺子", "粥", "面包", "土司", "烙饼", "年糕"], isExpanded: false),
        Section(title: "肉类", items: ["猪肉", "牛肉", "鸡肉", "鸭肉", "鱼肉", "虾", "螃蟹", "羊肉", "火腿", "香肠"], isExpanded: false),
        Section(title: "小食", items: ["薯片", "饼干", "巧克力", "糖果", "坚果", "爆米花", "果脯", "蛋糕", "布丁", "冰淇淋"], isExpanded: false),
        Section(title: "调料", items: ["盐", "糖", "醋", "酱油", "蚝油", "胡椒粉", "辣椒粉", "花椒", "八角", "桂皮"], isExpanded: false),
        Section(title: "早餐", items: ["煎蛋", "培根", "麦片", "酸奶", "三明治", "汉堡", "煎饼", "油条", "豆腐脑", "小笼包"], isExpanded: false),
        Section(title: "海鲜", items: ["鲑鱼", "金枪鱼", "带鱼", "鲤鱼", "扇贝", "生蚝", "海带", "紫菜", "鱿鱼", "章鱼"], isExpanded: false),
        Section(title: "坚果", items: ["核桃", "杏仁", "腰果", "花生", "瓜子", "松子", "榛子", "开心果", "夏威夷果", "碧根果"], isExpanded: false)
    ]
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.backgroundColor = .systemGroupedBackground
        table.separatorStyle = .singleLine
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.register(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: SectionHeaderView.identifier)
        table.delegate = self
        table.dataSource = self
        return table
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        title = "折叠列表"
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func toggleSection(_ section: Int) {
        guard section < sections.count else { return }
        
        sections[section].isExpanded.toggle()
        
        tableView.performBatchUpdates({
            tableView.reloadSections(IndexSet(integer: section), with: .automatic)
        }, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension CollapseController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].isExpanded ? sections[section].items.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = sections[indexPath.section].items[indexPath.row]
        cell.textLabel?.font = .systemFont(ofSize: 16)
        cell.accessoryType = .none
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CollapseController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: SectionHeaderView.identifier
        ) as? SectionHeaderView else {
            return nil
        }
        
        let sectionData = sections[section]
        header.configure(
            title: sectionData.title,
            isExpanded: sectionData.isExpanded,
            section: section
        ) { [weak self] sectionIndex in
            self?.toggleSection(sectionIndex)
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

// MARK: - SectionHeaderView
class SectionHeaderView: UITableViewHeaderFooterView {
    static let identifier = "SectionHeaderView"
    
    // MARK: - Properties
    private var toggleAction: ((Int) -> Void)?
    private var section: Int = 0
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .label
        return label
    }()
    
    private let toggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.tintColor = .systemBlue
        return button
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.down")
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()
    
    // MARK: - Initialization
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        contentView.backgroundColor = .systemBackground
        
        [titleLabel, toggleButton, arrowImageView, separatorView].forEach {
            contentView.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(arrowImageView.snp.leading).offset(-8)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.width.height.equalTo(16)
            make.trailing.equalTo(toggleButton.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
        }
        
        toggleButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.greaterThanOrEqualTo(44)
            make.height.greaterThanOrEqualTo(44)
        }
        
        separatorView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        toggleButton.addTarget(self, action: #selector(didTapToggleButton), for: .touchUpInside)
        
        // 添加点击手势到整个 contentView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapHeader))
        contentView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func didTapToggleButton() {
        toggleAction?(section)
    }
    
    @objc private func didTapHeader() {
        toggleAction?(section)
    }
    
    private func updateArrowRotation(isExpanded: Bool, animated: Bool = true) {
        let rotation: CGFloat = isExpanded ? .pi : 0
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                self.arrowImageView.transform = CGAffineTransform(rotationAngle: rotation)
            }
        } else {
            arrowImageView.transform = CGAffineTransform(rotationAngle: rotation)
        }
    }
    
    // MARK: - Public Methods
    func configure(title: String, isExpanded: Bool, section: Int, toggleAction: @escaping (Int) -> Void) {
        titleLabel.text = title
        self.section = section
        self.toggleAction = toggleAction
        
        toggleButton.setTitle(isExpanded ? "折叠" : "展开", for: .normal)
        updateArrowRotation(isExpanded: isExpanded, animated: false)
    }
}
