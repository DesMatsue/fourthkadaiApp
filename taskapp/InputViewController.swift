//
//  InputViewController.swift
//  taskapp
//
//  Created by Takakura 高倉 優介 on 2017/07/20.
//  Copyright © 2017年 DesMatsue. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var category: UITextField!
    
    var task:Task!
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()

        // 背景をタップしたらdismissKeyBoardメソッドを呼ぶように設定する
        let tapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target:self,action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        
        titleTextField.text = self.task.title
        category.text = self.task.category
        contentsTextView.text = self.task.contents
        datePicker.date = self.task.date as Date
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // キーボードを閉じる
    func dismissKeyboard(){
        view.endEditing(true)
    }
    
    // 追加する
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.category = self.category.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date as NSDate
            self.realm.add(self.task, update: true)
        }
        setNotification(task: task)
        
        super.viewWillDisappear(animated)
    }
    
    // タスクのローカル通知を登録する
    func setNotification(task: Task) {
        let content = UNMutableNotificationContent()
        content.title = task.title
        content.body  = task.contents       // bodyが空だと音しか出ない
        content.sound = UNNotificationSound.default()
        
        // ローカル通知が発動するtrigger（日付マッチ）を作成
        let calendar = NSCalendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date as Date)
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
        
        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest.init(identifier: String(task.id), content: content, trigger: trigger)
        
        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")  // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
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
