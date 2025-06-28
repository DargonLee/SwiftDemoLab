//
//  AppSelectionViewController.swift
//  SwiftDemoLab
//
//  Created by lihailong on 2025/6/28.
//

import UIKit

class AppSelectionViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var availableApps = [
        "Keep",
        "小米运动",
        "华为健康",
        "Zepp Life",
        "Google Fit"
    ]
    
    var selectedApps: [ConnectedApp] = []
    var completion: (([ConnectedApp]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsMultipleSelection = true
    }
    
    @IBAction func doneTapped(_ sender: UIBarButtonItem) {
        completion?(selectedApps)
        navigationController?.popViewController(animated: true)
    }
}

extension AppSelectionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableApps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppSelectCell", for: indexPath)
        let appName = availableApps[indexPath.row]
        cell.textLabel?.text = appName
        
        // 设置选中状态
        if selectedApps.contains(where: { $0.name == appName }) {
            cell.accessoryType = .checkmark
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let appName = availableApps[indexPath.row]
        if !selectedApps.contains(where: { $0.name == appName }) {
            let newApp = ConnectedApp(
                name: appName,
                status: "数据同步中",
                isSyncing: true,
                progress: 12,
                total: 299
            )
            selectedApps.append(newApp)
        }
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let appName = availableApps[indexPath.row]
        selectedApps.removeAll { $0.name == appName }
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
}
