//
//  DataManger.swift
//  GuestlogixTest
//
//  Created by Byung Yoo on 2018-09-25.
//  Copyright © 2018 Theta Labs Inc. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps


// All data-related stuff goes here (the csv files).
// Approach: the files will be parsed and stored as array of string arrays (2D)
// (alternative: Core Data)

extension ViewController{
    
    
    
    // method to read data from CSV
    func readDataFromCSV(fileName:String, fileType: String)-> String!{
        guard let filepath = Bundle.main.path(forResource: fileName, ofType: fileType)
            else {
                print("file nil")
                return nil
        }
        do {
            var contents = try String(contentsOfFile: filepath, encoding: .utf8)
            contents = cleanRows(file: contents)
            return contents
        } catch {
            print("File Read Error for file \(filepath)")
            return nil
        }
    }

    
    // to clean up the newline characters just in case
    func cleanRows(file:String)->String{
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        
        return cleanFile
    }
    
    
    // parse each row of the CSV file
    func parseCSVData(data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ",")
            result.append(columns)
        }
        return result
    }
    
    
    // read all three files
    func readFiles(){
        

        var airlinesDataTemp = readDataFromCSV(fileName: "airlines", fileType: "csv")
        
        airlinesDataTemp = cleanRows(file: airlinesDataTemp!)
        airlinesData = parseCSVData(data: airlinesDataTemp!)
        
        
        var routesDataTemp = readDataFromCSV(fileName: "routes", fileType: "csv")
        
        routesDataTemp = cleanRows(file: routesDataTemp!)
        routesData = parseCSVData(data: routesDataTemp!)
        
        var airportsDataTemp = readDataFromCSV(fileName: "airports", fileType: "csv")
        
        airportsDataTemp = cleanRows(file: airportsDataTemp!)
        airportsData = parseCSVData(data: airportsDataTemp!)
      
        
    }
    
    
    
}
