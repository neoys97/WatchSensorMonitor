//
//  MotionData.swift
//  SensorTracker WatchKit Extension
//
//  Created by Neo Yi Siang on 10/7/2020.
//

import Foundation
import CoreMotion

class MotionData: Encodable, Decodable {
    var timeStamp: Double
    var acc: [Double]
    var gyro: [Double]
    init(accData: CMAcceleration, gyroData: CMRotationRate) {
        timeStamp = Date.currentTimeStamp
        acc = []
        acc.append(accData.x)
        acc.append(accData.y)
        acc.append(accData.z)
        gyro = []
        gyro.append(gyroData.x)
        gyro.append(gyroData.y)
        gyro.append(gyroData.z)
    }
    
    func toString() -> String {
        return("\(timeStamp),\(acc[0]),\(acc[1]),\(acc[2]),\(gyro[0]),\(gyro[1]),\(gyro[2])")
    }
}

extension Date {
    static var currentTimeStamp: Double{
        return Double(Date().timeIntervalSince1970 * 1000)
    }
}
