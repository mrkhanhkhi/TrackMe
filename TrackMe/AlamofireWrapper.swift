//
//  AlamofireWrapper.swift
//  TrackMe
//
//  Created by KhanhND on 10/10/17.
//  Copyright © 2017 KhanhND. All rights reserved.
//

import Alamofire
import SwiftyJSON
import ReachabilitySwift

class AlamofireWrapper: NSObject {
    
    // Instance object
    static let sharedInstance = AlamofireWrapper()
    var baseURL: String!
    var sessionManager: SessionManager!
    var reachability: Reachability!
    var windowVisible = false
    
    fileprivate override init() {
        super.init()
        self.baseURL = kBaseURL
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = kTimeoutIntervalForRequest
        sessionManager = Alamofire.SessionManager(configuration: configuration)
        /// setup Reachability
        self.reachability = Reachability()!
        do {
            try reachability.startNotifier()
        } catch {
            //print("Unable to start notifier")
        }
    }
    
    func POST(_ urlString: String, parameters: [String : Any]?, completionHandler: @escaping CompletionHandler) -> () {
        
        let postURL = "\(baseURL!)\(urlString)"
        let aParameters = [String: Any]()
        
        sessionManager.request(postURL, method: .post, parameters: aParameters, encoding: URLEncoding.default, headers: nil).validate().responseJSON { (response) in
            switch response.result {
            case .failure(let error as NSError):
                if error.code == NSURLErrorNetworkConnectionLost || error.code == NSURLErrorNotConnectedToInternet {
                    // Slow connection | connection has expired | No Connection
                } else {
                    completionHandler(false, 0, error)
                }
                break
                
            case .success:
                if let value = response.result.value {
                    completionHandler(true, 200, value)
                } else {
                    
                    completionHandler(false, 0, response.result.error!)
                }
                break
                
            default:
                break
            }
        }
    }
}

