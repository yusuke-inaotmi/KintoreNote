//
//  EventViewController.swift
//  KintoreNote2
//
//  Created by 稲富祐輔 on 2020/11/18.
//

import UIKit
import RealmSwift

class ResultTable: Object {
    // プライマリーキー
    @objc dynamic var id: Int = 0
    // セット１の重量と回数
    @objc dynamic var set_1_weight: Float = 0.00
    @objc dynamic var set_1_repetition_1: Int = 0
    @objc dynamic var set_1_repetition_2: Int = 0
    @objc dynamic var set_1_repetition_3: Int = 0
    @objc dynamic var set_1_repetition_4: Int = 0
    // セット２の重量と回数
    @objc dynamic var set_2_weight: Float = 0.00
    @objc dynamic var set_2_repetition_1: Int = 0
    @objc dynamic var set_2_repetition_2: Int = 0
    @objc dynamic var set_2_repetition_3: Int = 0
    @objc dynamic var set_2_repetition_4: Int = 0
    // 種目のid
    @objc dynamic var menu_id: Int = 0
    // 部位
    @objc dynamic var parts_name: String = ""
    // 「重量」「回数」「種目id」「部位」の保存日時
    @objc dynamic var updated_at = Date()
    @objc dynamic var created_at = Date()
    
    // idをプライマリキーに設定
    override static func primaryKey() -> String? {
        return "id"
    }
    // IDをincrement(1増やす)して返す
    static func newID(realm: Realm) -> Int {
        if let training = realm.objects(ResultTable.self).sorted(byKeyPath: "id").last { // 全てのResult_Tableオブジェクトの中から最後のものを取得する。
            return training.id + 1 // 上の行で取得した最後のオブジェクトのidに+1した値を返却する。
        } else {
            return 1 // Result_Tableオブジェクトが今までに一度も設定されていなければ、1を返却する。
        }
    }
    // increment(1増やす)されたIDを持つ新規trainingインスタンスを返す
    static func create(realm: Realm) -> ResultTable {
        let training: ResultTable = ResultTable() // インスタンス化する。
        training.id = newID(realm: realm) // idをnewID関数を使って設定する。このnewIDは上記のように、全てのResult_Tableオブジェクトの中から、最後に追加したidに+1したものが返却されている。
        return training // Result_Tableのインスタンスを返却する。
    }
}

class MenuTable: Object {
    // プライマリーキー
    @objc dynamic var id: Int = 0
    // 種目
    @objc dynamic var menu_name: String? = ""
    // 部位
    @objc dynamic var parts_name: String = ""
    // 「種目」の保存日時
    @objc dynamic var updated_at = Date()
    @objc dynamic var created_at = Date()
    
    // idをプライマリキーに設定
    override static func primaryKey() -> String? {
        return "id"
    }
    // IDをincrement(1増やす)して返す
    static func newID(realm: Realm) -> Int {
        if let training = realm.objects(MenuTable.self).sorted(byKeyPath: "id").last {
            return training.id + 1
        } else {
            return 1
        }
    }
    // increment(1増やす)されたIDを持つ新規trainingインスタンスを返す
    static func create(realm: Realm) -> MenuTable {
        let training: MenuTable = MenuTable()
        training.id = newID(realm: realm)
        return training
    }
}

class EventViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var partsPickerView: UIPickerView!
    @IBOutlet weak var partsLabel: UILabel!
    @IBOutlet weak var menuPickerView: UIPickerView!
    @IBOutlet weak var menuLabel: UILabel!
    @IBOutlet weak var menuTextField: UITextField!
    @IBOutlet weak var kgTextField1: UITextField!
    @IBOutlet weak var kgTextField2: UITextField!
    @IBOutlet weak var repTextField1: UITextField!
    @IBOutlet weak var repTextField2: UITextField!
    @IBOutlet weak var repTextField3: UITextField!
    @IBOutlet weak var repTextField4: UITextField!
    @IBOutlet weak var repTextField5: UITextField!
    @IBOutlet weak var repTextField6: UITextField!
    @IBOutlet weak var repTextField7: UITextField!
    @IBOutlet weak var repTextField8: UITextField!
    
    var partsDataList: [String] = [
        "脚","背中","胸","肩","三頭","二頭","腹"
    ]
    var selectedParts = ""
    
    var selectedMenu: MenuTable?
    
    // 永続化されたデータを<>から取り出す
    var menuResult: Results<MenuTable>!
    
    var evcDate: Date!
    
    // 遷移後その都度呼ばれる処理
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // dateLabelに選択した日付を表示
        dateLabel.text = dateFormatter.string(from: evcDate)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        partsPickerView.delegate = self
        partsPickerView.dataSource = self
        menuPickerView.delegate = self
        menuPickerView.dataSource = self
        menuTextField.delegate = self
        kgTextField1.delegate = self
        kgTextField2.delegate = self
        repTextField1.delegate = self
        repTextField2.delegate = self
        repTextField3.delegate = self
        repTextField4.delegate = self
        repTextField5.delegate = self
        repTextField6.delegate = self
        repTextField7.delegate = self
        repTextField8.delegate = self
        partsPickerView.tag = 1
        menuPickerView.tag = 2
        selectedParts = partsDataList[0]
        
        partsLabel.text = selectedParts
        
        // Realmのインスタンスを取得
        let realm = try! Realm()
        
        // pickerView問題で追加したところ　画面を読み込んだら種目を選択
        menuResult = realm.objects(MenuTable.self).filter("parts_name == %@", "脚")
        selectedMenu = menuResult.first
        menuLabel.text = selectedMenu?.menu_name
        
        // キーボードを開く際に呼び出す通知
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        // キーボードを閉じる際に呼び出す通知
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // キーボードの種類
        menuTextField.keyboardType = UIKeyboardType.default
        kgTextField1.keyboardType = UIKeyboardType.decimalPad
        kgTextField2.keyboardType = UIKeyboardType.decimalPad
        repTextField1.keyboardType = UIKeyboardType.decimalPad
        repTextField2.keyboardType = UIKeyboardType.decimalPad
        repTextField3.keyboardType = UIKeyboardType.decimalPad
        repTextField4.keyboardType = UIKeyboardType.decimalPad
        repTextField5.keyboardType = UIKeyboardType.decimalPad
        repTextField6.keyboardType = UIKeyboardType.decimalPad
        repTextField7.keyboardType = UIKeyboardType.decimalPad
        repTextField8.keyboardType = UIKeyboardType.decimalPad
        
        print("viewDidLoad")
        print(menuResult ?? "menuResult is not found")
        print(selectedMenu ?? "selectedMenu is not found")
        
        menuPickerView.reloadAllComponents()
        view.addSubview(menuLabel)
    }
    
    // 日付の設定
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        formatter.dateFormat = "yyyy-MM-dd"
        // ロケールを日本に設定
        formatter.locale = Locale(identifier: "ja_JP")
        // 年月日のみ、曜日なし
        formatter.dateStyle = .long
        // 時間の出力なし
        formatter.timeStyle = .none
        return formatter
    }()
    
    // UIPickerViewの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // UIPickerViewの個数を返す処理
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        
        // Realmのインスタンスを取得
        let realm = try! Realm()
        
        if pickerView.tag == 1{
            return partsDataList.count
        } else if pickerView.tag == 2{
            
            // 「選択した部位」と同じ「MenuTableに保存されている部位」を検索しその内容を取得
            menuResult = realm.objects(MenuTable.self).filter(NSPredicate(format: "parts_name == %@", selectedParts))
            
            return menuResult.count
            
        } else {
            return 0
        }
    }
    
    // UIPickerViewに表示する内容
    func pickerView(_ picker: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        
        // Realmのインスタンスを取得
        let realm = try! Realm()
        
        // 種目が空なら非表示にしクラッシュを防ぐ
        if menuResult.count == 0 {
            menuPickerView.isHidden = true
        } else if menuResult.count != 0 {
            menuPickerView.isHidden = false
        }
        
        if picker.tag == 1 {
            return partsDataList[row]
        } else if picker.tag == 2 {
            
            // 「選択した部位」と同じ「MenuTableに保存されている部位」を検索しその内容を取得
            menuResult = realm.objects(MenuTable.self).filter(NSPredicate(format: "parts_name == %@", selectedParts)).sorted(byKeyPath: "id", ascending: true)
            
            let menu = menuResult[row]
            
            return menu.menu_name
        } else {
            return ""
        }
    }
    
    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        
        if pickerView.tag == 1 {
            partsLabel.text = partsDataList[row]
            selectedParts = partsDataList[row]
            menuPickerView.reloadAllComponents()
            print("部位のピッカービューで「\(selectedParts)」を選択")
        } else if pickerView.tag == 2 {
            
            // 保存されたMenuTableのrow番目
            selectedMenu = menuResult[row]
            menuLabel.text = selectedMenu?.menu_name
            
            print(menuResult ?? "menuResult is not found")
            print(menuResult[row])
            print("選択した種目のデータ群\(selectedMenu!)")
            print("種目のピッカービューで「\(selectedMenu?.menu_name ?? "selectedMenu.menu_name is not found")」を選択")
        } else {
            return
        }
    }
    
    // 画面タップでキーボードを閉じる
    @IBAction func tapScreen(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    // 不要なメモリを解放してクラッシュを防ぐ
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Doneボタン押下でキーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // キーボード表示
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            } else {
                let suggestionHeight = self.view.frame.origin.y + keyboardSize.height
                self.view.frame.origin.y -= suggestionHeight
            }
        }
    }
    
    // キーボード非表示
    @objc func keyboardWillHide() {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    // 「種目を追加」ボタン
    @IBAction func didTapAddMenuButton(_ sender: Any) {
        
        // もし種目が入力されていたら
        if menuTextField.text != "" {
            
            menuLabel.text = menuTextField.text
            
            let okAlert = UIAlertController(title: "保存されました。", message: "", preferredStyle: .alert)
            let closeAction = UIAlertAction(title: "閉じる", style: .default) { (action: UIAlertAction) in }
            okAlert.addAction(closeAction)
            present(okAlert, animated: true, completion: nil)
            
            // 種目をRealmに保存
            // Realmのインスタンスを取得
            let realm = try! Realm()
            // 追加するデータを用意
            let menuTable = MenuTable.create(realm: realm)
            
            // データを永続化するための処理
            try! realm.write() {
                
                // 日付の設定
                let formatter = DateFormatter()
                formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
                formatter.dateFormat = "yyyy-MM-dd"
                // ロケールを日本に設定
                formatter.locale = Locale(identifier: "ja_JP")
                // 年月日のみ、曜日なし
                formatter.dateStyle = .long
                // 時間の出力
                formatter.timeStyle = .long
                
                print(formatter.string(from: Date()))
                
                menuTable.menu_name = menuTextField.text
                menuTable.parts_name = partsLabel.text!
                
                // Realmにデータを追加
                realm.add(menuTable, update: .modified)
                
                print("didTapAddMenuButton")
                print(menuResult ?? "menuResult is not found")
                print("種目「\(menuTable.menu_name ?? "menuTable.menu_name is not found")」を「\(selectedParts)」へ追加")
                print(selectedMenu ?? "selectedMenu is not found")
            }
            
        } else {
            // 種目が入力されていなかったら
            let ngAlert = UIAlertController(title: "新しい種目が空です。", message: "", preferredStyle: .alert)
            let closeAction = UIAlertAction(title: "閉じる", style: .default) { (action: UIAlertAction) in }
            ngAlert.addAction(closeAction)
            present(ngAlert, animated: true, completion: nil)
        }
        menuPickerView.reloadAllComponents()
    }
    
    // segueが動作することをViewControllerに通知するメソッド
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    // 「ノートを追加する」ボタンを押したら各項目を保存
    @IBAction func didTapAddNoteButton(_ sender: Any) {
        
        // 重量、回数が空の場合アラートを出す
        if kgTextField1.text == "" && repTextField1.text == "" && repTextField2.text == "" &&  repTextField3.text == "" && repTextField4.text == "" && kgTextField2.text == "" && repTextField5.text == "" && repTextField6.text == "" && repTextField7.text == "" && repTextField8.text == "" {
            let ngAlert = UIAlertController(title: "重量/kg 回数/Repが空です。", message: "", preferredStyle: .alert)
            let closeAction = UIAlertAction(title: "閉じる", style: .default) { (action: UIAlertAction) in }
            ngAlert.addAction(closeAction)
            present(ngAlert, animated: true, completion: nil)
            
        } else {
            
            // Realmのインスタンスを取得
            let realm = try! Realm()
            // 追加するデータを用意
            let resultTable = ResultTable.create(realm: realm)
            // 追加した種目を検出
            menuResult = realm.objects(MenuTable.self).filter("menu_name == %@", menuLabel.text ?? "menuLabel is not found")
            
            // menuPickerViewで選択しなくてもselectedMenuに種目を入れる
            selectedMenu = menuResult.first
            
            // データを永続化するための処理
            try! realm.write() {
                
                let kgText1: String = kgTextField1.text ?? ""
                let repText1: String = repTextField1.text ?? ""
                let repText2: String = repTextField2.text ?? ""
                let repText3: String = repTextField3.text ?? ""
                let repText4: String = repTextField4.text ?? ""
                let kgText2: String = kgTextField2.text ?? ""
                let repText5: String = repTextField5.text ?? ""
                let repText6: String = repTextField6.text ?? ""
                let repText7: String = repTextField7.text ?? ""
                let repText8: String = repTextField8.text ?? ""
                
                // 変換
                let set_1_weight_cv: Float = Float(kgText1) ?? 0.00
                let set_1_repetition_1_cv: Int = Int(repText1) ?? 0
                let set_1_repetition_2_cv: Int = Int(repText2) ?? 0
                let set_1_repetition_3_cv: Int = Int(repText3) ?? 0
                let set_1_repetition_4_cv: Int = Int(repText4) ?? 0
                let set_2_weight_cv: Float = Float(kgText2) ?? 0.00
                let set_2_repetition_1_cv: Int = Int(repText5) ?? 0
                let set_2_repetition_2_cv: Int = Int(repText6) ?? 0
                let set_2_repetition_3_cv: Int = Int(repText7) ?? 0
                let set_2_repetition_4_cv: Int = Int(repText8) ?? 0
                
                resultTable.set_1_weight = set_1_weight_cv
                resultTable.set_1_repetition_1 = set_1_repetition_1_cv
                resultTable.set_1_repetition_2 = set_1_repetition_2_cv
                resultTable.set_1_repetition_3 = set_1_repetition_3_cv
                resultTable.set_1_repetition_4 = set_1_repetition_4_cv
                resultTable.set_2_weight = set_2_weight_cv
                resultTable.set_2_repetition_1 = set_2_repetition_1_cv
                resultTable.set_2_repetition_2 = set_2_repetition_2_cv
                resultTable.set_2_repetition_3 = set_2_repetition_3_cv
                resultTable.set_2_repetition_4 = set_2_repetition_4_cv
                resultTable.parts_name = partsLabel.text!
                
                // selectedMenuの中身があればmenuに入れる、空なら処理を止める
                guard let menu = selectedMenu  else {
                    return
                }
                
                resultTable.menu_id = menu.id
                resultTable.updated_at = evcDate
                resultTable.created_at = evcDate
                
                // Realmにデータを追加
                realm.add(resultTable, update: .modified)
                
                print("didTapAddNoteButton")
                print(menuResult ?? "menuResult is not found")
                print(selectedMenu ?? "selectedMenu is not found")
                
            }
            
            // 画面遷移
            self.performSegue(withIdentifier: "toSegueViewController", sender: nil)
        }
    }
}
