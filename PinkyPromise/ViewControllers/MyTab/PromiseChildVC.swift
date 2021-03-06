///
//  PromiseChildVC.swift
//  PinkyPromise
//
//  Created by kimhyeji on 1/14/20.
//  Copyright © 2020 hyejikim. All rights reserved.
//

import UIKit

class PromiseChildVC: UIViewController {
    
    @IBOutlet weak var endedPromiseBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var promiseList: [PromiseTable]? {
        didSet { collectionView.reloadData() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpCollectionView()
        // getAllPromiseData()
        initView()
        
    }
    
    // MARK: wantToFix
    override func viewWillAppear(_ animated: Bool) {
        getAllPromiseData()
        
    }
    
    private func setUpCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    // 통신
    private func getAllPromiseData() {
        PromiseChildService.shared.getPromiseDataSinceToday(completion: { result in
            DispatchQueue.main.async {
                self.promiseList = result
            }
        })
        
    }
    
    @IBAction func endedPromiseBtnAction(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "EndedPromiseVC") as! EndedPromiseVC
        
        vc.modalTransitionStyle = .flipHorizontal
        vc.modalPresentationStyle = .overCurrentContext
        
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
}

// MARK:- Initialization
extension PromiseChildVC {
    private func initView() {
        setupBtn()
    }
    
    func setupBtn() {
        endedPromiseBtn.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        endedPromiseBtn.layer.cornerRadius = 8.0
        
        endedPromiseBtn.applyShadow(radius: 5.0, color: .gray, offset: CGSize(width: 0.0, height: 1.0), opacity: 1.0)
        endedPromiseBtn.layer.masksToBounds = false
        
        let attributedString = NSAttributedString(string: "100% 지킨 약속 보러가기", attributes: [
            .font: UIFont.boldSystemFont(ofSize: 20.0),
            .foregroundColor: UIColor.appColor //.withAlphaComponent(0.8)
        ])
        endedPromiseBtn.setAttributedTitle(attributedString, for: .normal)
    }
}

extension PromiseChildVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.bounds.width - CGFloat(32.0)
        let height = collectionView.bounds.height
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 약속 디테일 뷰로 이동해야함. 약속 정보를 가지고
        performSegue(withIdentifier: "promiseDetail", sender: promiseList?[indexPath.row])

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "promiseDetail"{
            let promiseDetail = sender as? PromiseTable
            if promiseDetail != nil{
                let PromiseDetailVC = segue.destination as? PromiseDetailVC
                if PromiseDetailVC != nil {
                    PromiseDetailVC?.promiseDetail = promiseDetail
                }
            }
        }
    }
    
    
}

extension PromiseChildVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let promiseList = promiseList else {
            return 1
        }
        return promiseList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        
        if let promiseCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "PromiseCVC", for: indexPath) as? PromiseCVC {
            
            if let list = promiseList {
                
                let rowData = list[indexPath.item]
                
                // 날짜만 비교해서 며칠 남았는지 뽑아낸다
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let today = Date()
                let startDate = rowData.promiseStartTime
                let endDate = rowData.promiseEndTime
                
                let interval = endDate.timeIntervalSince(startDate)
                let days = Int(interval / 86400) + 1
                
                let leftInterval = endDate.timeIntervalSince(today)
                let left = Int(leftInterval / 86400) + 1
                
                /** 날짜 차이와 시간 차이까지 알고 싶으면
                 let calendar = Calendar.current
                 let dateGap = calendar.dateComponents([.year,.month,.day,.hour], from: startDate, to: endDate)
                 
                 if case let (y?, m?, d?, h?) = (dateGap.year, dateGap.month, dateGap.day, dateGap.hour)
                 {
                 print("\(y)년 \(m)개월 \(d)일 \(h)시간 후")
                 }
                 */
                
                promiseCell.leftDays.text = "\(left)일남음"
                promiseCell.totalDays.text = String(days)
                
                // slider의 max 값을 변경
                promiseCell.appSlider.maximumValue = Float(days)
                
                promiseCell.promiseIcon.image = UIImage(named: rowData.promiseIcon)
                promiseCell.promiseName.text = rowData.promiseName
                
                
                var promiseAchievement:Int = 0
                let sliderValueOriginX = CGFloat(15)
                
                if let id = rowData.promiseId {
                    PromiseChildService.shared.getProgressDataWithPromiseId(promiseid: id, completion: { result in
                        DispatchQueue.main.async {
                            if result.isEmpty != true {
                                
                                for degree in result[0].progressDegree {
                                    if degree > 0 {
                                        promiseAchievement += 1
                                    }
                                }
                            }
                            
                            promiseCell.appSlider.value = Float(promiseAchievement)
                            if promiseAchievement == days {
                                promiseCell.showSliderValue.text = ""
                            } else {
                                promiseCell.showSliderValue.text = String(promiseAchievement)
                            }
                            
                            let calcValue = CGFloat( Float(promiseAchievement) / promiseCell.appSlider.maximumValue * Float(promiseCell.appSlider.frame.width))
                            
                            promiseCell.showSliderValue.center = CGPoint(x: sliderValueOriginX + calcValue, y: 81)   
                        }
                    })
                }
            }
            
            cell = promiseCell
        }
        return cell
    }
    
}

