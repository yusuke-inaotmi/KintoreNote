//
//  ViewController.swift
//  KintoreNote2
//
//  Created by 稲富祐輔 on 2020/11/18.
//

import UIKit
import FSCalendar
import CalculateCalendarLogic
import RealmSwift

class NoteTableViewCell: UITableViewCell {
    @IBOutlet weak var vcMenuLabel: UILabel!
    @IBOutlet weak var vcKgLabel1: UILabel!
    @IBOutlet weak var vcKgLabel2: UILabel!
    @IBOutlet weak var vcRepLabel1: UILabel!
    @IBOutlet weak var vcRepLabel2: UILabel!
    @IBOutlet weak var vcRepLabel3: UILabel!
    @IBOutlet weak var vcRepLabel4: UILabel!
    @IBOutlet weak var vcRepLabel5: UILabel!
    @IBOutlet weak var vcRepLabel6: UILabel!
    @IBOutlet weak var vcRepLabel7: UILabel!
    @IBOutlet weak var vcRepLabel8: UILabel!
}

class ViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var vcDateLabel: UILabel!
    @IBOutlet weak var noteTableView: UITableView!
    
    var vcDate : Date!
    
    // 永続化されたデータを<>から取り出す
    var trainingNote: Results<ResultTable>!
    var menuNote: Results<MenuTable>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Realmのインスタンスを取得
        let realm = try! Realm()
        
        // 今日の00:00:00
        let startDate = Calendar.current.startOfDay(for: Date())
        // 今日の23:59:59
        let endDate: Date = {
            let components = DateComponents(day: 1, second:  -1)
            return Calendar.current.date(byAdding: components, to: startDate)!
        }()
        
        // 今日の保存内容を取得する
        trainingNote = realm.objects(ResultTable.self).filter("created_at BETWEEN {%@,%@}", startDate, endDate).sorted(byKeyPath: "id", ascending: true)
        
        // 保存された全ての種目を取得する
        menuNote = realm.objects(MenuTable.self)
        
        self.calendar.dataSource = self
        self.calendar.delegate = self
        self.noteTableView.dataSource = self
        self.noteTableView.delegate = self
        
        // ナビゲーションバーアイテムの色
        self.navigationController!.navigationBar.tintColor = .label
        // 戻るボタンを非表示
        self.navigationItem.hidesBackButton = true
        
        calendar.calendarWeekdayView.weekdayLabels[0].text = "日"
        calendar.calendarWeekdayView.weekdayLabels[1].text = "月"
        calendar.calendarWeekdayView.weekdayLabels[2].text = "火"
        calendar.calendarWeekdayView.weekdayLabels[3].text = "水"
        calendar.calendarWeekdayView.weekdayLabels[4].text = "木"
        calendar.calendarWeekdayView.weekdayLabels[5].text = "金"
        calendar.calendarWeekdayView.weekdayLabels[6].text = "土"
        
        noteTableView.reloadData()
        noteTableView.separatorInset.left = 0
        
        // 日付の設定
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        formatter.dateFormat = "yyyy-MM-dd"
        // ロケールを日本に設定
        formatter.locale = Locale(identifier: "ja_JP")
        // 年月日のみ、曜日なし
        formatter.dateStyle = .long
        // 時間の出力なし
        formatter.timeStyle = .none
        
        // 選択された日付は今日の日付
        self.vcDate = Date()
        vcDateLabel.text = formatter.string(from: vcDate)
        
        print("viewDidLoad")
        print(trainingNote ?? "trainingNote is not found")
        print(menuNote ?? "menuNote is not found")
        print(vcDate ?? "vcDate is not found")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        noteTableView.reloadData()
        calendar.reloadData()
    }
    
    // 不要なメモリを解放してクラッシュを防ぐ
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // 西暦
    fileprivate let gregorian: Calendar = Calendar(identifier: .gregorian)
    
    // 日付の設定
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        // ロケールを日本に設定
        formatter.locale = Locale(identifier: "ja_JP")
        // 年月日のみ、曜日なし
        formatter.dateStyle = .long
        // 時間の出力なし
        formatter.timeStyle = .none
        return formatter
    }()
    
    // 祝日判定を行い結果を返すメソッド(True:祝日)
    func judgeHoliday(_ date : Date) -> Bool {
        // 祝日判定用のカレンダークラスのインスタンス
        let tmpCalendar = Calendar(identifier: .gregorian)
        // 祝日判定を行う日にちの年、月、日を取得
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        // 祝日判定のインスタンスの生成
        let holiday = CalculateCalendarLogic()
        return holiday.judgeJapaneseHoliday(year: year, month: month, day: day)
    }
    
    // date型 -> 年月日をIntで取得
    func getDay(_ date:Date) -> (Int,Int,Int){
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        return (year,month,day)
    }
    
    // 曜日判定(日曜日:1 〜 土曜日:7)
    func getWeekIdx(_ date: Date) -> Int{
        let tmpCalendar = Calendar(identifier: .gregorian)
        return tmpCalendar.component(.weekday, from: date)
    }
    
    // 土日祝日の色を変更
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        // 祝日判定（祝日は赤）
        if self.judgeHoliday(date){
            return UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 1.0)
        }
        // 土日判定（土曜日は青、日曜日は赤）
        let weekday = self.getWeekIdx(date)
        if weekday == 1 {   // 日曜日
            return UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 1.0)
        }
        else if weekday == 7 {  // 土曜日
            return UIColor(red: 0.1, green: 0.3, blue: 0.8, alpha: 1.0)
        }
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // セルの数　ノートの数
        return trainingNote.count
    }
    
    // セルの内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NoteTableViewCell
        let trainingRecord = trainingNote[indexPath.row]
        
        // Realmのインスタンスを取得
        let realm = try! Realm()
        // 種目を検出
        let menuRecord = realm.objects(MenuTable.self).filter("id == %@", trainingRecord.menu_id).first
        
        cell.vcMenuLabel.text = menuRecord?.menu_name ?? "Menu name is not found"
        cell.vcKgLabel1.text = String("\(trainingRecord.set_1_weight)kg")
        cell.vcRepLabel1.text = String("\(trainingRecord.set_1_repetition_1)回")
        cell.vcRepLabel2.text = String("\(trainingRecord.set_1_repetition_2)回")
        cell.vcRepLabel3.text = String("\(trainingRecord.set_1_repetition_3)回")
        cell.vcRepLabel4.text = String("\(trainingRecord.set_1_repetition_4)回")
        
        cell.vcKgLabel2.text = String("\(trainingRecord.set_2_weight)kg")
        cell.vcRepLabel5.text = String("\(trainingRecord.set_2_repetition_1)回")
        cell.vcRepLabel6.text = String("\(trainingRecord.set_2_repetition_2)回")
        cell.vcRepLabel7.text = String("\(trainingRecord.set_2_repetition_3)回")
        cell.vcRepLabel8.text = String("\(trainingRecord.set_2_repetition_4)回")
        
        // セルの色を変更
        let selectionView = UIView()
        selectionView.backgroundColor = UIColor.systemGray6
        cell.selectedBackgroundView = selectionView
        
        print("cellForRowAt")
        print(trainingRecord)
        print(menuRecord ?? "menuRecord is not found")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    // セルを削除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if(editingStyle == UITableViewCell.EditingStyle.delete) {
            do {
                // Realmのインスタンスを取得
                let realm = try Realm()
                
                // 選択した日付の00:00:00
                let startDate = Calendar.current.startOfDay(for: vcDate)
                // 選択した日付の23:59:59
                let endDate: Date = {
                    let components = DateComponents(day: 1, second:  -1)
                    return Calendar.current.date(byAdding: components, to: startDate)!
                }()
                
                // 選択した日付の保存内容を取得する
                trainingNote = realm.objects(ResultTable.self).filter("created_at BETWEEN {%@,%@}", startDate, endDate).sorted(byKeyPath: "id", ascending: true)
                
                try realm.write {
                    realm.delete(self.trainingNote[indexPath.row])
                }
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
            } catch {
                print("delete data error")
            }
        }
        noteTableView.reloadData()
        calendar.reloadData()
    }
    
    // 日付を選択して取得
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // didSelect dateをvcDateに入れる
        self.vcDate = date
        // 選択した日付が空でないなら日付をvcDateLabelに表示する
        if vcDate != nil {
            vcDateLabel.text = dateFormatter.string(from: date)
        }
        
        // Realmのインスタンスを取得
        let realm = try! Realm()
        
        // 選択した日付の00:00:00
        let startDate = Calendar.current.startOfDay(for: date)
        // 選択した日付の23:59:59
        let endDate: Date = {
            let components = DateComponents(day: 1, second:  -1)
            return Calendar.current.date(byAdding: components, to: startDate)!
        }()
        
        // 永続化されたデータを取り出す
        // 選択した日付の保存内容を取得する
        trainingNote = realm.objects(ResultTable.self).filter("created_at BETWEEN {%@,%@}", startDate, endDate).sorted(byKeyPath: "id", ascending: true)
        
        print("didSelect date")
        print(dateFormatter.string(from: date))
        print(date)
        print(startDate)
        print(endDate)
        print(trainingNote ?? "trainingNote is not found")
        print(trainingNote.count)
        print(menuNote ?? "menuNote is not found")
        
        noteTableView.reloadData()
    }
    
    // 予定のある日に点を表示
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        // Realmのインスタンスを取得
        let realm = try! Realm()
        // 選択した日付の00:00:00
        let startDate = Calendar.current.startOfDay(for: date)
        // 選択した日付の23:59:59
        let endDate: Date = {
            let components = DateComponents(day: 1, second:  -1)
            return Calendar.current.date(byAdding: components, to: startDate)!
        }()
        
        // 選択した日付の保存内容を取得する
        trainingNote = realm.objects(ResultTable.self).filter("created_at BETWEEN {%@,%@}", startDate, endDate).sorted(byKeyPath: "id", ascending: true)
        
        if trainingNote.count == 0 {
            return 0
        } else if trainingNote.count >= 1 {
            return 1
        }
        
        print("numberOfEventsFor date")
        print(trainingNote ?? "trainingNote is not found")
        
        return 0
    }
    
    // 「ノートを編集する」ボタンを押した時の処理
    @IBAction func editNote(_ sender: Any) {
        // もしvcDateの中身がnilでないなら画面遷移する
        // 日付を選択してから画面遷移
        if vcDate != nil {
            self.performSegue(withIdentifier: "toEventViewController", sender: nil)
            print("editNote")
            print(vcDate ?? "vcDate is not found")
        } else {
            // 日付を選択していなかったら
            let ngAlert = UIAlertController(title: "日付を選択して下さい。", message: "", preferredStyle: .alert)
            let closeAction = UIAlertAction(title: "閉じる", style: .default) { (action: UIAlertAction) in }
            ngAlert.addAction(closeAction)
            present(ngAlert, animated: true, completion: nil)
        }
    }
    
    // 画面遷移
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEventViewController" {
            let eventView = segue.destination as! EventViewController
            eventView.evcDate = vcDate
        }
    }
}
