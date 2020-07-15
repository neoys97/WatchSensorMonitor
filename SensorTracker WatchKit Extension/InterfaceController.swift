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
    @IBOutlet weak var reachabilityLbl: WKInterfaceLabel!
    var motionManager: MotionManager!
    var communicator: DataCommunicator!
    let session = WCSession.default

    let healthStore = HKHealthStore()
    var keepAliveSession: HKWorkoutSession?
    var healthKitTypesToRead: Set<HKObjectType> =  [HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!]
    var healthKitTypesToWrite = Set<HKSampleType>()
    let workoutConfiguration = HKWorkoutConfiguration()
    
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
        if session.isReachable {
            reachabilityLbl.setText("App reachable")
        }
        else {
            reachabilityLbl.setText("App unreachable")
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        if session.isReachable {
            reachabilityLbl.setText("App reachable")
        }
        else {
            reachabilityLbl.setText("App unreachable")
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        print("close")
    }

    
}

extension InterfaceController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print ("watch activated")
        sessionStatusLbl.setText("Activated idle")
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        let startSensor = message["startSensor"] as! Bool
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
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        if (session.isReachable) {
            reachabilityLbl.setText("App reachable")
        }
        else {
            reachabilityLbl.setText("App unreachable")
        }
    }
}


