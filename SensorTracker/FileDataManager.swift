//
//  FileManager.swift
//  SensorTracker
//
//  Created by Neo Yi Siang on 14/7/2020.
//

import Foundation

class FileDataManager {
    var dataString: String = ""
    var delegate: FileDataManagerDelegate?
    let rootPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileManager = FileManager.default
    
    func receivedStringData(message: String) {
        dataString += message
    }
    
    func saveFileToCSV(to filename: String) {
        delegate?.startWritingToFile()
        let url = rootPath.appendingPathComponent(filename + ".csv")
        do {
            print("writing")
            try dataString.write(to: url, atomically: true, encoding: .utf8)
            dataString = ""
        }
        catch {
            print(error.localizedDescription)
        }
        delegate?.finishWritingToFile()
    }
    
    func checkFileExist(filename: String) -> Bool {
        let url = rootPath.appendingPathComponent(filename + ".csv")
        if fileManager.fileExists(atPath: url.path) {
            return true
        }
        else {
            return false
        }
    }
}

protocol FileDataManagerDelegate {
    func startWritingToFile()
    func finishWritingToFile()
}
