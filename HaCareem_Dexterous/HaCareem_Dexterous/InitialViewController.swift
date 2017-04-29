//
//  ViewController.swift
//  HaCareem_Dexterous
//
//  Created by Asher Ahsan on 29/04/2017.
//  Copyright © 2017 Asher Ahsan. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import SwiftyJSON
import GoogleMaps
import GooglePlaces
import MRCountryPicker

class InitialViewController: UIViewController, MRCountryPickerDelegate, UITextFieldDelegate, GMSAutocompleteViewControllerDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var categoryOption: UISegmentedControl!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var countryPicker: MRCountryPicker!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var countryCode: UITextField!
    @IBOutlet weak var pickupLocation: RoundTextField!
    @IBOutlet weak var dropoffLocation: RoundTextField!
    @IBOutlet weak var estimatedTimeArrival: UILabel!
    @IBOutlet weak var cancelButton: RoundedButton!
    @IBOutlet weak var pinTextField: RoundTextField!
    @IBOutlet weak var numberStack: UIStackView!
    @IBOutlet weak var segmentControl: RoundSegmentControl!
    @IBOutlet weak var checkImage: UIImageView!
    
    var location = CLLocationCoordinate2D()
    let locationManager = CLLocationManager()
    var customerNumber: String!
    var tempCountryCode: String!
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    let geoCoder = CLGeocoder()
    var pickupAddress = String()
    var productsArray = [Int:Product]()
    
    var productApi = "http://qa-interface.careem-engineering.com/v1/products"
    var estimateTimeApi = "http://qa-interface.careem-engineering.com/v1/estimates/time"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countryPicker.removeFromSuperview()
        countryPicker.setCountry("PK")
        countryPicker.countryPickerDelegate = self
        countryPicker.showPhoneNumbers = true
        countryCode.inputView = countryPicker
        self.tempCountryCode = "+92"
        
        self.dropoffLocation.delegate = self
        
        //mapView.isMyLocationEnabled = true
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        //
        checkImage.setRounded()
        let attr = NSDictionary(object: UIFont(name: "HelveticaNeue-Bold", size: 17.0)!, forKey: NSFontAttributeName as NSCopying)
        segmentControl.setTitleTextAttributes(attr as! [AnyHashable : Any], for: .normal)
        
        Alamofire.request(
            productApi,
            parameters: ["latitude": 24.8673 , "longitude": 67.0248],
            headers: ["Authorization": "crl54u6cj8f3a7hkc304359lhg"]
            )
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        let value = JSON(response.result.value!)
                        //print("ps: ", value)
                        let products = value["products"].arrayObject
                        for p in products! {
                            let product = Product(id: 1234, data: JSON(p))
                            self.productsArray[product.productId] = product
                            print("Pro1: ", product.productId)
                            print("Pro2: ", product.displayName)
                        }
                    }
                case .failure(_):
                    print("Error: ", response.error)
                }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func countryPhoneCodePicker(_ picker: MRCountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        print("country code: ", countryCode)
        self.countryCode.text = phoneCode
        self.tempCountryCode = phoneCode
    }
    
    @IBAction func tapPressed(_ sender: UITapGestureRecognizer) {
        print("done ")
        self.countryCode.text = self.tempCountryCode
        countryPicker.removeFromSuperview()
    }
    
    @IBAction func donePressed(_ sender: Any) {
        if let code = countryCode.text, let number = phoneNumber.text, (code.characters.count > 0 && number.characters.count > 0) {
            self.customerNumber = code + number
            var pin = String(arc4random())
            pin = String(pin.characters.prefix(4))
            
            let autoId = DataService.instance.userRef.childByAutoId()
            autoId.child("number").setValue(self.customerNumber)
            autoId.child("pin").setValue(pin)
        }
    }
    
    @IBAction func confirmBooking(_ sender: Any) {
        //Get nearby driver
        
    }
    
    @IBAction func categoryChanged(_ sender: UISegmentedControl) {
        switch categoryOption.selectedSegmentIndex
        {
        case 0:
            print("Go")
            //ETA for GO
            Alamofire.request(
                self.estimateTimeApi,
                parameters: ["start_latitude": 24.8673 , "start_longitude": 67.0248, "product_id": CATEGORY_GO],
                headers: ["Authorization": "crl54u6cj8f3a7hkc304359lhg"]
                )
                .responseJSON { response in
                    switch(response.result) {
                    case .success(_):
                        if response.result.value != nil {
                            let value = JSON(response.result.value!)
                            print("ETA: ", value)
                            self.estimatedTimeArrival.text = "4 mins"
                        }
                    case .failure(_):
                        print("Error: ", response.error)
                    }
                }
            break
        case 1:
            print("Go+")
            Alamofire.request(
                self.estimateTimeApi,
                parameters: ["start_latitude": 24.8673 , "start_longitude": 67.0248, "product_id": CATEGORY_GO_PLUS],
                headers: ["Authorization": "crl54u6cj8f3a7hkc304359lhg"]
                )
                .responseJSON { response in
                    switch(response.result) {
                    case .success(_):
                        if response.result.value != nil {
                            let value = JSON(response.result.value!)
                            print("ETA: ", value)
                            self.estimatedTimeArrival.text = "7 mins"
                        }
                    case .failure(_):
                        print("Error: ", response.error)
                    }
                }
        case 2:
            print("Business")
            Alamofire.request(
                self.estimateTimeApi,
                parameters: ["start_latitude": 24.8673 , "start_longitude": 67.0248, "product_id": CATEGORY_BUSINESS],
                headers: ["Authorization": "crl54u6cj8f3a7hkc304359lhg"]
                )
                .responseJSON { response in
                    switch(response.result) {
                    case .success(_):
                        if response.result.value != nil {
                            let value = JSON(response.result.value!)
                            print("ETA: ", value)
                            self.estimatedTimeArrival.text = "20 mins"
                        }
                    case .failure(_):
                        print("Error: ", response.error)
                    }
                }
        default:
            break;
        }
    }
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        dropoffLocation.text = place.formattedAddress
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("XYZ")
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationCoordinate = manager.location!.coordinate
        
        if location.latitude != locationCoordinate.latitude && location.longitude != locationCoordinate.longitude {
            location = manager.location!.coordinate
            //let loc = CLLocation(latitude: 24.8146922, longitude: 67.07959789999995)
            print("loc1: ", manager.location)
            /*
             geoCoder.reverseGeocodeLocation(manager.location!, completionHandler: {
             placemarks, error in
             print("loc2: ", manager.location)
             if error == nil && (placemarks?.count)! > 0 {
             var placeMark: CLPlacemark!
             placeMark = placemarks?[0]
             
             print("dic: ", placeMark.addressDictionary as Any)
             if let street = placeMark.addressDictionary!["Street"] as? String, let city = placeMark.addressDictionary!["City"] as? String, let country = placeMark.addressDictionary!["Country"] as? String{
             self.pickupAddress = street + ", " + city + ", " + country
             print("Address: ", self.pickupAddress)
             }
             }
             })*/
            
            let geocoder = GMSGeocoder()
            geocoder.reverseGeocodeCoordinate((manager.location?.coordinate)!) { response, error in
                if let address = response?.firstResult() {
                    let lines = address.lines as! [String]
                    
                    print("Lines: ", lines)
                    UIView.animate(withDuration: 0.25) {
                        self.view.layoutIfNeeded()
                    }
                }
            }
        }
    }
    
    
    
    @IBAction func verifyPressed(_ sender: UITapGestureRecognizer) {
        print("yes")
        UIView.animate(withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.numberStack.alpha = 0.0
            self.pinTextField.alpha = 1
            self.cancelButton.alpha = 1
        }, completion: nil)
    }
    
    @IBAction func cancelBtnPressed(_ sender: RoundedButton) {
        UIView.animate(withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.numberStack.alpha = 1
            self.pinTextField.alpha = 0
            self.cancelButton.alpha = 0
        }, completion: nil)
    }
    
    
    
}
