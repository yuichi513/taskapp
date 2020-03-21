//
//  ViewController.swift
//  taskapp
//
//  Created by 山田裕一 on 2020/03/10.
//  Copyright © 2020 yuichi.yamada. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    func categoryBottonsReset() {
        allCategoryButton.tintColor = nil
        jobCategoryButton.tintColor = nil
        homeCategoryButton.tintColor = nil
        playCategoryButton.tintColor = nil
        otherCategoryButton.tintColor = nil
    }
    
    
    @IBOutlet weak var allCategoryButton: UIBarButtonItem!
    @IBAction func allCategory(_ sender: Any) {
    taskArray = realm.objects(Task.self).filter("category LIKE '*'")
        tableView.reloadData()
        categoryBottonsReset()
        allCategoryButton.tintColor = UIColor.gray
    }
    @IBOutlet weak var jobCategoryButton: UIBarButtonItem!
    @IBAction func jobCategory(_ sender: Any) {
        taskArray = realm.objects(Task.self).filter("category = '仕事'")
        tableView.reloadData()
        categoryBottonsReset()
        jobCategoryButton.tintColor = UIColor.gray
    }
    @IBOutlet weak var homeCategoryButton: UIBarButtonItem!
    @IBAction func homeCategory(_ sender: Any) {
        taskArray = realm.objects(Task.self).filter("category = '家庭'")
        tableView.reloadData()
        categoryBottonsReset()
        homeCategoryButton.tintColor = UIColor.gray
    }
    @IBOutlet weak var playCategoryButton: UIBarButtonItem!
    @IBAction func playCategory(_ sender: Any) {
        taskArray = realm.objects(Task.self).filter("category = '遊び'")
        tableView.reloadData()
        categoryBottonsReset()
        playCategoryButton.tintColor = UIColor.gray
    }

    @IBOutlet weak var otherCategoryButton: UIBarButtonItem!
    @IBAction func otherCategory(_ sender: Any) {
        taskArray = realm.objects(Task.self).filter("category = 'その他'")
        tableView.reloadData()
        categoryBottonsReset()
        otherCategoryButton.tintColor = UIColor.gray
    }
    
    let realm = try! Realm()
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        allCategoryButton.tintColor = UIColor.gray
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    func tableView(_ tableView:UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"Cell", for:indexPath)
        
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"

        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    func tableView (_ tableView:UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return.delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 削除するタスクを取得する
            let task = self.taskArray[indexPath.row]

            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])

            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }

            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }
    // segue で画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController

        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()

            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }

            inputViewController.task = task
        }
    }
    
    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}

