//
//  ViewController.swift
//  SwiftDemoLab
//
//  Created by lihailong on 2025/5/19.
//

import Inject
import UIKit

#if DEBUG
    extension UIViewController {
        @objc func injected() {
            viewDidLoad()
        }
    }
#endif

class MainViewController: UIViewController {
    private var tableView: UITableView!
    private var dataSource: [DemoSection] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SwiftDemoLab"
        view.backgroundColor = .systemBackground
        setupTableView()
        setupDataSource()
    }

    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
    }

    private func setupDataSource() {
        dataSource = DemoDataProvider.allSections()
        tableView.reloadData()
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].items.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource[section].title
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ??
            UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let item = dataSource[indexPath.section].items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.desc
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = dataSource[indexPath.section].items[indexPath.row]
        let vc = item.controllerType.init()
        vc.title = item.title
        let hostVC = Inject.ViewControllerHost(vc)
        navigationController?.pushViewController(hostVC, animated: true)
    }
}
