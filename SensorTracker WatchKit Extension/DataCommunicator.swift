//
//  DataCommunicator.swift
//  SensorTracker WatchKit Extension
//
//  Created by Neo Yi Siang on 10/7/2020.
//

import Foundation
import WatchKit
import WatchConnectivity
import CoreMotion

class DataCommunicator {
    var buffer: [MotionData] = []
    let bufferCap = 50
    let session: WCSession!
    let queue = OperationQueue()
    
    init(session: WCSession) {
        self.session = session
        buffer = []
        queue.maxConcurrentOperationCount = 1
        queue.name = "sendingQueue"
    }
}

extension DataCommunicator: MotionManagerDelegate {
    func receivedData(accData: CMAcceleration, gyroData: CMRotationRate) {
        buffer.append(MotionData(accData: accData, gyroData: gyroData))
        if buffer.count == bufferCap {
            var sendingMsg = ""
            var count = 0
            for d in self.buffer {
                count += 1
                sendingMsg.append(d.toString()+",\n")
            }
            self.session.sendMessage(["data": sendingMsg], replyHandler: nil, errorHandler: {_ in print ("wrong")})
            print (count)
            buffer.removeAll()
        }
    }
    
    func sensorStopped() {
        var sendingMsg = ""
        for d in self.buffer {
            sendingMsg.append(d.toString()+",\n")
        }
        self.session.sendMessage(["data": sendingMsg], replyHandler: nil, errorHandler: nil)
        buffer.removeAll()
    }
}
