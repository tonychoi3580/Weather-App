//
//  WeatherTableViewController.swift
//  CityWeather
//
//  Created by Tony Choi on 3/4/20.
//  Copyright © 2020 Tony Choi. All rights reserved.
//
import Foundation
import SystemConfiguration
import UIKit


class closeupView: UIViewController{
    @IBOutlet weak var cityimage: UIImageView!
    @IBOutlet weak var statusimage: UIImageView!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var citylabel: UILabel!
    
    var city: String = "Honolulu"
    var status: String = "Sunny"
    var temp: String = "26.9"
    
    
    override func viewDidLoad() {
        citylabel.text = city
        temperature.text = temp
        cityimage.image = UIImage(named: city)
        statusimage.image = UIImage(named: status)
    }
}
class WeatherTableViewCell: UITableViewCell {
    @IBOutlet weak var statusimage: UIImageView!
    @IBOutlet weak var cityimage: UIImageView!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var City: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}


class WeatherTableViewController: UITableViewController {
   
    
    //variables for cities
    var cities = ["Honolulu","Irvine","Seoul","Durham","New York","Tokyo","Hsinchu","Singapore"]
    var inputs = ["honolulu":"Honolulu","Irvine":"Irvine","seoul":"Seoul","durham":"Durham","Tokyo":"Tokyo","hsinchu":"Hsinchu","singapore":"Singapore","new%20york":"New York"]
    var temperatures = ["Honolulu":0.0,"Irvine":0.0,"Seoul":0.0,"Durham":0.0,"New York":0.0,"Tokyo":0.0,"Hsinchu":0.0,"Singapore":0.0]
    var citystatuses =
        ["Honolulu":"Sunny","Irvine":"Sunny","Seoul":"Sunny","Durham":"Sunny","New York":"Sunny","Tokyo":"Sunny","Hsinchu":"Sunny","Singapore":"Sunny"]
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }

        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }

    func showAlert() {
        if !isInternetAvailable() {
            let alert = UIAlertController(title: "Warning", message: "The Internet is not available", preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.rowHeight = 130
        showAlert()
        
        
        
        loadData()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source
    @objc func loadData() {
            inputs.keys.forEach {
            let headers = [
                "x-rapidapi-host": "community-open-weather-map.p.rapidapi.com",
                "x-rapidapi-key": "fff46e995dmsh5b3c5fbb9bfcc6ep1f71fbjsn022cc5d6f5a0"
            ]
            let city = inputs[$0]
            let request = NSMutableURLRequest(url: NSURL(string: "https://community-open-weather-map.p.rapidapi.com/weather?q="+$0)! as URL,
                cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                
                if (error != nil) {
                } else {
                    if let data = data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options:.allowFragments) as! [String:AnyObject]
                            let main = json["main"] as? [String:AnyObject]
                            let temp = main!["temp"]  as? Double
                            let temperature = Double(temp!)
                           
                            self.temperatures[city!] = Double(round(10*(temperature-273.0))/10)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                            
                          
                        } catch {
                        }
                    }
                }
            })

            dataTask.resume()
            
        }
        
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // your code here
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
           // #warning Incomplete implementation, return the number of sections
           return 1
           
       }
    
   

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return cities.count
    }

    /*UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCell", for: indexPath) as! CurrencyCell
    let currency = currenciesBack[indexPath.row]
    cell.flagLabel.text = currencies[currency]
    cell.currencyLabel.text = currency
    cell.countryLabel.text = currenciesCountries[indexPath.row]
    cell.symbolLabel.text = currenciesSymbol[indexPath.row]
    cell.valueLabel.text = (currency != "BTC") ? String(format: "%.2f", (currencies_data[currency] ?? 0.0)*currentValue) : String(format: "%.8f", (currencies_data[currency] ?? 0.0)*currentValue)
    
    return cell
    */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherTableViewCell", for: indexPath) as! WeatherTableViewCell
        
        let city = cities[indexPath.row]
        cell.City.text = city
      
       // let imageName = Array(inputs.keys)[indexPath.row]
        let temper = temperatures[city]
        let temper2 = String(format:"%.1f",temper!)
        //let startIndex = temper2.index(temper2.startIndex, offsetBy: 4)
        
        cell.temp.text = temper2
       
        
        cell.cityimage.image = UIImage(named:city)
        if(temper!>24.0){
            
            cell.statusimage.image = UIImage(named:"Sunny")
            
            citystatuses[city] = "Sunny"
        }
        if(temper!>10){
            cell.statusimage.image = UIImage(named:"Chilly")
      
            citystatuses[city] = "Chilly"
        }
        else{
            cell.statusimage.image = UIImage(named:"Cold")

            citystatuses[city] = "Cold"
        }
        

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            print("TOny")
            let city = cities[indexPath.row]

            if segue.identifier == "closeupSegue" {
                print("L")
                let closeup = segue.destination as! closeupView
                closeup.city = city
                closeup.status = citystatuses[city]!
                let temperature = temperatures[city]!
                print(temperature)
               // let celciusTemp = (Double(round(10*(temperature-273.0))/10))
                closeup.temp = String(format:"%.1f",temperature)

            }
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

  
    */
    
}
