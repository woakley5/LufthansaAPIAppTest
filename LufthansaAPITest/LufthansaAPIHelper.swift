//
//  LufthansaAPIHelper.swift
//  LufthansaAPITest
//
//  Created by Will Oakley on 9/13/18.
//  Copyright © 2018 Will Oakley. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class LufthansaAPIHelper {
    
    //These are where we will store all of the authentication information. Get these from your account at developer.lufthansa.com.
    static let clientSecret = "5ffY9Y7GnW"
    static let clientID = "4kaj48pwtppvwkhharsat2bt"
    
    //This variable will store the session's auth token that we will get from getAuthToken()
    static var authToken: String?
    
    //This function will request an auth token from the lufthansa servers
    static func getAuthToken(completion: @escaping () -> ()){
        
        //This is the information that will be sent to the server to authenticate our device
        let requestURL = "https://api.lufthansa.com/v1/oauth/token"
        let parameters = ["client_id": "\(clientID)", "client_secret": "\(clientSecret)", "grant_type": "client_credentials"]
        
        //This is the POST request made to the lufthansa servers to get the authToken for this session.
        Alamofire.request(requestURL, method: .post, parameters: parameters, encoding: URLEncoding(), headers: ["Content-Type": "application/x-www-form-urlencoded"]).responseJSON { response in
            
            //Converts response to JSON object and sets authToken variable to appropriate value
            let json = JSON(response.result.value!)
            self.authToken = json["access_token"].stringValue
            
            print("Auth token: " + self.authToken!)
            print("This key expires in " + json["expires_in"].stringValue + " seconds\n")
            
            //Runs completion closure
            completion()
        }
    }
    
    //This function will get the status for a flight. Input format "LHXXX"
    static func getFlightStatus(flightNum: String, completion: @escaping (Flight) -> ()){
        
        //Request URL and authentication parameters
        let requestURL = "https://api.lufthansa.com/v1/operations/flightstatus/\(flightNum)/2018-09-14"
        let parameters: HTTPHeaders = ["Authorization": "Bearer \(authToken!)", "Accept": "application/json"]
        
        print("PARAMETERS FOR REQUEST:")
        print(parameters)
        print("\n")
        
        Alamofire.request(requestURL, headers: parameters).responseJSON { response in
            //Makes sure that response is valid
            guard response.result.isSuccess else {
                print(response.result.error.debugDescription)
                return
            }
            //Creates JSON object
            let json = JSON(response.result.value)
            print(json)
            //Create new flight model and populate data
            let flight = Flight()
            flight.flightNumber = flightNum
            flight.status = json["FlightStatusResource"]["Flights"]["Flight"]["FlightStatus"]["Definition"].stringValue
            
            completion(flight)
        }
    }
}
