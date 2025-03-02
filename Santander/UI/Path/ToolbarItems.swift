//
//  ToolbarItems.swift
//  Santander
//
//  Created by Serena on 04/08/2022.
//

import UIKit


extension SubPathsTableViewController {
    
    @objc
    func setupOrUpdateToolbar() {
        
        let trashAction = UIAction {
            let confirmationController = UIAlertController(title: "Are you sure you want to delete \(self.selectedItems.count) item(s)?", message: nil, preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                
                // if we fail to delete one or multiple paths, save them to this dictionary to display them
                var failedDict: [String: Error] = [:]
                for item in self.selectedItems {
                    do {
                        try FileManager.default.removeItem(at: item)
                    } catch {
                        failedDict[item.lastPathComponent] = error
                    }
                }
                
                if !failedDict.isEmpty {
                    var message: String = ""
                    for (item, error) in failedDict {
                        message.append("\(item): \(error.localizedDescription)\n")
                    }
                    self.errorAlert(message, title: "Failed to delete \(failedDict.count) item(s)")
                }
            }
            
            confirmationController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            confirmationController.addAction(deleteAction)
            self.present(confirmationController, animated: true)
        }
        
        let trash = UIBarButtonItem(systemItem: .trash, primaryAction: trashAction)
        trash.tintColor = .systemRed
        
        let shareAction = UIAction {
            self.presentShareAction(items: self.selectedItems)
        }
        
        let share = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), primaryAction: shareAction)
        let moreItems = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), menu: makeToolbarMoreItemsMenu())
        let items = [trash, share, moreItems].map { item in
            item.isEnabled = !selectedItems.isEmpty
            return item
        }
        
        self.toolbarItems = items
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    @objc
    func hideToolbar() {
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    private func disableToolbarItems() {
        guard let items = toolbarItems else {
            return
        }
        
        for item in items {
            item.isEnabled = !selectedItems.isEmpty
        }
        
        self.toolbarItems = items
    }
    
    func presentShareAction(items: [Any]) {
        let vc = UIActivityViewController(activityItems: items, applicationActivities: [])
        vc.popoverPresentationController?.sourceView = self.view
        vc.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        self.present(vc, animated: true)
    }
    
    fileprivate func makeToolbarMoreItemsMenu() -> UIMenu {
        let moveAction = UIAction(title: "Move", image: UIImage(systemName: "arrow.right")) { _ in
            let vc = PathOperationViewController(paths: self.selectedItems, operationType: .move)
            self.present(UINavigationController(rootViewController: vc), animated: true)
        }
        
        let copyAction = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { _ in
            let vc = PathOperationViewController(paths: self.selectedItems, operationType: .copy)
            self.present(UINavigationController(rootViewController: vc), animated: true)
        }
        
        let symlinkAction = UIAction(title: "Alias", image: UIImage(systemName: "link")) { _ in
            let vc = PathOperationViewController(paths: self.selectedItems, operationType: .symlink)
            self.present(UINavigationController(rootViewController: vc), animated: true)
        }
        
        return UIMenu(children: [moveAction, copyAction, symlinkAction])
    }
    
    /// The button which says "Select all" or "Deselect all" when in edit mode
    @objc
    func setLeftBarSelectionButtonItem() {
        if !isEditing {
            navigationItem.leftBarButtonItem = nil
            return
        }
        
        let contents = self.contents // in order to not keep triggering the getter
        let allItemsSelected = selectedItems.count == contents.count
        let action = UIAction {
            for index in contents.indices {
                if !allItemsSelected {
                    self.tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .none)
                } else {
                    self.tableView.deselectRow(at: IndexPath(row: index, section: 0), animated: true)
                }
            }
            
            self.selectedItems = allItemsSelected ? [] : contents // why do i have to do this? welp! it works
            self.setLeftBarSelectionButtonItem()
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: allItemsSelected ? "Deselect All" : "Select All", primaryAction: action)
        setupOrUpdateToolbar()
    }
}
