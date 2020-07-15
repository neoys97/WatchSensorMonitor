//
//  MotionManager.swift
//  SensorTracker WatchKit Extension
//
//  Created by Neo Yi Siang on 10/7/2020.
//

import WatchKit
import Foundation
import CoreMotion
import WatchConnectivity

class MotionManager: NSObject {
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    let wristLocationIsLeft = WKInterfaceDevice.current().wristLocation == .left
    let sampleInterval = 1.0/50.0
    var delegate: MotionManagerDelegate!
        
    override init() {
        super.init()
        queue.maxConcurrentOperationCount = 1
        queue.name = "MotionManagerQueue"
    }
    
    func startSensors() {
        if !motionManager.isDeviceMotionAvailable {
            print("Device Motion is not available.")
            return
        }
        motionManager.deviceMotionUpdateInterval = sampleInterval
        motionManager.startDeviceMotionUpdates(to: queue) { (deviceMotion: CMDeviceMotion?, error: Error?) in
            if error != nil {
                print("Encountered error: \(error!)")
            }
            if deviceMotion != nil {
                self.processDeviceMotion(deviceMotion!)
            }
        }
    }
    
    func stopSensors() {
        motionManager.stopDeviceMotionUpdates()
        delegate.sensorStopped()
    }
    
    func processDeviceMotion(_ deviceMotion: CMDeviceMotion) {
        delegate.receivedData(accData: deviceMotion.gravity, gyroData: deviceMotion.rotationRate)
    }
}

protocol MotionManagerDelegate {
    func receivedData (accData: CMAcceleration, gyroData: CMRotationRate)
    func sensorStopped ()
}
