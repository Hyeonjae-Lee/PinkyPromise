//
//  DayAndPromise.swift
//  PinkyPromise
//
//  Created by apple on 2020/01/29.
//  Copyright © 2020 hyejikim. All rights reserved.
//

import Foundation

struct DayAndPromise {
    var Day: Date!
    var promiseData: [PromiseTable]!
}

struct PromiseAndProgressforDate {
    var Day: Date
    var promiseData: PromiseTable
    var progressData: PromiseTable
}

struct PromiseAndProgressNotDay {
    var promiseData: PromiseTable
    var progressData: ProgressTable
}

struct PromiseAndProgress1 {
    var Day: Date!
    var PAPD: [PromiseAndProgressNotDay]
}

struct PromiseAndProgress {
    var Day: Date!
    var promiseData: [PromiseTable]
    var progressData: [ProgressTable]
}

struct MonthlyData {
    var DayPAP: [PromiseAndProgress]
}
