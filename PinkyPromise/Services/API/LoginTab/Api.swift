//
//  Api.swift
//  PinkyPromise
//
//  Created by kimhyeji on 1/14/20.
//  Copyright © 2020 hyejikim. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseFirestore

/* 기본적으로 Auth.auth().currentuser 유저의 uid가 포함하고 있는 함수들만 있게함*/

class MyApi: NSObject {
    
    static let shared = MyApi()
    
    fileprivate let promiseCollectionRef = Firestore.firestore().collection(PROMISETABLEREF)
    fileprivate let userCollectionRef = Firestore.firestore().collection(PROMISEUSERREF)
    fileprivate let progressCollectionRef = Firestore.firestore().collection(PROGRESSTABLEREF)
    
    var promiseListner: ListenerRegistration!
    var delegate: SendProgressDelegate!
    let dateFormatter = DateFormatter()
    
    //    func fireStoreSetting() {
    //        let store = Firestore.firestore()
    //
    //        let setting = FirestoreSettings()
    //        setting.isPersistenceEnabled = true
    //        setting.cacheSizeBytes = FirestoreCacheSizeUnlimited
    //
    //        store.settings = setting
    //    }
    
    // Api 예시
    func allMore(completion: ([MoreTableData]) -> Void) { //}, onError: @escaping (Error) -> Void) {
        let result = [
            MoreTableData(title: "내 정보"),
            MoreTableData(title: "내 친구"),
            MoreTableData(title: "내 코드"),
        ]
        completion(result)
    }
    
    //20200229 회의록에 기재된 함수
    //Ended에서 사용하는 API 함수 두 개 삭제하고 achievement가 true 이면서 내 약속인 거 가져오는 API 함수 만들기
    func getPromiseDataWithTrueAchievement(completion: @escaping ([PromiseTable]) -> Void) {
        //var result = [PromiseTable]()
        
        promiseCollectionRef.whereField(PROMISEUSERS, arrayContains: FirebaseUserService.currentUserID!).whereField(ISPROMISEACHIEVEMENT, isEqualTo: false).getDocuments { (snapShot, error) in
            if let err = error {
                debugPrint(err.localizedDescription)
            } else {
                let tempResult = PromiseTable.parseData(snapShot: snapShot)
                completion(tempResult)
            }
        }
    }
    
    //유저 데이터가 업데이트될때마다 실행되며 업데이트된 데이터를 반환해줌, 클로저 사용
    func getUserUpdate(completion: @escaping ([PromiseUser]) -> Void) {
        var result = [PromiseUser]()
        //self.fireStoreSetting()
        
        //        userCollectionRef.document(FirebaseUserService.currentUserID!).add
        //        promiseListner = userCollectionRef.whereField(USERID, isEqualTo: FirebaseUserService.currentUserID!).addSnapshotListener({ (snapShot, error) in
        //            if let err = error {
        //                debugPrint(err)
        //            } else {
        //                result = PromiseUser.parseData(snapShot: snapShot)
        //                completion(result)
        //            }
        //        })
        
        userCollectionRef.document(FirebaseUserService.currentUserID!).addSnapshotListener { (document, error) in
            if let err = error {
                debugPrint(err)
            } else {
                //let dataDescription = document?.data()
                
                result = PromiseUser.parseDouc(snapShot: document)
                completion(result)
            }
        }
    }
    
    //유저 데이터를 반환해줌
    func getUserData(completion: @escaping ([PromiseUser]) -> Void) {
        var result = [PromiseUser]()
        //self.fireStoreSetting()
        
        userCollectionRef.document(FirebaseUserService.currentUserID!).getDocument { (document, error) in
            if let err = error {
                debugPrint(err)
                completion(result)
            } else {
                //let dataDescription = document?.data()
                result = PromiseUser.parseDouc(snapShot: document)
                completion(result)
            }
        }
        
        //        userCollectionRef.whereField(USERID, isEqualTo: FirebaseUserService.currentUserID!).getDocuments { (sanpShot, err) in
        //            if let err = err {
        //                debugPrint(err)
        //            }else {
        //                result = PromiseUser.parseData(snapShot: sanpShot)
        //                completion(result)
        //            }
        //        }
    }
    
    //UID에 맞는 유저 이름을 반환해줌
    func getUserNameWithUID(id: String, completion: @escaping (String) -> Void) {
        //self.fireStoreSetting()
        
        userCollectionRef.whereField(USERID, isEqualTo: id).getDocuments { (sanpShot, err) in
            if let err = err {
                debugPrint(err)
            }else {
                let result = PromiseUser.parseData(snapShot: sanpShot)
                if result.count > 0 {
                    completion(result[0].userName)
                }
                
            }
        }
    }
    
    //유저의 친구들의 promiseUser들 가져온다.
    func getUsersFriendsData(completion: @escaping ([PromiseUser]) -> Void) {
        //self.fireStoreSetting()
        //        userCollectionRef.whereField(USERID, isEqualTo: FirebaseUserService.currentUserID!).getDocuments { (snapShot, error) in
        //            if let err = error {
        //                debugPrint(err.localizedDescription)
        //            } else {
        //                let tempResult = PromiseUser.parseData(snapShot: snapShot)
        //                var temp = [PromiseUser]()
        //                var check1 = 0
        //
        //                if tempResult.count > 0 {
        //                    for douc in tempResult[0].userFriends {
        //                        self.getUserDataWithUID(id: douc) { (result) in
        //                            temp.append(result)
        //                            check1 += 1
        //                            if tempResult[0].userFriends.count <= check1 {
        //                                completion(temp)
        //                            }
        //                        }
        //                    }
        //                }
        //
        //            }
        //        }
        
        userCollectionRef.document(FirebaseUserService.currentUserID!).getDocument { (snapShot, error) in
            if let err = error {
                debugPrint(err.localizedDescription)
            } else {
                let tempResult = PromiseUser.parseDouc(snapShot: snapShot)
                var temp = [PromiseUser]()
                var check1 = 0
                
                for douc in tempResult[0].userFriends {
                    self.getUserDataWithUID(id: douc) { (result) in
                        temp.append(result)
                        check1 += 1
                        if tempResult[0].userFriends.count <= check1 {
                            completion(temp)
                        }
                    }
                }
            }
        }
    }
    
    //UID에 맞는 유저 데이터를 반환해줌
    func getUserDataWithUID(id: String, completion: @escaping (PromiseUser) -> Void) {
        //self.fireStoreSetting()
        //        var result = [PromiseUser]()
        //        userCollectionRef.whereField(USERID, isEqualTo: id).getDocuments { (sanpShot, err) in
        //            if let err = err {
        //                debugPrint(err)
        //            }else {
        //                result = PromiseUser.parseData(snapShot: sanpShot)
        //                let result2 = result[result.startIndex]
        //                completion(result2)
        //            }
        //        }
        
        var result = [PromiseUser]()
        userCollectionRef.document(id).getDocument { (sanpShot, err) in
            if let err = err {
                debugPrint(err)
            }else {
                result = PromiseUser.parseDouc(snapShot: sanpShot)
                let result2 = result[result.startIndex]
                completion(result2)
            }
        }
    }
    
    //약속 아이디를 가지고 약속한 친구의 이름들을 반환하는 함수
    func getPromiseFriendsNameWithPID(promiseID: String, completion: @escaping ([String]) -> Void) {
        //self.fireStoreSetting()
        promiseCollectionRef.whereField(PROMISEID, isEqualTo: promiseID).getDocuments { (snapsHot, error ) in
            if let err = error {
                debugPrint(err.localizedDescription)
            } else {
                let tempResult = PromiseTable.parseData(snapShot: snapsHot)
                var temp = [String]()
                
                let usersNotMe = tempResult[0].promiseUsers.filter { $0 != FirebaseUserService.currentUserID }
                
                for douc in usersNotMe {
                    self.getUserNameWithUID(id: douc) { (result) in
                        temp.append(result)
                        if temp.count == usersNotMe.count {
                            completion(temp)
                        }
                    }
                }
                
            }
        }
    }
    
    //약속 데이터를 반환// Input: PromiseID   Output: PromiseTable
    func getPromiseDataWithPromiseId(promiseid: String, completion: @escaping ([PromiseTable]) -> Void ){
        //self.fireStoreSetting()
        var result: [PromiseTable] = [] //[ProgressTable]()]
        //        var result: [ProgressTable]? = nil
        promiseCollectionRef.whereField(PROMISEID, isEqualTo: promiseid).getDocuments { (snapShot, error) in
            if let err = error {
                debugPrint("debug print \(err)")
            } else {
                result = PromiseTable.parseData(snapShot: snapShot)
                completion(result)
                
            }
        }
    }
    
    //약속 데이터를 반환// 내가 포함되어 있는 녀석들만
    func getPromiseData(completion: @escaping ([PromiseTable]) -> Void) {
        //self.fireStoreSetting()
        var result = [PromiseTable]()
        promiseCollectionRef.whereField(PROMISEUSERS, arrayContains: FirebaseUserService.currentUserID!).getDocuments { (sanpShot, err) in
            if let err = err {
                debugPrint(err)
            }else {
                result = PromiseTable.parseData(snapShot: sanpShot)
                completion(result)
            }
        }
    }
    
    
    //이미 끝난 약속 데이터만 반환하는 함수
    func getCompletedPromiseData(completion: @escaping ([PromiseTable]) -> Void) {
        let now3 = Date(timeIntervalSince1970: ceil(Date().timeIntervalSince1970/86400)*86400 + 21600 - (15*3600))
        //let result = now3.timeIntervalSince1970
        //self.fireStoreSetting()
        promiseCollectionRef.whereField(PROMISEUSERS, arrayContains: FirebaseUserService.currentUserID!).whereField(PROMISEENDTIME, isLessThan: now3).getDocuments { (snapShot, error) in
            if let err = error {
                debugPrint(err.localizedDescription)
            } else {
                let tempResult = PromiseTable.parseData(snapShot: snapShot)
                self.getPerfectCompletedPromiseData(promises: tempResult, completion: { result in
                    completion(result)
                })
            }
        }
        
    }
    
    //끝난 약속 데이터를 인풋으로, 이중에서 프로그레스 배열이 모두 4인 경우만 약속 반환
    func getPerfectCompletedPromiseData(promises: [PromiseTable], completion: @escaping ([PromiseTable]) -> Void) {
        var result = [PromiseTable]()
        //self.fireStoreSetting()
        
        var countcheck = 0
        for douc in promises {
            progressCollectionRef.whereField(USERID, isEqualTo: FirebaseUserService.currentUserID!).whereField(PROMISEID, isEqualTo: douc.promiseId).getDocuments { (snapShot, error) in
                if let err = error {
                    debugPrint(err.localizedDescription)
                } else {
                    let tempResult = ProgressTable.parseData(snapShot: snapShot)
                    
                    if tempResult.count > 0 {
                        let check4 = tempResult[0].progressDegree.contains { $0 < 4 }
                        
                        if check4 == false {
                            result.append(douc)
                            if promises.count <= countcheck {
                                completion(result)
                            }
                        }
                    }
                }
            }
            countcheck += 1
        }
    }
    
    //func getPromiseAndProgress()
    
    
    //약속 데이터가 업데이트되면 실행되며 업데이트되는 데이터를 받아줌
    func getPromiseUpdate(completion: @escaping ([PromiseTable]) -> Void) {
        var result = [PromiseTable]()
        //self.fireStoreSetting()
        
        //        promiseListner = promiseCollectionRef.order(by: PROMISEACHIEVEMENT, descending: true).addSnapshotListener({ (snapShot, error) in
        promiseListner = promiseCollectionRef.whereField(PROMISEUSERS, arrayContains: FirebaseUserService.currentUserID!).addSnapshotListener({ (snapShot, error) in
            if let err = error {
                debugPrint(err)
            } else {
                result = PromiseTable.parseData(snapShot: snapShot)
                completion(result)
            }
        })
    }
    
    //약속 id를 인풋으로 프로그레스테이블의 정보 반환
    func getProgressDataWithPromiseId(promiseid: String, completion: @escaping ([ProgressTable]) -> Void ){
        //self.fireStoreSetting()
        var result: [ProgressTable] = [] //[ProgressTable]()]
        //        var result: [ProgressTable]? = nil
        progressCollectionRef.whereField(USERID, isEqualTo: FirebaseUserService.currentUserID!).whereField(PROMISEID, isEqualTo: promiseid).getDocuments { (snapShot, error) in
            if let err = error {
                debugPrint("debug print \(err)")
            } else {
                result = ProgressTable.parseData(snapShot: snapShot)
                completion(result)
                
            }
        }
    }
    
    //겉
    //약속 id와 uid를 인풋으로 프로그레스테이블의 정보 반환
    func getProgressDataWithPromiseIdAndUid(promiseid: String, uid: String, completion: @escaping ([ProgressTable]) -> Void ){
        //self.fireStoreSetting()
        var result: [ProgressTable] = [] //[ProgressTable]()]
        progressCollectionRef.whereField(USERID, isEqualTo: uid).whereField(PROMISEID, isEqualTo: promiseid).getDocuments { (snapShot, error) in
            if let err = error {
                debugPrint("debug print \(err)")
            } else {
                result = ProgressTable.parseData(snapShot: snapShot)
                completion(result)
                
            }
        }
    }
    
    //프로그레스테이블에 원하는 유저의 uid를 인풋으로 그 유저의 프로그레스 정보를 알 수 있다
    func getProgressDataWithUid(userid: String, completion: @escaping ([ProgressTable]) -> Void ) {
        //self.fireStoreSetting()
        var result = [ProgressTable]()
        progressCollectionRef.whereField(USERID, isEqualTo: userid).getDocuments { (snapShot, error) in
            
            if let err = error {
                debugPrint("debug print \(err)")
            } else {
                result = ProgressTable.parseData(snapShot: snapShot)
                completion(result)
            }
            
        }
    }
    
    //프로그레스테이블의 유저의 정보를 알 수 있다.
    func getAllProgressData(completion: @escaping ([ProgressTable]) -> Void ){
        //self.fireStoreSetting()
        var result = [ProgressTable]()
        progressCollectionRef.whereField(USERID, isEqualTo: FirebaseUserService.currentUserID!).getDocuments { (snapShot, error) in
            if let err = error {
                debugPrint("debug print \(err)")
            } else {
                result = ProgressTable.parseData(snapShot: snapShot)
                completion(result)
            }
        }
    }
    
    //오늘을 기준으로 30일 이전 약속들을 [PromiseTable]을 하나의 배열 요소로 가지는 배열
    //업데이트됨
    func getPromiseData30ToNow(completion: @escaping ([DayAndPromise]) -> Void ) {
        //self.fireStoreSetting()
        
        let now3 = Date(timeIntervalSince1970: ceil( Date().timeIntervalSince1970/86400)*86400 + 21600 - (15*3600))
        
        promiseCollectionRef.whereField(PROMISEUSERS, arrayContains: FirebaseUserService.currentUserID!).order(by: PROMISEENDTIME).getDocuments { (snapShot, error) in
            if let err = error {
                debugPrint(err.localizedDescription)
            } else {
                let tempResult = PromiseTable.parseData(snapShot: snapShot)
                var temp1 = [DayAndPromise]()
                
                //30일 전부터 30일 후까지
                for i in stride(from: now3.timeIntervalSince1970 - (2592000 * 3), through: now3.timeIntervalSince1970 + (2592000 * 3), by: 86400) {
                    var temp2 = [PromiseTable]()
                    
                    for douc in tempResult {
                        if (i >= douc.promiseStartTime.timeIntervalSince1970) && (i <= douc.promiseEndTime.timeIntervalSince1970) {
                            temp2.append(douc)
                        }
                    }
                    
                    let temp3 = DayAndPromise(Day: Date(timeIntervalSince1970: i + 21600 - (15 * 3600)), promiseData: temp2)
                    temp1.append(temp3)
                }
                completion(temp1)
            }
        }
    }
    
    //오늘을 기준으로 약속이 끝날 때까지의 날짜별 데이터
    func getPromiseDataSorted(completion: @escaping ([[PromiseTable]]) -> Void ) {
        
        let now3 = Date(timeIntervalSince1970: ceil(Date().timeIntervalSince1970/86400)*86400 + 21600 - (15*3600))
        let result = now3.timeIntervalSince1970
        //let now2 = Timestamp()
        
        promiseCollectionRef.whereField(PROMISEUSERS, arrayContains: FirebaseUserService.currentUserID!).whereField(PROMISEENDTIME, isGreaterThan: result).order(by: PROMISEENDTIME).getDocuments { (snapShot, error) in
            if let err = error {
                debugPrint(err.localizedDescription)
            } else {
                let tempResult = PromiseTable.parseData(snapShot: snapShot)
                
                let MaxTime = tempResult.count
                if MaxTime > 0 {
                    let maxTimeDate = tempResult[MaxTime].promiseEndTime
                    
                    var temp1 = [[PromiseTable]]()
                    
                    for i in stride(from: now3.timeIntervalSince1970, through: maxTimeDate.timeIntervalSince1970, by: 60*60*24) {
                        //i는 하루하루의 타임스탬프
                        
                        var temp2 = [PromiseTable]()
                        
                        for douc in tempResult {
                            if (i > douc.promiseStartTime.timeIntervalSince1970) && (i < douc.promiseEndTime.timeIntervalSince1970) {
                                temp2.append(douc)
                            }
                        }
                        temp1.append(temp2)
                    }
                    
                    completion(temp1)
                }
            }
        }
    }
    
    //선영쿤이 요청한 함수 -> friendTab에 들어갈 데이터
    func getPromiseNameAndFriendsName(completion: @escaping ([promiseNameAndFriendsName]) -> Void) {
        
        let now2 = Timestamp()
        let now3 = Date(timeIntervalSince1970: ceil(Date().timeIntervalSince1970/86400)*86400 + 21600 - (15*3600))
        
        //self.fireStoreSetting()
        promiseCollectionRef.whereField(PROMISEUSERS, arrayContains: FirebaseUserService.currentUserID!).whereField(PROMISEENDTIME, isGreaterThanOrEqualTo: now3).getDocuments { (snapShot, error) in
            if let err = error {
                debugPrint(err.localizedDescription)
            }else {
                let tempResult = PromiseTable.parseData(snapShot: snapShot)
                var result1 = [promiseNameAndFriendsName]()
                var check = 0
                for douc in tempResult {
                    let FriendsList = douc.promiseUsers.filter { $0 != FirebaseUserService.currentUserID }
                    
                    let temp = promiseNameAndFriendsName(promiseName: douc.promiseName, promiseId: douc.promiseId, FirstuserImage: douc.promiseName, friendsName: FriendsList)
                    
                    if FriendsList.count == 0 {//친구가 없으면 패스하고 check에 1을 더해준다.
                        check += 1
                    } else {
                        self.getFriendsName(tempTable: temp) { (result) in
                            result1.append(result)
                            if result1.count + check >= tempResult.count {
                                completion(result1)
                            }
                        }
                    }
                }
            }
        }
    }
    
    //getPromiseNameAndFriendsName의 부속함수, 약속테이블의 사용자의 친구들의 이름을 반환함
    func getFriendsName(tempTable: promiseNameAndFriendsName, completion: @escaping (promiseNameAndFriendsName) -> Void ){
        
        //self.fireStoreSetting()
        var temp2 = [String]()
        let temp4 = tempTable.friendsName.sorted()
        for douc in temp4 {
            self.getUserNameWithUID(id: douc) { (result) in
                temp2.append(result)
                if temp2.count == tempTable.friendsName.count {
                    let temp3 = promiseNameAndFriendsName(promiseName: tempTable.promiseName, promiseId: tempTable.promiseId, FirstuserImage: temp4[0], friendsName: temp2.sorted())
                    completion(temp3)
                }
            }
        }
    }
    
    func getDataforDetailViewjrWithoutMe(promiseID: String, completion: @escaping (promiseDetail) -> Void) {
        //self.fireStoreSetting()
        promiseCollectionRef.whereField(PROMISEID, isEqualTo: promiseID).getDocuments { (snapshot, error) in
            if let err = error {
                debugPrint(err.localizedDescription)
            } else {
                let result = PromiseTable.parseData(snapShot: snapshot)
                
                if result.count > 0 {
                    let promiseDay = Double( (result[0].promiseEndTime.timeIntervalSince1970 - result[0].promiseStartTime.timeIntervalSince1970) / 86400)
                    
                    let promiseDaysinceToday = Double( ( Date(timeIntervalSince1970: ceil(Date().timeIntervalSince1970/86400)*86400 + 21600 - (15*3600)).timeIntervalSince1970 - result[0].promiseStartTime.timeIntervalSince1970 ) / 86400 )
                    
                    let tempUsers = result[0].promiseUsers.filter { $0 != FirebaseUserService.currentUserID }
                    
                    let temp = promiseDetailjunior1(promiseName: result[0].promiseName, promiseDay: promiseDay, promiseDaySinceStart: promiseDaysinceToday, friendsUIDList: tempUsers)
                    
                    //completion(temp)
                    
                    self.getDataForDetailViewjr2(detailData1: temp) { (result2) in
                        
                        completion(result2)
                    }
                }
            }
        }
    }
    
    //선영쿤이 요청한 detailView 진행중인 약속에 한해 들어간다.
    //이거 쿼리 물어봐야함 도대체 왜 세개하면 invalid라고 뜰
    func getDataforDetailViewjr1(promiseID: String, completion: @escaping (promiseDetail) -> Void) {
        //self.fireStoreSetting()
        promiseCollectionRef.whereField(PROMISEID, isEqualTo: promiseID).getDocuments { (snapshot, error) in
            if let err = error {
                debugPrint(err.localizedDescription)
            } else {
                let result = PromiseTable.parseData(snapShot: snapshot)
                
                if result.count > 0 {
                    let promiseDay = Double( (result[0].promiseEndTime.timeIntervalSince1970 - result[0].promiseStartTime.timeIntervalSince1970) / 86400)
                    
                    let promiseDaysinceToday = Double( ( Date(timeIntervalSince1970: ceil(Date().timeIntervalSince1970/86400)*86400 + 21600 - (15*3600)).timeIntervalSince1970 - result[0].promiseStartTime.timeIntervalSince1970 ) / 86400 )
                    
                    //let tempUsers = result[0].promiseUsers.filter { $0 != FirebaseUserService.currentUserID }
                    
                    let temp = promiseDetailjunior1(promiseName: result[0].promiseName, promiseDay: promiseDay, promiseDaySinceStart: promiseDaysinceToday, friendsUIDList: result[0].promiseUsers)
                    
                    //completion(temp)
                    
                    self.getDataForDetailViewjr2(detailData1: temp) { (result2) in
                        
                        completion(result2)
                    }
                }
            }
        }
    }
    
    func getDataForDetailViewjr2(detailData1: promiseDetailjunior1, completion: @escaping (promiseDetail) -> Void) {
        
        var temp4 = [promiseDetailChild]()
        
        for douc in detailData1.friendsUIDList {
            self.getUserDataWithUID(id: douc) { (result3) in
                
                self.getProgressDataWithUid(userid: douc) { (result4) in
                    
                    var temp6 = Array<Int>(repeating: 0, count: 5)
                    
                    if result4.count > 0 {
                        for i in result4[0].progressDegree {
                            switch i {
                            case 0:
                                temp6[i] += 1
                            case 1:
                                temp6[i] += 1
                            case 2:
                                temp6[i] += 1
                            case 3:
                                temp6[i] += 1
                            case 4:
                                temp6[i] += 1
                            case -1:
                                print("")
                            //-1은 안한거다.
                            default:
                                print("cuase default at getDataForDetailViewjr2")
                            }
                        }
                    } 
                    
                    let zek = promiseDetailChild(friendName: result3.userName, friendImage: result3.userImage, friendDegree: temp6)
                    temp4.append(zek)
                    
                    if temp4.count == detailData1.friendsUIDList.count {
                        
                        temp4.sort { $0.friendName < $1.friendName }
                        
                        completion(promiseDetail(promiseName: detailData1.promiseName, promiseDay: detailData1.promiseDay, promiseDaySinceStart: detailData1.promiseDaySinceStart, friendsDetail: temp4))
                        
                    }
                }
            }
        }
    }
    
    //오늘을 기준으로 끝나지 않은 약속들만 반환
    func getPromiseDataSinceToday(completion: @escaping ([PromiseTable]) -> Void) {
        let now3 = Date(timeIntervalSince1970: ceil(Date().timeIntervalSince1970/86400)*86400 + 21600 - (15*3600))
        //let result = now3.timeIntervalSince1970
        //self.fireStoreSetting()
        
        promiseCollectionRef.whereField(PROMISEUSERS, arrayContains: FirebaseUserService.currentUserID!).whereField(PROMISEENDTIME, isGreaterThanOrEqualTo: now3).getDocuments { (snapShot, error) in
            if let err = error {
                debugPrint(err.localizedDescription)
            } else {
                let tempResult = PromiseTable.parseData(snapShot: snapShot)
                completion(tempResult)
            }
        }
    }
    
    //의정쿤이 요청한 함수 졸라게 어려붐 펔큉 극강빌런임
    func getMothlyDataWithCurrentMonth(completion: @escaping ([PromiseAndProgress]) -> Void) {
        //self.fireStoreSetting()
        let days = self.getTotalDate()//이번 달의 날짜 수 31일
        
        let cal = Calendar.current
        let components = cal.dateComponents([.year, .month, .day, .weekday, .hour, .minute], from: Date())
        
        //let todayMonth = components.month //이번 달이 몇번째 달인지
        let todayDay = components.day // 오늘이 며칠째인지
        
        let firstDay = Date(timeIntervalSince1970: Date().timeIntervalSince1970 - Double(86400 * (todayDay! - 1)) + 32400)//이번달의 첫번째 날
        
        let calendar = Calendar(identifier: .gregorian)
        
        _ = DateComponents(calendar:calendar, year:components.year, month:components.month, day:1) //그 달 1일
        
        //components.day => 오늘날짜
        var temp = [PromiseAndProgress]()
        
        for i in 0 ..< days {//이번달 일수만큼
            
            let firstDayPlusi = Date(timeIntervalSince1970: firstDay.timeIntervalSince1970 + Double(i * 86400) )
            
            promiseCollectionRef.whereField(PROMISEUSERS, arrayContains: FirebaseUserService.currentUserID!).whereField(PROMISEENDTIME, isGreaterThanOrEqualTo: firstDay ).getDocuments { (snapShot, error ) in
                
                if let err = error {
                    debugPrint(err.localizedDescription)
                } else {
                    
                    let tempResult1 = PromiseTable.parseData(snapShot: snapShot)
                    
                    let tempResult2 = tempResult1.filter { $0.promiseStartTime.timeIntervalSince1970 <= firstDayPlusi.timeIntervalSince1970 && $0.promiseEndTime.timeIntervalSince1970 >= firstDayPlusi.timeIntervalSince1970 }
                    
                    self.getMothlyDataWithCurrentMonth2(day1: firstDayPlusi, promiseData: tempResult2) { (result2) in
                        
                        //result2는 PromiseAndProgress객체임
                        
                        temp.append(result2)
                        
                        if temp.count >= days {
                            completion(temp)
                        }
                        
                    }
                    
                    
                }
            }
        }
    }
    
    
    func getMothlyDataWithCurrentMonth2(day1: Date, promiseData: [PromiseTable], completion: @escaping (PromiseAndProgress) -> Void ) {
        
        var temp11 = [ProgressTable]()
        
        if promiseData.count > 0 {
            for douc in promiseData {
                
                progressCollectionRef.whereField(PROMISEID, isEqualTo: douc.promiseId).whereField(USERID, isEqualTo: FirebaseUserService.currentUserID!).getDocuments { (snapShot, error) in
                    if let err = error {
                        print("this is err..1 \(err.localizedDescription)")
                        
                    } else {
                        let temp2 = ProgressTable.parseData(snapShot: snapShot)
                        
                        temp11.append(temp2[0])
                        
                        if temp11.count >= promiseData.count {
                            completion(PromiseAndProgress(Day: day1, promiseData: promiseData, progressData: temp11))
                        }
                        
                    }
                }
                
            }
        }
            
        else {
            let temp1 = [PromiseTable]()
            let temp2 = [ProgressTable]()
            completion(PromiseAndProgress(Day: day1, promiseData: temp1, progressData: temp2))
        }
        
    }
    
    //제발.. 오늘을 기준으로 이번 달의 날짜를 반환
    func getTotalDate() -> Int{
        // choose the month and year you want to look
        let date = Date()
        let calendar = Calendar.current
        let componentsYear = calendar.dateComponents([.year], from: date)
        let year = componentsYear.year
        let componentsMonth = calendar.dateComponents([.month], from: date)
        let month = componentsMonth.month
        
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        
        let datez = calendar.date(from: dateComponents)
        // change .month into .year to see the days available in the year
        let interval = calendar.dateInterval(of: .month, for: datez!)!
        
        let days = calendar.dateComponents([.day], from: interval.start, to: interval.end).day!
        
        return days
    }
    
    //real homeTab
    func getAllHome(completion: @escaping ([PromiseAndProgress1]) -> Void){
        let days = self.getTotalDate()//이번 달의 날짜 수 31일
        
        let cal = Calendar.current
        let components = cal.dateComponents([.year, .month, .day, .weekday, .hour, .minute], from: Date())
        
        let todayDay = components.day // 오늘이 며칠째인지
        
        var firstDay = Date(timeIntervalSince1970: Date().timeIntervalSince1970 - Double(86400 * (todayDay! - 1)) + 32400)//이번달의 첫번째 날
        
        let secondDay = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: firstDay)
        let thirdDay = Date(timeIntervalSince1970: secondDay!.timeIntervalSince1970 + Double(32400))
        firstDay = thirdDay
        
        var temp3 = [PromiseAndProgress1]()
        
        self.getAllDataWithDate(day: firstDay) { (result) in
            temp3.append(result)
            self.getAllDataWithDate(day: Date(timeIntervalSince1970: firstDay.timeIntervalSince1970 + Double(1 * 86400) ) ) { (result2) in
                temp3.append(result2)
                self.getAllDataWithDate(day: Date(timeIntervalSince1970: firstDay.timeIntervalSince1970 + Double(2 * 86400) ) ) { (result2) in
                    temp3.append(result2)
                    self.getAllDataWithDate(day: Date(timeIntervalSince1970: firstDay.timeIntervalSince1970 + Double(3 * 86400)) ) { (result2) in
                        temp3.append(result2)
                        self.getAllDataWithDate(day: Date(timeIntervalSince1970: firstDay.timeIntervalSince1970 + Double(4 * 86400) ) ) { (result2) in
                            temp3.append(result2)
                            self.getAllDataWithDate(day: Date(timeIntervalSince1970: firstDay.timeIntervalSince1970 + Double(5 * 86400)) ) { (result2) in
                                temp3.append(result2)
                                self.getAllDataWithDate(day: Date(timeIntervalSince1970: firstDay.timeIntervalSince1970 + Double(6 * 86400) ) ) { (result2) in
                                    temp3.append(result2)
                                    self.getAllDataWithDate(day: Date(timeIntervalSince1970: firstDay.timeIntervalSince1970 + Double(7 * 86400)) ) { (result2) in
                                        temp3.append(result2)
                                        self.getAllDataWithDate(day: Date(timeIntervalSince1970: firstDay.timeIntervalSince1970 + Double(8 * 86400) ) ) { (result2) in
                                            temp3.append(result2)
                                            self.getAllDataWithDate(day: Date(timeIntervalSince1970: firstDay.timeIntervalSince1970 + Double(9 * 86400) ) ) { (result2) in
                                                temp3.append(result2)
                                                self.getAllDataWithDate(day: Date(timeIntervalSince1970: firstDay.timeIntervalSince1970 + Double(10 * 86400) ) ) { (result2) in
                                                    temp3.append(result2)
                                                    self.getAllDataWithDate(day: Date(timeIntervalSince1970: firstDay.timeIntervalSince1970 + Double(11 * 86400)) ) { (result2) in
                                                        temp3.append(result2)
                                                        self.getAllDataWithDate(day: Date(timeIntervalSince1970: firstDay.timeIntervalSince1970 + Double(12 * 86400) ) ) { (result2) in
                                                            temp3.append(result2)
                                                            self.getAllDataWithDate(day: Date(timeIntervalSince1970: firstDay.timeIntervalSince1970 + Double(13 * 86400) ) ) { (result2) in
                                                                temp3.append(result2)
                                                                self.getAllDataWithDate(day: Date(timeIntervalSince1970: firstDay.timeIntervalSince1970 + Double(14 * 86400)) ) { (result2) in
                                                                    temp3.append(result2)
                                                                    self.getAllDataWithDate(day: Date(timeIntervalSince1970: firstDay.timeIntervalSince1970 + Double(15 * 86400)) ) { (result2) in
                                                                        temp3.append(result2)
                                                                        self.getAllDataWithDate(day: Date(timeIntervalSince1970: firstDay.timeIntervalSince1970 + Double(16 * 86400) ) ) { (result2) in
                                                                            temp3.append(result2)
                                                                            self.getAllDataWithDate(day: Date(timeIntervalSince1970: firstDay.timeIntervalSince1970 + Double(17 * 86400)) ) { (result2) in
                                                                                temp3.append(result2)
                                                                                self.getAllDataWithDate(day: Date(timeIntervalSince1970: firstDay.timeIntervalSince1970 + Double(18 * 86400)) ) { (result2) in
                                                                                    temp3.append(result2)
                                                                                    self.getAllDataWithDate(day: Date(timeIntervalSince1970: firstDay.timeIntervalSince1970 + Double(19 * 86400) ) ) { (result2) in
                                                                                        temp3.append(result2)
                                                                                        self.getAllDataWithDate(day: Date(timeIntervalSince1970: firstDay.timeIntervalSince1970 + Double(20 * 86400)) ) { (result2) in
                                                                                            temp3.append(result2)
                                                                                            self.getAllDataWithDate(day: Date(timeIntervalSince1970: firstDay.timeIntervalSince1970 + Double(21 * 86400) ) ) { (result2) in
                                                                                                temp3.append(result2)
                                                                                                self.getAllDataWithDate(day: Date(timeIntervalSince1970: firstDay.timeIntervalSince1970 + Double(22 * 86400) ) ) { (result2) in
                                                                                                    temp3.append(result2)
                                                                                                    self.getAllDataWithDate(day: Date(timeIntervalSince1970: firstDay.timeIntervalSince1970 + Double(23 * 86400)) ) { (result2) in
                                                                                                        temp3.append(result2)
                                                                                                        self.getAllDataWithDate(day: Date(timeIntervalSince1970: firstDay.timeIntervalSince1970 + Double(24 * 86400) ) ) { (result2) in
                                                                                                            temp3.append(result2)
                                                                                                            self.getAllDataWithDate(day: Date(timeIntervalSince1970: firstDay.timeIntervalSince1970 + Double(25 * 86400) ) ) { (result2) in
                                                                                                                temp3.append(result2)
                                                                                                                self.getAllDataWithDate(day: Date(timeIntervalSince1970: firstDay.timeIntervalSince1970 + Double(26 * 86400) ) ) { (result2) in
                                                                                                                    temp3.append(result2)
                                                                                                                    self.getAllDataWithDate(day: Date(timeIntervalSince1970: firstDay.timeIntervalSince1970 + Double(27 * 86400) ) ) { (result2) in
                                                                                                                        temp3.append(result2)
                                                                                                                        self.getAllDataWithDate(day: Date(timeIntervalSince1970: firstDay.timeIntervalSince1970 + Double(28 * 86400) ) ) { (result2) in
                                                                                                                            temp3.append(result2)
                                                                                                                            if days > 29 {
                                                                                                                                self.getAllDataWithDate(day: Date(timeIntervalSince1970: firstDay.timeIntervalSince1970 + Double(29 * 86400) ) ) { (result2) in
                                                                                                                                    temp3.append(result2)
                                                                                                                                    if days > 30 {
                                                                                                                                        self.getAllDataWithDate(day: Date(timeIntervalSince1970: firstDay.timeIntervalSince1970 + Double(30 * 86400) ) ) { (result2) in
                                                                                                                                            temp3.append(result2)
                                                                                                                                            completion(temp3)
                                                                                                                                        }
                                                                                                                                    } else {
                                                                                                                                        completion(temp3)
                                                                                                                                    }}} else {
                                                                                                                                completion(temp3)
                                                                                                                            }}}}}}}}}}}}}}}}}}}}}} }}}}}}}}
    }
    
    
    func getAllDataWithDate(day: Date, completion: @escaping (PromiseAndProgress1) -> Void) {
        
        promiseCollectionRef.whereField(PROMISEUSERS, arrayContains: FirebaseUserService.currentUserID).getDocuments { (snapShot, error) in
            if let err = error {
                print(err.localizedDescription)
            } else {
                let promises = PromiseTable.parseData(snapShot: snapShot)
                
                let promises2 = promises.filter { $0.promiseEndTime.timeIntervalSince1970 >= day.timeIntervalSince1970 && $0.promiseStartTime.timeIntervalSince1970 <= day.timeIntervalSince1970 }
                
                var temp = [PromiseAndProgressNotDay]()
                
                for douc in promises2 {
                    self.progressCollectionRef.whereField(USERID, isEqualTo: FirebaseUserService.currentUserID).whereField(PROMISEID, isEqualTo: douc.promiseId).getDocuments { (snapShot, error) in
                        if let err = error {
                            print(err.localizedDescription)
                        } else {
                            let progress1 = ProgressTable.parseData(snapShot: snapShot)
                            let temp2 = PromiseAndProgressNotDay(promiseData: douc, progressData: progress1[0])
                            temp.append(temp2)
                            
                            if temp.count == promises2.count {
                                completion(PromiseAndProgress1(Day: day, PAPD: temp))
                            }
                        }
                    }
                }
                if promises2.count == 0 {
                    completion(PromiseAndProgress1(Day: day, PAPD: temp))
                }
            }
        }
    }
    
    //약속 데이터를 추가할 때 사용하는 함수
    func addPromiseData(_ promiseTable: PromiseTable) {
        
        var temp = promiseTable.promiseUsers
        temp.append(FirebaseUserService.currentUserID!)
        
        promiseCollectionRef.document(promiseTable.promiseId).setData([
            PROMISENAME : promiseTable.promiseName ?? "Anomynous",
            PROMISECOLOR: promiseTable.promiseColor ?? "nil",
            PROMISEICON: promiseTable.promiseIcon ?? "nil",
            ISPROMISEACHIEVEMENT: promiseTable.isPromiseAchievement ?? false,
            PROMISESTARTTIME: promiseTable.promiseStartTime,
            PROMISEENDTIME: promiseTable.promiseEndTime,
            PROMSISEPANALTY: promiseTable.promisePanalty ?? "nil",
            PROMISEUSERS: temp,
            PROMISEID: promiseTable.promiseId ?? "nil"
        ]) { error in
            if let err = error {
                debugPrint("Error adding document : \(err)")
            } else {
                print("parsing success")
            }
        }
    }
    
    //사용자 데이터를 추가할 때 사용하는 함수
    func addUserData(_ userTable: PromiseUser) {
        
        userCollectionRef.document(userTable.userId).setData([
            USERNAME : userTable.userName ?? "Anomynous",
            USERFRIENDS: userTable.userFriends ?? [],
            USERID: userTable.userId ?? "nil",
            USERIMAGE: userTable.userImage ?? "404",
            USERCODE: userTable.userCode ?? Int.random(in: 100000...999999)
        ]) { error in
            if let err = error {
                debugPrint("Error adding document : \(err)")
            } else {
                print("this is API success")
            }
        }
        
    }
    
    //프로그레스테이블에 데이터 추가, addPromiseTable 직후 같은 promiseTable을 넣어준다.
    func addProgressData(_ promiseTable: PromiseTable) {
        
        var temp = promiseTable.promiseUsers
        temp.append(FirebaseUserService.currentUserID!)
        
        let indexTime = Int(promiseTable.promiseEndTime.timeIntervalSince1970 - promiseTable.promiseStartTime.timeIntervalSince1970) / 86400
        let indexPromiseId = promiseTable.promiseId
        
        for douc in temp {//약속에 있는 유저 개수만큼 progressTable을 만든다.
            let temp1 = [Int](repeating: -1, count: indexTime + 1)
            
            progressCollectionRef.addDocument( data: [
                PROGRESSDEGREE: temp1,
                PROMISEID: indexPromiseId ?? "nil",
                USERID: douc
            ]) { error in
                if let err = error {
                    debugPrint("error adding document : \(err)")
                } else {
                    print("this is API success")
                }
            }
        }
    }
    
    func addFriendWithCode(code: Int, completion: @escaping (PromiseUser?) -> Void) {
        userCollectionRef.whereField(USERCODE, isEqualTo: code).getDocuments { (snapShot, error) in
            if let err = error {
                debugPrint(err.localizedDescription)
            }else {
                let result = PromiseUser.parseData(snapShot: snapShot)
                //result는 원소가 1인 배열이거나 혹은 0인 배열, 코드를 입력했을때 그코드에 맞는 사용자가 있다.
                
                if result.count > 0 {
                    //code를 가지는 사용자가 있다는 의미
                    
                    if result[0].userId != FirebaseUserService.currentUserID {
                        //본인이 아닐 경우 사용자에 친구 추가 누름
                        
                        self.getUserData { (result2) in
                            
                            var temp = result2[0].userFriends//나의 친구들
                            let tempadd = temp!.contains { $0 == (result[0].userId) }//나의 친구들 중에 친구가 이미 있는지검사
                            if tempadd == false {//친구가 없으면
                                temp?.append(result[0].userId)//내 친구목록에 추가
                            }
                            var temp2 = result[0].userFriends//친구의 친구들
                            let tempadd2 = temp2!.contains { $0 == FirebaseUserService.currentUserID }//친구의 친구목록중 내가 있는지 검사
                            if tempadd2 == false {//친구가 없으면
                                temp2?.append(FirebaseUserService.currentUserID!)
                            }
                            self.userCollectionRef.document(result[0].userId).setData([USERFRIENDS : temp2!], merge: true); self.userCollectionRef.document(FirebaseUserService.currentUserID!).setData( [USERFRIENDS : temp!], merge: true )
                        }
                    }
                    
                    self.getUserDataWithUID(id: result[0].userId) { (result) in
                        completion(result)
                    }
                } else {
                    //사용자가 없다. 고로 result는 0, 빈 배열
                    completion(nil)
                }
            }
        }
    }
    
    //유저를 uid를 이용해서 유저를 삭제하는 함수
    func deleteUserWithUid(Uid: String, completion: @escaping (Bool)-> Void) {
        //let uid = Auth.auth().currentUser!.uid
        let uid = Uid
        userCollectionRef.whereField(USERID, isEqualTo: uid).getDocuments { (snapshot, error) in
            if let err = error {
                print("get error in delete user with uid... with \(err)")
            } else {
                var temp = 0
                for document in snapshot!.documents {
                    //document.reference.delete()
                    document.reference.delete { (Error) in
                        if let err = Error {
                            debugPrint(err.localizedDescription)
                            completion(false)
                        } else {
                            temp += 1
                            if temp == snapshot!.documents.count {
                                completion(true)
                            }
                        }
                    }
                    
                }
            }
        }
        
    }
    
    //약속을 약속 id를 사용해서 삭제하는 함수
    //약속 id는 약속 doucment id를 의미한다.
    func deletePromiseWithDocumentId(_ promiseId: String) {
        promiseCollectionRef.document(promiseId).delete() { error in
            if let err = error {
                print("delete promise cause \(err)..")
            } else {
                print("delete promise success")
            }
        }
    }
    
    func deleteMeFromFriend(Uid: String, completion: @escaping (Bool) -> Void) {
        userCollectionRef.document(Uid).getDocument { (DocumentSnapshot, Error) in
            if let err = Error {
                debugPrint(err.localizedDescription)
                completion(false)
            } else {
                let tempMe = PromiseUser.parseDouc(snapShot: DocumentSnapshot)
                //tempMe 는 나잖아
                if tempMe.count > 0 {
                    var tempCount = 0
                    
                    if tempMe[0].userFriends.count == 0 {//친구가 없으면 바로 completion
                        completion(true)
                    }
                    for douc in tempMe[0].userFriends {//나의 친구들 명수만큼
                        self.userCollectionRef.document(douc).getDocument { (DocumentSnapshot2, Error) in
                            if let err = Error {
                                debugPrint(err.localizedDescription)
                            } else {
                                //친구들의 친구목록중에서 나를 제거함
                                let tempFriend = PromiseUser.parseDouc(snapShot: DocumentSnapshot2)
                                let tempFriendWithoutMe = tempFriend[0].userFriends.filter { $0 != Uid }
                                self.userCollectionRef.document(tempFriend[0].documentId).updateData([USERFRIENDS : tempFriendWithoutMe]) { (Error) in
                                    if let err = Error {
                                        debugPrint(err.localizedDescription)
                                        completion(false)
                                    }else {
                                        tempCount += 1
                                        if tempCount == tempMe[0].userFriends.count {
                                            completion(true)
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    //내가 가지고 있던 약속들이랑 프로그레스 삭제하기
    func deleteAboutMe( completion: @escaping (Bool) -> Void) {
        MyApi.shared.getPromiseData { (result) in
            var tempCount = 0
            if result.count == 0 {
                completion(true)
            }
             for douc in result {
                MyApi.shared.deletePromiseWithPromiseID(Uid: FirebaseUserService.currentUserID!, PromiseID: douc.promiseId) { (result3) in
                    tempCount += 1
                    if tempCount == result.count * 2 {
                        completion(true)
                    }
                }
                //MyApi.shared.deleteProgressWithpromiseID(Uid: FirebaseUserService.currentUserID!, promiseId: douc.promiseId)
                MyApi.shared.deleteProgressWithpromiseID(Uid: FirebaseUserService.currentUserID!, promiseId: douc.promiseId) { (result2) in
                    tempCount += 1
                    if tempCount == result.count * 2 {
                        completion(true)
                    }
                }
            }
            
        }
    }
    
    //progress를 uid와 promiseID 사용해서 삭제하는함수
    func deleteProgressWithpromiseID(Uid: String, promiseId: String, completion: @escaping (Bool) -> Void) {
        //let uid = Auth.auth().currentUser!.uid
        progressCollectionRef.whereField(USERID, isEqualTo: Uid).whereField(PROMISEID, isEqualTo: promiseId).getDocuments { (QuerySnapshot, error) in
            if let err = error {
                debugPrint(err.localizedDescription)
            }else {
                var temp = 0
                for douc in QuerySnapshot!.documents {
                    self.progressCollectionRef.document(douc.documentID).delete { (Error) in
                        if let err = Error {
                            debugPrint(err.localizedDescription)
                        }else {
                            temp += 1
                            if temp == QuerySnapshot!.documents.count {
                                completion(true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    //promiseID를 사용해서 promiseTable 안에 자신을 삭제할 수 있다.
    //유저가 한명인 경우 약속 자체를 없애고 유저가 여러명인경우 나 한명만 없앤다.
    func deletePromiseWithPromiseID(Uid: String, PromiseID: String, completion: @escaping (Bool) -> Void) {
        promiseCollectionRef.document(PromiseID).getDocument { (DocumentSnapshot, Error) in
            if let err = Error {
                debugPrint(err.localizedDescription)
            } else {
                let promiseTemp = PromiseTable.parseDouc(snapShot: DocumentSnapshot)
                if promiseTemp.count > 0 {
                    //값을 가지고 왔을 경우
                    if promiseTemp[0].promiseUsers.count == 1 {
                        //유저가 한명인 경우 약속 자체를 없앤다.
                        self.promiseCollectionRef.document(PromiseID).delete { (Error) in
                            if let err = Error {
                                debugPrint(err.localizedDescription)
                            }else {
                                completion(true)
                            }
                        }
                        //self.deleteProgressWithpromiseID(Uid: Uid, promiseId: PromiseID)//프로그레스도 없애준다.
                        
                    } else if promiseTemp[0].promiseUsers.count > 1 {
                        //유저가 여러명인경우 유저 한명만 없앤다.
                        let tempUsers = promiseTemp[0].promiseUsers.filter { $0 != Uid }
                        self.promiseCollectionRef.document(PromiseID).updateData([PROMISEUSERS : tempUsers]) { (Error) in
                            if let err = Error {
                                debugPrint(err.localizedDescription)
                            }else {
                                completion(true)
                            }
                        }
                        //self.deleteProgressWithpromiseID(Uid: Uid, promiseId: PromiseID)//프로그레스도 없애준다.
                    }
                }
            }
        }
    }
    
    //프로그레스 입력뷰
    func updateProgress(day: Date, userId: String, data: Int, promise: PromiseTable, progress: ProgressTable ){
        progressCollectionRef.whereField(USERID, isEqualTo: userId).whereField(PROMISEID, isEqualTo: promise.promiseId!).getDocuments { (snapShot, error) in
            if let err = error {
                debugPrint(err.localizedDescription)
            } else {
                //프로그레스 갖고오기
                
                let progressTemp = ProgressTable.parseData(snapShot: snapShot)
                
                let datindex = Int(day.timeIntervalSince1970 - promise.promiseStartTime.timeIntervalSince1970) / 86400
                var temp: [Int] = progressTemp[0].progressDegree
                temp[datindex] = data
                self.progressCollectionRef.document((snapShot?.documents[0].documentID)!).updateData([PROGRESSDEGREE : temp]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                        self.delegate.sendProgress(data: data)
                    }
                    
                }
            }
        }
    }
    
    func updateUserNameinAppleLogin(name: String) {
        userCollectionRef.document(FirebaseUserService.currentUserID!).updateData([USERNAME: name]) { err in
            if let error = err {
                debugPrint(error.localizedDescription)
            } else {
                print("update name success!!")
            }
        }
    }
    
    //프로미스 어치브먼트 바꾸는함수
    func updatePromiseAchievement(promiseID: String) {
        promiseCollectionRef.document(promiseID).updateData([ISPROMISEACHIEVEMENT : true])
    }
    
    func updateUserImageName(userImageName: String) {
        userCollectionRef.document(FirebaseUserService.currentUserID!).updateData([USERIMAGE : userImageName])
    }
    
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if length == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        //let index = result.index(result.startIndex, offsetBy: 20)
        return String(result.prefix(20))
    }
    
    // VC file에 이렇게 사용
    //    MyApi.shared.allMenu(completion: { result in
    //               DispatchQueue.main.async {
    //                   self.moreTableList = result
    //                   self.moreTableView.reloadData()
    //               }
    //           })
    
    
}
