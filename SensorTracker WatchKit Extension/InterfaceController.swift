//
//  InterfaceController.swift
//  SensorTracker WatchKit Extension
//
//  Created by Neo Yi Siang on 9/7/2020.
//

import WatchKit
import Foundation
import CoreMotion
import WatchConnectivity
import CoreLocation
import HealthKit

class InterfaceController: WKInterfaceController {

    @IBOutlet weak var sessionStatusLbl: WKInterfaceLabel!
    @IBOutlet weak var nameLabel: WKInterfaceLabel!
    //    @IBOutlet weak var reachabilityLbl: WKInterfaceLabel!
    
    let deviceInterface = WKInterfaceDevice.current()
    var motionManager: MotionManager!
    var communicator: DataCommunicator!
    let session = WCSession.default

    let healthStore = HKHealthStore()
    var keepAliveSession: HKWorkoutSession?
    var healthKitTypesToRead: Set<HKObjectType> =  [HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!]
    var healthKitTypesToWrite = Set<HKSampleType>()
    let workoutConfiguration = HKWorkoutConfiguration()
    
    var currentName = ""
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        motionManager = MotionManager()
        communicator = DataCommunicator(session: session)
        motionManager.delegate = communicator
        workoutConfiguration.activityType = .tennis
        workoutConfiguration.locationType = .outdoor
        
        session.delegate = self
        session.activate()
        healthStore.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { (success, error) -> Void in
            print ("authorised")
        }
//        if session.isReachable {
//            reachabilityLbl.setText("App reachable")
//        }
//        else {
//            reachabilityLbl.setText("App unreachable")
//        }
        if deviceInterface.wristLocation == .left {
            currentName = randomString(length: 4) + "-Left"
        }
        else {
            currentName = randomString(length: 4) + "-Right"
        }
        nameLabel.setText(currentName)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        print("close")
    }
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
}

extension InterfaceController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print ("watch activated")
        sessionStatusLbl.setText("Activated idle")
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let _ = message["watchName"] as? Bool {
            replyHandler(["watchName": currentName])
        }
        else if let startSensor = message["startSensor"] as? Bool {
            print (startSensor)
            if startSensor {
                do {
                    keepAliveSession = try HKWorkoutSession(healthStore: healthStore, configuration: workoutConfiguration)
                }
                catch {
                    fatalError("Unable to create the workout session!")
                }
                sessionStatusLbl.setText("Activated running")
                keepAliveSession!.startActivity(with: Date())
                motionManager.startSensors()
                replyHandler(["watchRunning": true])
            }
            else {
                sessionStatusLbl.setText("Activated idle")
                keepAliveSession!.stopActivity(with: Date())
                keepAliveSession!.end()
                keepAliveSession = nil
                motionManager.stopSensors()
                replyHandler(["watchRunning": false])
            }
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        if (session.isReachable) {
//            reachabilityLbl.setText("App reachable")
            print("App reachable")
        }
        else {
//            reachabilityLbl.setText("App unreachable")
            print("App unreachable")
        }
    }
}


