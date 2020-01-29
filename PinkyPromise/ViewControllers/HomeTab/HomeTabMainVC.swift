//
//  HomeTabMainVC.swift
//  PinkyPromise
//
//  Created by kimhyeji on 1/13/20.
//  Copyright © 2020 hyejikim. All rights reserved.
//

import UIKit
import EventKit
import FSCalendar
import Floaty

class HomeTabMainVC: UIViewController {
    
    //    @IBOutlet weak var addPromiseBtn: UIButton!
    //    @IBOutlet weak var nearPromiseLabel: UILabel!
    //    @IBOutlet weak var nearPromise: UILabel!
    fileprivate weak var calendar: FSCalendar!
    fileprivate weak var eventLabel: UILabel!
    var addPromiseBtn: AddPromiseBtn!
    weak var tableView: UITableView!
    private var promiseListforDates: [ProgressTable]!
    
    let dateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_kr")
        formatter.timeZone = TimeZone(abbreviation: "KST")
        return formatter
    }()
    
    struct Promise {
        let promiseName: String
        let promiseColor: String
        let progress: Int
    }
    
    struct Day {
        var day: Date
        var promise: [Promise]
    }
    
    var days: [Day] = [
        
        Day(day: Date(), promise: [
            Promise(promiseName: "독서", promiseColor: "red", progress: 0),
            Promise(promiseName: "1DAY 1COMMIT", promiseColor: "yellow", progress: 1)
        ]),
        Day(day: Date(timeInterval: 86400, since: Date()), promise: [
            Promise(promiseName: "yellow", promiseColor: "yellow", progress: 2),
            Promise(promiseName: "green", promiseColor: "green", progress: 1),
            Promise(promiseName: "blue", promiseColor: "blue", progress: 0),
            Promise(promiseName: "purple", promiseColor: "purple", progress: 2),
            Promise(promiseName: "blue", promiseColor: "blue", progress: 1),
            Promise(promiseName: "green", promiseColor: "green", progress: 1),
            Promise(promiseName: "systemPink", promiseColor: "systemPink", progress: 0)
        ]),
        Day(day: Date(timeInterval: 172800, since: Date()), promise: [
            Promise(promiseName: "purple", promiseColor: "purple", progress: 4),
            Promise(promiseName: "green", promiseColor: "green", progress: 4),
            Promise(promiseName: "systemPink", promiseColor: "systemPink", progress: 4)
        ])
    ]
    
    override func loadView() {
       
        // initialize UI
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor.white
        self.view = view
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 50, width: self.view.frame.size.width, height: 33))
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 27.0)
        titleLabel.attributedText = NSAttributedString(string: "PinkyPromise")
        view.addSubview(titleLabel)
        
        //        let height: CGFloat = UIDevice.current.model.hasPrefix("iPad") ? 400 : 300
        let calendar = FSCalendar(frame: CGRect(x: 0, y: titleLabel.frame.maxY, width: view.frame.size.width, height: view.frame.size.width - 90))
        calendar.dataSource = self
        calendar.delegate = self
        //        calendar.allowsMultipleSelection = true
        view.addSubview(calendar)
        self.calendar = calendar
        
        calendar.appearance.headerTitleColor = UIColor.systemPurple
        
        calendar.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize: 20.0)
        calendar.appearance.weekdayTextColor = UIColor.darkText
        calendar.appearance.borderSelectionColor = UIColor.systemPurple
        calendar.appearance.selectionColor = UIColor.clear
        calendar.appearance.titleSelectionColor = UIColor.darkText
        
        calendar.appearance.headerMinimumDissolvedAlpha = 0
        
        calendar.appearance.todayColor = UIColor.systemPurple
        
        calendar.appearance.eventOffset = CGPoint(x: 0, y: -7)
        calendar.register(MyCalendarCell.self, forCellReuseIdentifier: "cell")
        //        calendar.clipsToBounds = true // Remove top/bottom line
        
        calendar.swipeToChooseGesture.isEnabled = true // Swipe-To-Choose
        
        let scopeGesture = UIPanGestureRecognizer(target: calendar, action: #selector(calendar.handleScopeGesture(_:)));
        calendar.addGestureRecognizer(scopeGesture)
        
        
        let label = UILabel(frame: CGRect(x: 0, y: calendar.frame.maxY, width: self.view.frame.size.width, height: 50))
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.font = UIFont.boldSystemFont(ofSize: 20.0)
        self.view.addSubview(label)
        self.eventLabel = label
        
        let attributedText = NSMutableAttributedString(string: "")
        attributedText.append(NSAttributedString(string: "Today"))
        self.eventLabel.attributedText = attributedText
        
        let myTableView: UITableView = UITableView(frame: CGRect(x: 0, y: eventLabel.frame.maxY + 10, width: self.view.frame.size.width, height: self.view.frame.size.height - self.tabBarController!.tabBar.frame.size.height - self.eventLabel.frame.maxY))
        
        view.addSubview(myTableView)
        
        self.tableView = myTableView
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let nibName = UINib(nibName: "DayPromiseListTVC", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "DayPromiseListCell")
        
        addPromiseBtn = AddPromiseBtn(frame: CGRect(x: self.view.center.x - 25, y: self.view.frame.size.height - self.tabBarController!.tabBar.frame.size.height - 110, width: 50, height: 50));
        
        addPromiseBtn.fabDelegate = self
        self.view.addSubview(addPromiseBtn)
        
//        // data setting
//        print(FirebaseUserService.currentUserID)
//        DispatchQueue.global().sync {
//            MyApi.shared.getProgressDataWithUid(userid: FirebaseUserService.currentUserID, completion: { (result) in
//                self.promiseListforDates = result
//                print(self.promiseListforDates[0].progressDay)
//            })
//        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        initView()
        setTableViewUI()
    }
    
    @IBAction func addPromiseBtnAction(_ sender: Any) {
        let vc = storyboard!.instantiateViewController(withIdentifier: "HomeNavigationController")
        
        vc.modalTransitionStyle = .flipHorizontal
        vc.modalPresentationStyle = .overCurrentContext
        
        self.present(vc, animated: false, completion: nil)
        
    }
}

// MARK: Init
extension HomeTabMainVC {
    //    private func initView() {
    //        setupLabel()
    //        setupBtn()
    //    }
}

extension HomeTabMainVC {
    
    //    func setupBtn() {
    ////        addPromiseBtn.layer.cornerRadius = addPromiseBtn.layer.frame.height/2
    //        addPromiseBtn.makeCircle()
    //    }
}



extension HomeTabMainVC: FSCalendarDataSource, FSCalendarDelegate {
    
    // 날짜 선택 시 콜백
    public func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        changeDateFormatKR(date: date)
        self.tableView.reloadData()
    }
    
    // 날짜 선택 해제 시 콜백
    public func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosion: FSCalendarMonthPosition) {
        
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position) as! MyCalendarCell
        cell.setBackgroundColor(progress: 0)
        configureVisibleCells()
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendar.frame.size.height = bounds.height
        self.eventLabel.frame.origin.y = calendar.frame.maxY + 10
        self.tableView.frame.origin.y = eventLabel.frame.maxY + 10
    }
    
    private func configureVisibleCells() {
        
        let cells = calendar.visibleCells() as! [MyCalendarCell]
        cells.forEach { (cell) in
            let date = calendar.date(for: cell)
            
            days.forEach { (day) in
                if self.dateFormat.string(from: day.day) == self.dateFormat.string(from: date!) {
                    
                    var progress: Int = 0
                    day.promise.forEach { (pm) in
                        progress += pm.progress
                        print(day.day)
                    }
                    cell.setBackgroundColor(progress: CGFloat(progress / day.promise.count) + 1)
                }
            }
        }
    }
    
}


extension HomeTabMainVC {
    func changeDateFormatKR(date: Date) {
        
        let today = Date()
        
        if self.dateFormat.string(from: today) == self.dateFormat.string(from: date) {
            eventLabel.text = "Today"
        }
        else{
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "eee"
            
            dateFormat.locale = Locale(identifier: "ko_kr")
            dateFormat.timeZone = TimeZone(abbreviation: "KST")
            
            let cal = Calendar.current
            let components = cal.dateComponents([.year, .month, .day, .weekday, .hour, .minute], from: date)
            if let eventLabel = eventLabel {
                eventLabel.text = "\(components.month!)월 \(components.day!)일 \(dateFormat.string(from: date))요일"
            }
        }
    }
}

extension HomeTabMainVC: UITableViewDelegate {}
extension HomeTabMainVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let date = calendar.selectedDate ?? Date()
        var count = 0

        days.forEach { (day) in
            if self.dateFormat.string(from: day.day) == self.dateFormat.string(from: date) {
                count = day.promise.count
            }
        }
        return count

        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DayPromiseListTVC = (tableView.dequeueReusableCell(withIdentifier: "DayPromiseListCell") as! DayPromiseListTVC)
        
        let date = calendar.selectedDate ?? Date()
        
        days.forEach { (day) in
            if self.dateFormat.string(from: day.day) == self.dateFormat.string(from: date) {
                cell.promiseName.text = day.promise[indexPath.row].promiseName
            }
        }
        
        cell.view.layer.backgroundColor = UIColor.systemPurple.withAlphaComponent(CGFloat(0.1)).cgColor
        //        cell.layer.borderWidth = 1
        cell.view.layer.cornerRadius = 8
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}

extension HomeTabMainVC {
    func setTableViewUI() {
        // tableView 뷰 변경
        let dummyView = UIView(frame:CGRect(x: 0, y: 0, width: 0, height: 0))
        self.tableView.tableFooterView = dummyView;
        self.tableView.clipsToBounds = false
    }
}

extension HomeTabMainVC: FloatyDelegate {
    func emptyFloatySelected(_ floaty: Floaty) {
        
        let storyboard = UIStoryboard(name: "HomeTab", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "HomeNavigationController")
        
        vc.modalTransitionStyle = .flipHorizontal
        vc.modalPresentationStyle = .overCurrentContext
        
        self.present(vc, animated: false, completion: nil)
        
    }
}
