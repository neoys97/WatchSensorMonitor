//
//  ViewController.swift
//  SensorTracker
//
//  Created by Neo Yi Siang on 9/7/2020.
//

import UIKit
import WatchConnectivity
import MobileCoreServices

class ViewController: UIViewController {
    
    @IBOutlet weak var watchReachabilityLbl: UILabel!
    @IBOutlet weak var guideLbl: UILabel!
    @IBOutlet weak var fileNameTF: UITextField!
    @IBOutlet weak var folderManagerBtn: UIButton!
    @IBOutlet weak var mainBtn: UIButton!
    @IBOutlet weak var deviceNameBtn: UIButton!
    
    var tap: UITapGestureRecognizer?
    
    var watchSession: WCSession?
    var watchRunning = false
    let fileDataManager = FileDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainBtn.imageView?.contentMode = .scaleAspectFit
        mainBtn.contentVerticalAlignment = .fill
        mainBtn.contentHorizontalAlignment = .fill
        mainBtn.tintColor = .systemGreen
        folderManagerBtn.imageView?.contentMode = .scaleAspectFit
        folderManagerBtn.contentVerticalAlignment = .fill
        folderManagerBtn.contentHorizontalAlignment = .fill
        
        fileDataManager.delegate = self
        tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap!.cancelsTouchesInView = false
        view.addGestureRecognizer(tap!)
        
        let mainBtnLongPress = UILongPressGestureRecognizer(target: self, action: #selector(saveDataToCSV(_:)))
        mainBtn.addGestureRecognizer(mainBtnLongPress)
        setupWatchSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let watchSession = watchSession {
            if watchSession.isReachable {
                watchReachabilityLbl.text = "Watch reachable"
            }
            else {
                watchReachabilityLbl.text = "Watch unreachable"
            }
        }
        else {
            let alert = UIAlertController(title: "Watch error", message: "This phone is not connected to any watch. Connect the device to an Apple Watch and restart the application", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel) {[unowned self] action in
                self.disableAllUIElement()
                self.watchReachabilityLbl.text = "No paired watch"
            })
            self.present(alert, animated: true)
        }
    }
    
    func setupWatchSession() {
        if WCSession.isSupported() {
            watchSession = WCSession.default
            watchSession?.delegate = self
            watchSession?.activate()
        }
    }
    
    func disableAllUIElement() {
        mainBtn.isEnabled = false
        folderManagerBtn.isEnabled = false
        fileNameTF.isEnabled = false
    }
    
    func enableAllUIElement() {
        mainBtn.isEnabled = true
        folderManagerBtn.isEnabled = true
        fileNameTF.isEnabled = true
    }
    
    @IBAction func deviceNameBtnPressed(_ sender: Any) {
        guard watchSession?.isReachable == true else {
            let alert = UIAlertController(title: "Watch error", message: "Watch is not reachable, please wake or restart the app on watch", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
            self.present(alert, animated: true)
            return
        }
        watchSession?.sendMessage(["watchName": true], replyHandler: {[unowned self] message in
            let watchName = message["watchName"] as! String
            DispatchQueue.main.async {
                self.deviceNameBtn.setTitle(watchName, for: .normal)
            }
        }, errorHandler: nil)
    }
    
    @IBAction func mainBtnPressed(_ sender: Any) {
        guard watchSession?.isReachable == true else {
            let alert = UIAlertController(title: "Watch error", message: "Watch is not reachable, please wake or restart the app on watch", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
            self.present(alert, animated: true)
            return
        }
        watchSession?.sendMessage(["startSensor": !watchRunning], replyHandler: {[unowned self] message in
            let watchStatus = message["watchRunning"] as! Bool
            if watchStatus {
                self.fileDataManager.dataString = ""
                DispatchQueue.main.async {
                    UIView.transition(with: self.mainBtn, duration: 0.2, options: .curveEaseIn, animations: { [unowned self] in
                        self.mainBtn.tintColor = .systemRed
                        self.mainBtn.setImage(UIImage(systemName: "smallcircle.fill.circle"), for: .normal)
                        self.guideLbl.text = "Tap to stop"
                    })
                }
            }
            else {
                DispatchQueue.main.async {
                    UIView.transition(with: self.mainBtn, duration: 0.2, options: .curveEaseIn, animations: { [unowned self] in
                        self.mainBtn.tintColor = .systemGreen
                        self.mainBtn.setImage(UIImage(systemName: "largecircle.fill.circle"), for: .normal)
                        self.guideLbl.text = "Tap to start, long press to save"
                    })
                }
            }
            self.watchRunning = watchStatus
        }, errorHandler: nil)
    }
    
    @objc func saveDataToCSV(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            guard fileDataManager.dataString != "" else {
                let alert = UIAlertController(title: "File error", message: "File cannot be empty", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                self.present(alert, animated: true)
                return
            }
            if let fileName = fileNameTF.text {
                if fileName != "" {
                    if fileName.contains(" ") || fileName.contains(".") {
                        let alert = UIAlertController(title: "File name error", message: "File name cannot contain space or .", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                        self.present(alert, animated: true)
                    }
                    else {
                        if fileDataManager.checkFileExist(filename: fileName) {
                            let alert = UIAlertController(title: "File name error", message: "Duplicate file name. Please choose a different file name or delete the original file explicitly", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                            self.present(alert, animated: true)
                        }
                        else {
                            UIView.transition(with: mainBtn, duration: 0.2, options: .curveEaseIn, animations: { [unowned self] in
                                self.mainBtn.tintColor = .systemBlue
                                self.mainBtn.setImage(UIImage(systemName: "largecircle.fill.circle"), for: .normal)
                            })
                            fileDataManager.saveFileToCSV(to: fileName)
                        }
                    }
                }
                else {
                    let alert = UIAlertController(title: "File name error", message: "File name cannot be empty", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                    self.present(alert, animated: true)
                }
            }
            else {
                let alert = UIAlertController(title: "File name error", message: "File name cannot be empty", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                self.present(alert, animated: true)
            }
        }
    }
}

extension ViewController: UIDocumentPickerDelegate {
    @IBAction func folderBtnPressed(_ sender: Any) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeText as String], in: .open)
        documentPicker.delegate = self
        documentPicker.directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.present(documentPicker, animated: true, completion: nil)
    }
}

extension ViewController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print ("activated")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print ("become inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print ("deactivated")
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print ("changed")
        if let watchSession = watchSession {
            if watchSession.isReachable {
                DispatchQueue.main.async { [unowned self] in
                    self.watchReachabilityLbl.text = "Watch reachable"
                }
            }
            else {
                DispatchQueue.main.async { [unowned self] in
                    self.watchReachabilityLbl.text = "Watch unreachable"
                }
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        let dataString = message["data"] as! String
        print ("received")
        fileDataManager.receivedStringData(message: dataString)
    }
}

extension ViewController: FileDataManagerDelegate {
    func startWritingToFile() {
        self.disableAllUIElement()
    }
    
    func finishWritingToFile() {
        self.enableAllUIElement()
        print ("ok")
        DispatchQueue.main.async {
            UIView.transition(with: self.mainBtn, duration: 0.2, options: .curveEaseIn, animations: { [unowned self] in
                self.mainBtn.tintColor = .systemGreen
                self.mainBtn.setImage(UIImage(systemName: "largecircle.fill.circle"), for: .normal)
                self.guideLbl.text = "Tap to start"
            })
            let alert = UIAlertController(title: "Done", message: "Data has been written to \(self.fileNameTF.text ?? "").csv", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}
