//
//  TabViewDemoController.swift
//  SwiftDemoLab
//
//  Created by lihailong on 2025/6/28.
//

import UIKit
import SnapKit


struct ConnectedApp {
    let name: String
    var status: String? // 状态文本（可选）
    var isSyncing: Bool // 是否显示进度
    var progress: Int?  // 当前进度（可选）
    var total: Int?     // 总进度（可选）
}

struct ImportedFile {
    let date: Date
    let title: String
    let distance: String
    let duration: String
    let pace: String
    let source: String
}

class TabViewDemoController: UIViewController {
    
    // 定义不同的section类型
    enum SectionType: Int {
        case healthApp = 0
        case importFile = 1
        case importedFiles = 2
    }
    
    // 定义不同的cell类型
    enum RowType {
        case healthApp(ConnectedApp)
        case allApps
        case importFile
        case importedFile(ImportedFile)
    }
    
    // 数据源结构
    struct Section {
        let type: SectionType
        let title: String?
        var rows: [RowType]
    }
    
    // 表格数据源
    var sections: [Section] = []
    
    var connectedApps: [ConnectedApp] = [
        ConnectedApp(name: "苹果健康", status: "已关联", isSyncing: false, progress: nil, total: nil),
        ConnectedApp(name: "Keep", status: "已关联", isSyncing: false, progress: nil, total: nil),
    ]
    
    var importedFiles: [ImportedFile] = [
        ImportedFile(date: Date(), title: "吊桥港天桥公园线", distance: "8.2公里", duration: "00:52:32", pace: "6'32\"", source: "苹果健康"),
        ImportedFile(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, title: "春日霄头梧水库滨江线", distance: "8.2公里", duration: "00:52:32", pace: "6'32\"", source: "苹果健康"),
        ImportedFile(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, title: "长广溪绿地线", distance: "8.2公里", duration: "00:52:32", pace: "6'32\"", source: "苹果健康"),
        ImportedFile(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, title: "霄头梧水库滨江线", distance: "8.2公里", duration: "00:52:32", pace: "6'32\"", source: "苹果健康"),
    ]

    
    private let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.separatorStyle = .none
        view.backgroundColor = .black
        view.contentInsetAdjustmentBehavior = .never
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = "数据迁移导入"
        
        setupUI()
        setupData()
    }
    
    private func setupUI() {
        // 导航栏返回按钮
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
        navigationController?.navigationBar.tintColor = .white
        
        // 设置导航栏标题颜色
        if let navigationBar = navigationController?.navigationBar {
            let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            navigationBar.titleTextAttributes = textAttributes
            navigationBar.barTintColor = .black
        }
        
        tableView.register(AppCell.self, forCellReuseIdentifier: "AppCell")
        tableView.register(FileCell.self, forCellReuseIdentifier: "FileCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupData() {
        // 构建数据源
        updateSections()
    }
    
    private func updateSections() {
        sections = []
        
        // 健康应用部分
        var healthAppRows: [RowType] = connectedApps.map { .healthApp($0) }
        healthAppRows.append(.allApps)
        sections.append(Section(type: .healthApp, title: "关联健康应用", rows: healthAppRows))
        
        // 导入文件部分
        sections.append(Section(type: .importFile, title: nil, rows: [.importFile]))
        
        // 已导入文件部分
        let fileRows: [RowType] = importedFiles.map { .importedFile($0) }
        sections.append(Section(type: .importedFiles, title: "已导入", rows: fileRows))
        
        tableView.reloadData()
    }
    
    func didSelectApps(_ apps: [ConnectedApp]) {
        connectedApps = [connectedApps[0]] + apps // 保留苹果健康
        updateSections()
    }
}

extension TabViewDemoController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowType = sections[indexPath.section].rows[indexPath.row]
        
        switch rowType {
        case .healthApp(let app):
            let cell = tableView.dequeueReusableCell(withIdentifier: "AppCell", for: indexPath) as! AppCell
            cell.configure(app: app)
            
            // 设置图标
            if app.name == "苹果健康" {
                cell.iconView.image = UIImage(systemName: "heart.fill")
                cell.iconView.tintColor = .white
                cell.iconView.contentMode = .scaleAspectFit
                cell.iconView.backgroundColor = .systemRed
            } else {
                cell.iconView.backgroundColor = .systemGreen
                cell.iconView.image = UIImage(systemName: "app.fill")
                cell.iconView.tintColor = .white
            }
            return cell
            
        case .allApps:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AppCell", for: indexPath) as! AppCell
            cell.configure(title: "全部应用", showArrow: true)
            
            // 设置图标
            cell.iconView.backgroundColor = .systemGreen
            cell.iconView.image = UIImage(systemName: "square.grid.2x2.fill")
            cell.iconView.tintColor = .white
            cell.contentView.layer.cornerRadius = 12
            cell.contentView.layer.masksToBounds = true
            cell.contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            return cell
            
        case .importFile:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AppCell", for: indexPath) as! AppCell
            cell.configure(title: "导入文件", showArrow: true)
            
            // 设置图标
            cell.iconView.backgroundColor = .systemTeal
            cell.iconView.image = UIImage(systemName: "doc.fill")
            cell.iconView.tintColor = .white
            
            // 添加问号按钮
            cell.helpButton.isHidden = false
            cell.helpButton.setImage(UIImage(systemName: "questionmark.circle"), for: .normal)
            cell.helpButton.setTitle(nil, for: .normal)
            
            return cell
            
        case .importedFile(let file):
            let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell", for: indexPath) as! FileCell
            cell.configure(file: file)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil // 不使用默认标题，改用自定义视图
    }
}

extension TabViewDemoController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let rowType = sections[indexPath.section].rows[indexPath.row]
        
        switch rowType {
        case .allApps:
            let selectionVC = AppSelectionViewController()
            selectionVC.selectedApps = Array(connectedApps.dropFirst()) // 排除苹果健康
            selectionVC.completion = { [weak self] apps in
                self?.didSelectApps(apps)
            }
            navigationController?.pushViewController(selectionVC, animated: true)
            
        case .importFile:
            showImportActionSheet()
            
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowType = sections[indexPath.section].rows[indexPath.row]
        
        switch rowType {
        case .healthApp, .allApps, .importFile:
            return 76
        case .importedFile:
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = sections[section].title else { return nil }
        
        let headerView = UIView()
        headerView.backgroundColor = .color("#19191E")
        headerView.layer.cornerRadius = 12
        headerView.layer.masksToBounds = true
        headerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        
        headerView.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sections[section].title == nil ? 0 : 40
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView() // 空视图
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 20 : 10 // 第一个section底部间距更大
    }
    
    private func showImportActionSheet() {
        let alert = UIAlertController(
            title: "导入文件",
            message: "选择导入方式",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "从文件导入", style: .default) { _ in
            // 实现文件导入逻辑
        })
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        present(alert, animated: true)
    }
}
