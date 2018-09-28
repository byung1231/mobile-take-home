//
//  ViewController.swift
//  GuestlogixTest
//
//  Created by Byung Yoo on 2018-09-24.
//  Copyright © 2018 Theta Labs Inc. All rights reserved.
//

import UIKit
import GoogleMaps
import Foundation


// ---------------------- Notes ----------------------
// Each possible route found will be stored a 3-d array 'nextRoutesToBeTested', starting with the origin
// Each row will represent a single level/depth of the route, e.g. [2][0][0] and [2][1][0] are the same level/depth. [3][1][0] would be the next route
// Along the search (done in checkPath()), starting from the origin:
//          1. All existing routes will be added to the arrays on the next row
//          2. A 2nd level array will be created for each origin, and all possible destinations on the 3rd level array within the same 2nd level array
//          3. Repeat for all existing entries on the array
//
// For example, for the following routes:
// A,B
// A,C
// A,D
// B,E
// B,F
// C,G
// C,H
// D,I
// E,J
// F,K
// G,L
// G,M
// H,O
// H,P
// I,Q
// and if we are looking for the path from A to P,
// the array nextRoutesToBeTested would be added as follows:
//
///     [0][0]["A"]
//      [1][0]["B","C","D"]
//      [2][0]["E","F"], [2][1]["G","H"], [2][2]["I"]
//      [3][0]["J"], [3][1]["K"], [3][2]["L,M"], [3][3]["O","P"], [3][4]["Q"]
//
// Search will be done in a breadth first search manner rather than depth first, starting from the first row,
// and each iteration of search will go through each entry, treating each entry as the temporary origin
// Once the destionation has been found, the traced back which is exaplined in checkPath() before the traversal part
//
// Assumption:
// The search will assume there won't be more than 7 stops in any routes.
// Search will stop if the destination has not been found after going over 7 levels in the search (realistically, and also to prevent infinite loops), and will alert the users as no possible routes existing

// --------------------------------------------------




class ViewController: UIViewController {

    @IBOutlet weak var txtOrigin: UITextField!
    @IBOutlet weak var txtDestination: UITextField!
    @IBOutlet weak var lblDestination: UILabel!
    @IBOutlet weak var lblOrigin: UILabel!
    @IBOutlet weak var btnGo: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var lblRouteTitle: UILabel!
    @IBOutlet weak var lblRoute: UILabel!
    
    // arrays to hold the csv data
    var airportsData = [[String]]()
    var airlinesData = [[String]]()
    var routesData = [[String]]()
    
    // stores all the
    var tempRoute = [String]()
    var routeCount = Int()
    
    
    // 3-d array storing all possible routes while searching for paths
    var nextRoutesToBeTested = [[[String]]]()
    
    // counter for 3rd level array along the search iterations (i.e. [][][tempCount])
    var tempCount = 0
    
    // counter for 2nd level array along the search iterations (i.e. [][tempCount2][])
    var tempCount2 = 0
    
    // position of an element in the 2nd level array, flattened.
    // used when tracing back from the destiation found
    var flattenedPositionCount = Int()
    
    // flag to indicate if the destination actually exists on the routes list
    var destinationExists = Bool()
    
    // flag to indicate if any route exists from the (temporary) origin during the iteration
    var routeExists = Bool()
    
    // show Toronto by default when the app is first launched
    var camera = GMSCameraPosition.camera(withLatitude: 43.6532, longitude: -79.3832, zoom: 6.0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // show Toronto
        mapView.camera = camera

        // read the CSV files first
        readFiles()
        
        // auto-capitalizing entries on the text boxes
        txtOrigin.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        txtDestination.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        
        //hides the keyboard when anywhere else on the screen besides textboxes is tapped
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    
    
    // action when the button is pressed - calculate the closest path and show it on the map
    @IBAction func getPath(_ sender: Any) {
        
        // resetting the markers and the labels
        lblRoute.text = ""
        
        // reset all the counters, flags and arrays
        routeCount = 0
        tempCount = 0
        tempCount2 = 0
        flattenedPositionCount = 0
        
        nextRoutesToBeTested.removeAll()
        tempRoute.removeAll()
        
        destinationExists = false
        routeExists = false
        

        // check if any of the boxes are not filled in
        let alert = UIAlertController(title: "Field empty", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        guard let originIATA = txtOrigin.text?.trimmed, !originIATA.isEmptyTrimmed else{
            alert.message = "Please enter IATA of the origin"
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        guard let destinationIATA = txtDestination.text?.trimmed, !destinationIATA.isEmptyTrimmed else{
            alert.message = "Please enter IATA of the destination"
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        // checks for the validity of the inputs
        if(validateInputs(originIATA, destinationIATA)){
        
            // add the origin IATA to the root of test list 
            nextRoutesToBeTested.append([[originIATA]])
    
            // check all existing routes/paths
             checkPath(originIATA, destinationIATA)
            
            // clear the array once the routes have been found
            nextRoutesToBeTested.removeAll()
            
            // add the markers to the map
            addMarkers()
            
            
        }
        
        
        // IATA = 3
        // latitude = 4
        // longitude = 5
        
        
    }
    
    
    

    // goes through all the list of routes and finds the first one found (Breadth first search approach instead of depth first)
    
    func checkPath(_ originIATA : String, _ destinationIATA : String)  {
        
        // temporary origin to be used for each iteration
        var tempOriginIATA = originIATA
    
        // this will be iterated for each origin along the possible routes
        while true{
        
            for i in 0..<routesData.count{
                
                // first, check if the destination actually exists on the route list (as some do not, e.g. DNV), before going through the loop
                if((routesData[i][2].caseInsensitiveCompare(destinationIATA.trimmed)) == ComparisonResult.orderedSame ){
                    
                    destinationExists = true
                    
                }
                
                //  check from the origin IATA
                if(
                    (routesData[i][1].caseInsensitiveCompare(tempOriginIATA.trimmed)) == ComparisonResult.orderedSame
                ){
                    
                    
                    routeExists = true
                    
                    
                    // destination found in the current route
                    if( (routesData[i][2].caseInsensitiveCompare(destinationIATA.trimmed)) == ComparisonResult.orderedSame ){
                     
                        tempRoute.append(tempOriginIATA.trimmed)
                        tempRoute.append(destinationIATA.trimmed)
                        
                        // trace backwards
                        var i = routeCount
                    
                        while(i > 0){
                        
                            
                            // flatten the 2nd level array for the parent IATAs (previous row),
                            // as the 2nd level array position of the current row correpsponds the
                            //  position of the flattened 2nd level array of the previous row,
                            // e.g. [0][0]["A"]
                            //      [1][0]["B","C","D"]
                            //      [2][0]["E","F"], [2][1]["G","H"], [2][2]["I"]
                            //      [3][0]["J"], [3][1]["K"], [3][2]["L,M"], [3][3]["O","P"], [3][4]["Q"]
                            // from the example above, the parent of 'P' (which is [3][3][1]) would be
                            // 'H' (which is [2][1][1], but if flattened, it would be [2][3]).
                            // it's the 4th (or [3]) element (flattned) from the previous row,
                            // and hence 4th array (or [3]) with [String] in the current row (4th, 2nd level array)
                            
                            let previousArrayFlattned = Array(nextRoutesToBeTested[i-1].joined())
                            
                            // insert to the route list (going backwards, so append to the beginning)
                            tempRoute.insert(previousArrayFlattned[tempCount2], at: 0)
                            
                            // parent IATA found at this point
                            
                            // need to get tempCount2 (2nd level index) for the next iteration of the traceback
                            var tempArrayCount = 0
                            var tempElementCount = tempCount2 + 1 // adding 1 b/c it's a count instead of an index
                            
                            // getting the flatenned position of the previous array using the 2nd level count of the current position
                            while(tempElementCount > 0){
                                tempElementCount -= nextRoutesToBeTested[i-1][tempArrayCount].count
                                tempArrayCount += 1
                                // move on to the next array
                            }
                            
                            tempCount2 = tempArrayCount-1 // subtracting 1 b/c it's an index
                            
                            
                            i -= 1
                        }
                        
                        routeCount += 1
                        
                        return
                    }
                        
                    // if destination not found in the current route, add it to the next level in the array so that is looked up after the lookup in the current level is complete
                    else{
                    
                        // initializing the array if empty
                        // if it's a new level of route
                        if( !nextRoutesToBeTested.indices.contains(routeCount+1) ){
                            
                           nextRoutesToBeTested.append([[routesData[i][2]]])
                            
                            
                        }
                        
                        // if it's from a new parent IATA (need to be created in a new array)
                        else if(!(nextRoutesToBeTested[routeCount+1].indices.contains(flattenedPositionCount))){
                            nextRoutesToBeTested[routeCount+1].append([routesData[i][2]])
                        }
                        
                        // else, add it to the existing last array
                        else{
                           
                            nextRoutesToBeTested[routeCount+1][flattenedPositionCount].append(routesData[i][2])
                        }
                        
                        
                    }
                    
                    
                }
              
        
            }
            
            // if no routes exist from the origin,
            // or destion does not exist from the route list,
            // or if destination not found after 7 levels
            // (assupmtion: no possible routes go over 7 stops, realistically, and to prevent infinite loops)
            if(!routeExists) || (!destinationExists) || (routeCount >= 7) {
               
                let alert = UIAlertController(title: "Route not found", message: "", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                tempRoute.removeAll()
                
                return
            }
            
            
            tempCount += 1
            flattenedPositionCount += 1
            
            // end of a 3rd level array - increment the 2nd level counter and rest the 3rd level counter for the next iteration
            if(tempCount >= nextRoutesToBeTested[routeCount][tempCount2].count){
                tempCount2 += 1
                tempCount = 0
            }
            
            // end of a 2nd level array - increment routeCount (basically the 1st level counter), and reset the 2nd / 3rd / flattened position counts
            if(tempCount2 >= nextRoutesToBeTested[routeCount].count){
                
                
                flattenedPositionCount = 0
                tempCount = 0
                tempCount2 = 0
                routeCount += 1

            }
            
            
            // if the next level of routes exist, then set the next origin for the next iteration
            if(nextRoutesToBeTested.indices.contains(routeCount)){
                tempOriginIATA = nextRoutesToBeTested[routeCount][tempCount2][tempCount]
            }
            
            else{
                return
                }
            
        
        }
        
        
        
    }
    
    
    // validating the inputs
    func validateInputs(_ originIATA: String, _ destinationIATA: String) -> Bool {
        
        let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.alert)
       
            var txtOriginIsValid : Bool = false
            var txtDestinationIsValid : Bool = false
        
            var i = 0
        
        
            // if origin and destination are the same
            // catching it before going through all the list of IATAs so that it doesnt have to go through the list if both entries are identical
            if((txtOrigin.text!.trimmed.caseInsensitiveCompare(txtDestination.text!.trimmed)) == ComparisonResult.orderedSame){
                
                alert.title = "Invalid Entries"
                alert.message = "Origin and Destination cannot be the same"
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            
                return false
            
            }
        
        
            // going through IATAs
            while((!txtOriginIsValid || !txtDestinationIsValid) &&  i < airportsData.count){
                
                // if the IATA code for the origin is found
                if((airportsData[i][3].caseInsensitiveCompare(txtOrigin.text!.trimmed)) == ComparisonResult.orderedSame
                    && !txtOriginIsValid){
                    
                    txtOriginIsValid = true
    
                }
                
                // if the IATA code for the origin is found
                if((airportsData[i][3].caseInsensitiveCompare(txtDestination.text!.trimmed)) == ComparisonResult.orderedSame
                    && !txtDestinationIsValid){
                    
                    txtDestinationIsValid = true
                }
                
                i += 1
              }
        
            // invalid origin and/or destination IATA
            if(!txtOriginIsValid || !txtDestinationIsValid){
                
                alert.title = "Invalid IATA"
                
                // origin invalid
                if(!txtOriginIsValid){
                    alert.message = "Invalid origin IATA"
                }
                    
                    // destination invalid
                else{
                    alert.message = "Invalid destination IATA"
                }
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                return false
            }
                // both inputs valid
            else{
                // only hide keyboard when the entries are valid
                dismissKeyboard()
                
                return true
            }
        
    }
    
    // returns the basic info about the airport (used for mapView)
    func getAirportDetails(_ IATA: String) -> [String]{
        
        var returnString = [String]()
        
        for i in 0..<airportsData.count{
            
            if((airportsData[i][3].caseInsensitiveCompare(IATA.trimmed)) == ComparisonResult.orderedSame){
                returnString = airportsData[i]
                
            }
        }
        
        return returnString
        
        
    }
    
    
    

    // adds all markers for all of the airports to be visited, once the route is determined
    func addMarkers(){
        
        mapView.clear()
        
        var bounds = GMSCoordinateBounds()
        let path = GMSMutablePath()
        
        // for each of the destinations on the route
        for i in 0..<tempRoute.count{
    
            // temporary airport entry / latitude / longtitude for each point to be visited
            var tempAirportEntry = getAirportDetails(tempRoute[i])
            let tempLatitude = Double(tempAirportEntry[4])!
            let tempLongitude = Double(tempAirportEntry[5])!
            
            let camera = GMSCameraPosition.camera(withLatitude: tempLatitude, longitude: tempLongitude, zoom: 5.0)
            mapView.camera = camera
        
            // create a marker on the map for each of the stops to be visited,
            // containing the info on the airport
            let marker = GMSMarker()
            marker.position = camera.target
            marker.title = tempAirportEntry[0]
            marker.snippet = tempAirportEntry[1] + ", " + tempAirportEntry[2]
            marker.map = mapView
            
            // adding bounds to be fitted on the map
            bounds = bounds.includingCoordinate(marker.position)
            
            // coordinates for adding lines on the map for each of the stops
            let coord = CLLocationCoordinate2DMake(tempLatitude, tempLongitude)
            path.add(coord)
            
            // adding airports to the label, listing all the stops
            if(i > 0){
                lblRoute.text?.append(" -> " + tempAirportEntry[3])
            }
            else{
                lblRoute.text?.append(tempAirportEntry[3])
            }
            
        }
        
        // fitting the bounds on the map
        let cameraUpdate = GMSCameraUpdate.fit(bounds, withPadding: 100)
        mapView.animate(with: cameraUpdate)
    
        // addling lines on the map for each of the stops
        let line = GMSPolyline(path: path)
        line.strokeColor = UIColor.blue
        line.strokeWidth = 3.0
        line.map = self.mapView
        
        
        
    
    }
    
    //hiding the keyboard back when the textboxes are not selected anymore
    @objc func keyboardWillHide(_ notification: Notification) {
  
        if let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
          
            self.view.frame.origin.y = 0
            
        }
    }

    
    
}




    
    


