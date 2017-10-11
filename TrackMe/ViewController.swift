//
//  ViewController.swift
//  TrackMe
//
//  Created by KhanhND on 10/10/17.
//  Copyright © 2017 KhanhND. All rights reserved.
//

import UIKit
import SwiftyJSON
import ReachabilitySwift
import MapKit
import UserNotifications
import CoreData


class ViewController: UIViewController {
    
    //MARK: - Constants
    fileprivate var radius = 500.0
    fileprivate let annotationTitle = "Annotation"
    
    //MARK: - IBOutlets
    @IBOutlet weak var userNameTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var mobileNumTextfield: UITextField!
    @IBOutlet weak var latitudeTextfield: UITextField!
    @IBOutlet weak var longitudeTextfield: UITextField!
    @IBOutlet weak var radiusTextfield: UITextField!
    
    @IBOutlet weak var savedLatitudeTextfield: UITextField!
    @IBOutlet weak var savedLongitudeTextfield: UITextField!
    @IBOutlet weak var savedRadiusTextfield: UITextField!
    
    @IBOutlet weak var cellularLocationLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - Custome variables
    fileprivate var reachability = Reachability()!
    fileprivate var param = [String:Any]()
    fileprivate var postURL = ""
    fileprivate var latitude = ""
    fileprivate var longitude = ""
    fileprivate var coordinate = CLLocationCoordinate2D()
    fileprivate let locationManager = CLLocationManager()
    var geolocations: [NSManagedObject] = []
    
    //MARK: - Life cycle view controller
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .denied:
            showAlertView(kAlert, message: kLocationAlert)
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
        default:
            return
        }
    }
    
    //MARK: - IBActions
    @IBAction func doPostRequest(_ sender: Any) {
        if validation() == true {
            sendRequest()
        } else {
            showAlertView(kAlert, message: kFillAllFields)
        }
    }
    
    @IBAction func doSaveData(_ sender: Any) {
        if dataValidation() == true {
            saveData(latitude: coordinate.latitude,
                     longitude: coordinate.longitude,
                     radius: radius,
                     location: locationLabel.text!)
        } else {
            showAlertView(kAlert, message: kNoData)
        }
    }
    
    @IBAction func doLoadData(_ sender: Any) {
        loadData()
    }
    
    //MARK: - Custom functions
    private func initComponents() {
        do {
            try reachability.startNotifier()
        } catch {
            print(kUnableStartNotifier)
        }
        locationManager.delegate = self
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
    private func setupLocationData() {
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            let coordinate = CLLocationCoordinate2DMake(self.coordinate.latitude, self.coordinate.longitude)
            let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude,
                                                                         longitude: coordinate.longitude), radius: radius, identifier: annotationTitle)
            locationManager.startMonitoring(for: region)
            let myAnnotation = MKPointAnnotation()
            myAnnotation.coordinate = coordinate;
            myAnnotation.title = "\(annotationTitle)";
            DispatchQueue.main.async {
                self.mapView.addAnnotation(myAnnotation)
                let circle = MKCircle(center: coordinate, radius: self.radius)
                self.mapView.add(circle)
	            }
        }
        else {
            print(kTrackRegionError)
        }
    }
    
    private func saveData(latitude: Double, longitude: Double, radius: Double, location: String) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let entity =
            NSEntityDescription.entity(forEntityName: "Geolocations",
                                       in: managedContext)!
        
        let geolocation = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        geolocation.setValue(latitude, forKeyPath: "latitude")
        geolocation.setValue(longitude, forKey: "longitude")
        geolocation.setValue(radius, forKeyPath: "radius")
        geolocation.setValue(location, forKey: "location")
        do {
            try managedContext.save()
            geolocations.append(geolocation)
            showAlertView(kSuccess, message: kSaveSuccess)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    private func loadData() {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Geolocations")
        do {
            geolocations = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        guard let savedLatitude = geolocations.first?.value(forKey: "latitude"), let savedLongitude = geolocations.first?.value(forKey: "longitude"), let savedRadius = geolocations.first?.value(forKey: "radius") else {
            showAlertView(kNoData, message: kNoDataSaved)
            return
        }
        DispatchQueue.main.async {
            self.savedLatitudeTextfield.text = "\(savedLatitude)"
            self.savedLongitudeTextfield.text = "\(savedLongitude)"
            self.savedRadiusTextfield.text = "\(savedRadius)"
        }
    }
    
    private func validation() -> Bool {
        if userNameTextfield.text == "" || passwordTextfield.text == "" || mobileNumTextfield.text == "" {
            return false
        } else {
            return true
        }
    }
    
    private func dataValidation() -> Bool {
        if latitudeTextfield.text == "" || longitudeTextfield.text == "" || radiusTextfield.text == "" {
            return false
        } else {
            return true
        }
    }
    
    func triggerNotifications(region:CLRegion, body: String) {
        guard let location = locationLabel.text else { return }
        let trigger = UNLocationNotificationTrigger(region: region, repeats: true)
        let enterContent = UNMutableNotificationContent()
        enterContent.title = "Alert"
        enterContent.body = "Entered \(location)"
        enterContent.sound = UNNotificationSound.default()
        let enterRequest = UNNotificationRequest(identifier: "enterNotification", content: enterContent, trigger: trigger)
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(enterRequest) {(error) in
            if let error = error {
                print("Error: \(error)")
            }
        }
    }
    
    private func sendRequest() {
        switch reachability.currentReachabilityStatus {
        case .notReachable:
            showAlertView(kNoInternet, message: kConnectToInternet)
        case .reachableViaWiFi:
            postURL = API_LOGIN
            param["user"] = userNameTextfield.text
            param["password"] = passwordTextfield.text
        case .reachableViaWWAN:
            postURL = API_LOGIN_CELLULAR
            param["mobile"] = mobileNumTextfield.text
        }
        AlamofireWrapper.sharedInstance.POST(postURL, parameters: param) { status, statusCode, data in
            if statusCode == 200 {
                let json = JSON(data!)
                let geo = Geolocation(json: json)
                DispatchQueue.main.async {
                    guard let latitude = geo.latitude, let longitude = geo.longitude, let radius = geo.radius, let location = geo.location else { return }
                    self.coordinate.latitude = latitude
                    self.coordinate.longitude = longitude
                    self.locationLabel.text = location
                    self.latitudeTextfield.text = "\(latitude)"
                    self.longitudeTextfield.text = "\(longitude)"
                    self.radiusTextfield.text = radius
                    self.setupLocationData()
                }
            }
        }
    }
}

//MARK: - MapViewDelegate
extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.strokeColor = UIColor.red
        circleRenderer.lineWidth = 1.0
        return circleRenderer
    }
}

//MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        showAlertView(kAlert, message: "Enter \(region.identifier)")
        triggerNotifications(region: region, body: "Entered")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        showAlertView(kAlert, message: "Exit \(region.identifier)")
        triggerNotifications(region: region, body: "Exit")
        }
}
