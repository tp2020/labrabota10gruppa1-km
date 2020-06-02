//
//  ViewController.swift
//  Lab9Task2.2
//
//  Created by Alex on 12.05.2020.
//  Copyright © 2020 Alex. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController, WeatherGetterDelegate, MKMapViewDelegate, UITableViewDataSource, CLLocationManagerDelegate{
    
    // Array to keep all records
    var data = [NSManagedObject]()

    // Map to choose city
    @IBOutlet weak var map: MKMapView!
    
    // View to show table with records
    @IBOutlet weak var tableView: UIView!
    
    // Tap recognizer to choose city
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    // Fields with chosen cities
    @IBOutlet weak var cityFromField: UITextField!
    @IBOutlet weak var cityToField: UITextField!
    
    // Button to show table
    @IBOutlet weak var showAllTrips: UIButton!

    private let locationManager = LocationManager()
    var myInitLocation = CLLocationCoordinate2D(latitude: 32.7767, longitude: -96.7970)
    
    
        
   // MARK: - Table view stack

    // To show all trips between chosen towns
    @IBOutlet weak var table: UITableView!
    

    
    // Method to fill cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get cell from dequeue
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        
        // Get next record
        let record = data[indexPath.row];
        
        // Set number of lines
        cell.textLabel?.numberOfLines = 4
        
        // Write information
        cell.textLabel?.text = NSLocalizedString("From: ", comment: "from") + ((record.value(forKey: "stationFrom") as? String)!)
        cell.textLabel?.text = (cell.textLabel?.text)! + "\n" + NSLocalizedString("To: ", comment: "to") + ((record.value(forKey: "stationTo") as? String)!)
        cell.textLabel?.text = (cell.textLabel?.text)! + "\n" + NSLocalizedString("Cost: ", comment: "cost") + (String(record.value(forKey: "cost")! as! Float))
        cell.textLabel?.text = (cell.textLabel?.text)! + "\n" + NSLocalizedString("Places: ", comment: "places") + String((record.value(forKey: "places") as! Int))
        
        return cell
    }
    
    // Get number of columns
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1
    }
    
    // Get number of lines
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    // Back to map
    @IBAction func backButton(_ sender: Any) {
        tableView.isHidden = true
    }
    
    // MARK: - Choose path interface
    
    // Variable to know what town user choose
    var isFrom = true
    
    // Write chosen town to field
    func setTown(town: String){
        if isFrom
        {
            // Set city from
            cityFromField.text = town as String
            isFrom = false
        }
        else
        {
            // Set city to
            cityToField.text = town as String
            isFrom = true
            
            // Set weather in chosen city
            weather.getWeatherByCity(city: cityToField.text!)
            
            // Draw line between cities
            drawPath()
        }
    }
    
    // Action when user click on map
    @IBAction func tapped(_ sender: Any) {
        if (sender as AnyObject).state == .ended{
            let locationInView = (sender as AnyObject).location(in: map)
            
            // Get coordinates of point on map
            let tappedCoordinate = map.convert(locationInView, toCoordinateFrom: map)
            
            // Write city's name to field
            whatCity(location: CLLocation(latitude: tappedCoordinate.latitude, longitude: tappedCoordinate.longitude))
        }
    }
    
    // Recognize city by coordinates and write it to field
    func whatCity(location: CLLocation)
    {
        let locationManager = LocationManager()
        locationManager.getPlace(for: location) {placemark in
        guard let placemark = placemark else { return }
        
        var output = ""
        if let town = placemark.locality {
            output = output + "\(town)"
            }
        }
    }

    
    // MARK: - Stack to draw line on map
    
    // This method find coordinates of entered towns and draw line between them
    func drawPath(){
        // Coordinates of start town
        var coordFrom: CLLocationCoordinate2D = CLLocationCoordinate2D()
        // Coordinates of finish town
        var coordTo: CLLocationCoordinate2D = CLLocationCoordinate2D()
        
        self.locationManager.getLocation(forPlaceCalled: cityFromField.text!) { location in
            guard let location = location else { return }
            
            // Get coordinates of start town
            coordFrom.latitude = location.coordinate.latitude
            coordFrom.longitude = location.coordinate.longitude
            
            self.locationManager.getLocation(forPlaceCalled: self.cityToField.text!) { location1 in
                guard let location1 = location1 else { return }
                
                // Get coordinates of finish town
                coordTo.latitude = location1.coordinate.latitude
                coordTo.longitude = location1.coordinate.longitude
            
                // Draw line between two towns
                self.createPolyLine(location1:coordFrom, location2: coordTo)
            }
        }
    }
    
    // Last line. I save it there to delete, when draw new line
    private var aPolyLine: MKOverlay = MKPolyline()
    
    // Draw line between two coordinates
    func createPolyLine(location1: CLLocationCoordinate2D, location2: CLLocationCoordinate2D){
        // Delete last line
        map.removeOverlay(aPolyLine)
        
        // Make new line
        self.aPolyLine = MKPolyline(coordinates: [location1, location2], count: 2)
    
        // Add this line to map
        map.addOverlay(aPolyLine)
    }
    
    // Method with parameters for drawing line
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer{
        if(overlay is MKPolyline){
            let polylineRender = MKPolylineRenderer(overlay: overlay)
            
            // Line color
            polylineRender.strokeColor = UIColor.red
            
            // Line width
            polylineRender.lineWidth = 5
            
            return polylineRender
        }
        return MKPolylineRenderer(overlay: overlay)
    }
    
    // MARK: - Weather stack
    
    // Label to show city in weather
    @IBOutlet weak var cityLabel: UILabel!
    // Label to show weather in city
    @IBOutlet weak var weatherLabel: UILabel!
    // Label to show temperature in city
    @IBOutlet weak var tempLabel: UILabel!
    
    // Object for requests to weather server
    var weather: WeatherGetter!
    
    func didGetWeather(weather: Weather) {
        // This method is called asynchronously, which means it won't execute in the main queue.
        // ALl UI code needs to execute in the main queue, which is why we're wrapping the code
        // that updates all the labels in a dispatch_async() call.
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                self.cityLabel.text = weather.city
                self.weatherLabel.text = weather.weatherDescription
                self.tempLabel.text = String(Int(weather.tempCelsius))
            }
        }
      }
      
      func didNotGetWeather(error: NSError) {
        // This method is called asynchronously, which means it won't execute in the main queue.
        // ALl UI code needs to execute in the main queue, which is why we're wrapping the call
        // to showSimpleAlert(title:message:) in a dispatch_async() call.
        DispatchQueue.global(qos: .background).async {
        DispatchQueue.main.async {
            self.showSimpleAlert(title: "Can't get the weather",
            message: "The weather service isn't responding.")
        }
        print("didNotGetWeather error: \(error)")
      }
    }
    
    // Method to show error
    func showSimpleAlert(title: String, message: String) {
      let alert = UIAlertController(
        title: title,
        message: message,
        preferredStyle: .alert
      )
      let okAction = UIAlertAction(
        title: "OK",
        style:  .default,
        handler: nil
      )
      alert.addAction(okAction)
      present(
        alert,
        animated: true,
        completion: nil
      )
    }
}

