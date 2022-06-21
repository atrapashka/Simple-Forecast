
import UIKit
import AVFoundation
import CoreLocation
import MapKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    private var collectionViewHourly: UICollectionView!
    private var tableViewDaily: UITableView!
    private var mainForecastView = UIView()
    private var hourlyForecastView = UIView()
    private var futureForecastView = UIView()
    private var backgroundView = UIImageView()
    private var searchField = UITextField()
    private var placeLabel = UILabel()
    private var temperatureLabel = UILabel()
    private var infoMainLabel = UILabel()
    private var infoHourlyLabel = UILabel()
    private var infoHourlyLabelBottom = UILabel()
    private var infoDailyLabel = UILabel()
    private var iconView = UIImageView()
    private var weatherImage = UIImageView()
    private var numbersOfHours = Int()
    private var hoursArray: [Int] = []
    private var daysArray: [Int] = []
    private var iconArrayDaily: [String] = []
    private var tempArrayMin: [Double] = []
    private var tempArrayMax: [Double] = []
    private var iconArrayHourly: [String] = []
    private var tempArrayHourly: [Double] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        setupUI()
        settingsUI(forecastView: mainForecastView)
        settingsUI(forecastView: hourlyForecastView)
        settingsUI(forecastView: futureForecastView)
        
        setupCollectionView()
        setupTableView()
        setupUIMainForecast()
        setupUIHourlyForecast()
        setupUIDailyForecast()
        
        mainForecastView.backgroundColor = .clear
        mainForecastView.alpha = 1
        
        let urlHourlyString = "https://api.openweathermap.org/data/2.5/onecall?lat=41.716667&lon=44.883333&exclude=minutely,alerts&appid=b7b89053dc118879472b67fc8488043e&units=metric"
        
        guard let urlHourly = URL(string: urlHourlyString) else {
            return
        }
        let requestHourly = URLRequest(url: urlHourly)

        let taskHourly = URLSession.shared.dataTask(with: requestHourly) { data, response, error in
            if let data = data {
                guard let hourlyWeatherResponse = try? JSONDecoder().decode(HourlyWeatherResponse.self,
                                                                            from: data) else {
                    return
                }
                DispatchQueue.main.async { [self] in
                    updateUIForecast(response: hourlyWeatherResponse)
                }
            }
            let httpResponse = response as! HTTPURLResponse
            
            if let error = error {
                print(error.localizedDescription)
            }
        }
        taskHourly.resume()
    }
    
    //MARK: - Private Functions
    //MARK: -
    
    private func updateUIForecast(response: HourlyWeatherResponse) {
        placeLabel.text = response.timezone
        let temp = response.current.temp
        let tempFeelsLike = response.current.feels_like
        let visibility = response.current.visibility
        let windSpeed = response.current.wind_speed
        let icon = response.current.weather[0].icon
        let description = response.current.weather[0].description
        temperatureLabel.text = "\(String(Int(temp)))℃"
        infoMainLabel.text = "Feels like - \(String(Int(tempFeelsLike)))℃, \(description)"
        infoHourlyLabel.text = "Visibility - \(visibility) m"
        infoHourlyLabelBottom.text = "Wind speed - \(windSpeed) m/s"
        iconView.image = UIImage(named: "\(icon)")
        
        let date = Date()
        let dateComponents = Calendar.current.dateComponents([.hour, .day], from: date)
        let hour = dateComponents.hour
        let day = dateComponents.day
        print(day!)
        
        switch icon {
        case "01d", "02d":
            backgroundView.image = UIImage(named: "sunny")
        case "03d", "03n", "04d", "04n":
            backgroundView.image = UIImage(named: "cloud")
        case "09d", "09n", "10d", "10n":
            backgroundView.image = UIImage(named: "rain")
        case "11d", "11n":
            backgroundView.image = UIImage(named: "lightning")
        case "13d", "13n":
            backgroundView.image = UIImage(named: "snow")
        case "50d", "50n":
            backgroundView.image = UIImage(named: "fog")
        case "01n", "02n":
            backgroundView.image = UIImage(named: "night")
        default:
            backgroundView.backgroundColor = .black
        }
        
        for i in day!...(day! + 6) {
            daysArray.append(i)
        }
        
        for i in 0...daysArray.count {
            tempArrayMin.append(response.daily[i].temp.min)
            tempArrayMax.append(response.daily[i].temp.max)
            iconArrayDaily.append(response.daily[i].weather[0].icon)
        }
        
        for i in hour!..<24 {
            hoursArray.append(i)
        }
        
        for i in 0..<24 {
            hoursArray.append(i)
            iconArrayHourly.append(response.hourly[i].weather[0].icon)
            tempArrayHourly.append(response.hourly[i].temp)
        }
        iconArrayHourly.append(response.hourly[24].weather[0].icon)
        tempArrayHourly.append(response.hourly[24].temp)
        
        for i in 0...(48-hoursArray.count) {
            hoursArray.append(i)
        }
        collectionViewHourly.reloadData()
        tableViewDaily.reloadData()
    }
    
    private func setupUI() {
        let mainWidth: CGFloat = view.bounds.width - 50
        let mainHeight: CGFloat = view.bounds.height / 4
        
        backgroundView.frame = view.bounds
        backgroundView.alpha = 0.5
        view.addSubview(backgroundView)
        
        mainForecastView.frame = CGRect(x: view.bounds.midX - mainWidth / 2,
                                        y: view.bounds.midY - view.bounds.height / 3,
                                        width: mainWidth,
                                        height: mainHeight)
        view.addSubview(mainForecastView)
        
        hourlyForecastView.frame = mainForecastView.frame.offsetBy(dx: 0, dy: mainHeight + 20)
        view.addSubview(hourlyForecastView)
        
        futureForecastView.frame = hourlyForecastView.frame.offsetBy(dx: 0, dy: mainHeight + 20)
        view.addSubview(futureForecastView)
        
        searchField.frame = mainForecastView.frame.offsetBy(dx: 0, dy: -mainHeight / 3)
        searchField.frame.size = CGSize(width: mainWidth, height: mainHeight / 4)
        searchField.layer.cornerRadius = 20
        searchField.text = "Search your place..."
        searchField.alpha = 0.7
        searchField.delegate = self
        searchField.textAlignment = .center
        searchField.clearsOnBeginEditing = true
        searchField.backgroundColor = .white
        view.addSubview(searchField)
    }
    
    private func setupCollectionView() {
        let layoutFlow = UICollectionViewFlowLayout()
        layoutFlow.scrollDirection = .horizontal
        layoutFlow.itemSize = CGSize(width: hourlyForecastView.bounds.width / 3 - 7,
                                     height: hourlyForecastView.bounds.width / 3 - 7)
        let collectionViewWidth: CGFloat = hourlyForecastView.bounds.width / 1.05
        let collectionViewHeight: CGFloat = hourlyForecastView.bounds.height / 1.05
        let collectionViewFrame = CGRect(x: hourlyForecastView.bounds.midX - collectionViewWidth / 2,
                                         y: hourlyForecastView.bounds.midY - collectionViewHeight / 3,
                                         width: collectionViewWidth,
                                         height: collectionViewHeight / 1.5)
        collectionViewHourly = UICollectionView(frame: collectionViewFrame,
                                                collectionViewLayout: layoutFlow)
        collectionViewHourly.register(HourlyForecastCell.self,
                                      forCellWithReuseIdentifier: HourlyForecastCell.identifier)
        collectionViewHourly.dataSource = self
        collectionViewHourly.delegate = self
        collectionViewHourly.showsHorizontalScrollIndicator = false
        
        hourlyForecastView.addSubview(collectionViewHourly)
    }
    
    private func setupTableView() {
        let tableViewDailyWidth: CGFloat = futureForecastView.bounds.width / 1.03
        let tableViewDailyHeight: CGFloat = futureForecastView.bounds.height / 1.05
        let tableViewDailyFrame = CGRect(x: futureForecastView.bounds.midX - tableViewDailyWidth / 2,
                                         y: futureForecastView.bounds.midY - tableViewDailyHeight / 3,
                                         width: tableViewDailyWidth,
                                         height: tableViewDailyHeight / 1.2)
        tableViewDaily = UITableView(frame: tableViewDailyFrame)
        tableViewDaily.layer.cornerRadius = 25
        
        tableViewDaily.register(DailyForecastCell.self,
                                forCellReuseIdentifier: DailyForecastCell.identifier)
        tableViewDaily.dataSource = self
        tableViewDaily.showsVerticalScrollIndicator = false
        
        futureForecastView.addSubview(tableViewDaily)
    }
    
    private func settingsUI(forecastView: UIView) {
        forecastView.backgroundColor = .white
        forecastView.alpha = 0.8
        forecastView.layer.cornerRadius = 30
    }
    
    private func setupUIMainForecast() {
        let labelWidth: CGFloat = mainForecastView.bounds.width
        let labelHeight: CGFloat = mainForecastView.bounds.height / 4
        
        placeLabel.frame = CGRect(x: mainForecastView.bounds.midX - labelWidth / 2,
                                  y: mainForecastView.bounds.minY + labelHeight / 10,
                                  width: labelWidth,
                                  height: labelHeight)
        placeLabel.text = "..............."
        placeLabel.font = UIFont.systemFont(ofSize: 35, weight: .light)
        placeLabel.textAlignment = .center
        placeLabel.textColor = .white
        mainForecastView.addSubview(placeLabel)
        
        temperatureLabel.frame = placeLabel.frame.offsetBy(dx: 0, dy: labelHeight + 15)
        temperatureLabel.text = "--℃"
        temperatureLabel.font = UIFont.systemFont(ofSize: 40, weight: .light)
        temperatureLabel.textAlignment = .center
        temperatureLabel.textColor = .white
        mainForecastView.addSubview(temperatureLabel)
        
        infoMainLabel.frame = temperatureLabel.frame.offsetBy(dx: 0, dy: labelHeight + 15)
        infoMainLabel.text = "Feels like - --℃"
        infoMainLabel.font = UIFont.systemFont(ofSize: 20, weight: .light)
        infoMainLabel.textAlignment = .center
        infoMainLabel.textColor = .white
        mainForecastView.addSubview(infoMainLabel)
        
        iconView.frame = placeLabel.frame.offsetBy(dx: labelWidth / 1.65, dy: labelHeight + 15)
        iconView.frame.size = CGSize(width: labelWidth / 6, height: labelHeight)
        iconView.contentMode = .scaleAspectFit
        iconView.image = UIImage(named: "")
        mainForecastView.addSubview(iconView)
    }
    
    private func setupUIHourlyForecast() {
        let labelWidth: CGFloat = hourlyForecastView.bounds.width / 1.2
        let labelHeight: CGFloat = hourlyForecastView.bounds.height / 6
        
        infoHourlyLabel.frame = CGRect(x: hourlyForecastView.bounds.midX - labelWidth / 2,
                                       y: hourlyForecastView.bounds.minY + labelHeight / 10,
                                       width: labelWidth,
                                       height: labelHeight)
        infoHourlyLabel.text = "Visibility - ---- m"
        infoHourlyLabel.textAlignment = .left
        infoHourlyLabel.font = UIFont.systemFont(ofSize: 20, weight: .light)
        hourlyForecastView.addSubview(infoHourlyLabel)
        
        infoHourlyLabelBottom.frame = CGRect(x: hourlyForecastView.bounds.midX - labelWidth / 2,
                                             y: hourlyForecastView.bounds.maxY - labelHeight * 1.1,
                                             width: labelWidth,
                                             height: labelHeight)
        infoHourlyLabelBottom.text = "Wind speed - -- m/s"
        infoHourlyLabelBottom.textAlignment = .left
        infoHourlyLabelBottom.font = UIFont.systemFont(ofSize: 20, weight: .light)
        hourlyForecastView.addSubview(infoHourlyLabelBottom)
    }
    
    private func setupUIDailyForecast() {
        let labelWidth: CGFloat = futureForecastView.bounds.width / 1.2
        let labelHeight: CGFloat = futureForecastView.bounds.height / 6
        
        infoDailyLabel.frame = CGRect(x: futureForecastView.bounds.midX - labelWidth / 2,
                                      y: futureForecastView.bounds.midY - labelHeight * 3,
                                      width: labelWidth,
                                      height: labelHeight)
        infoDailyLabel.text = "Next 7 days"
        infoDailyLabel.textAlignment = .center
        infoDailyLabel.font = UIFont.systemFont(ofSize: 20, weight: . light)
        futureForecastView.addSubview(infoDailyLabel)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - Extensions
//MARK: -

extension ViewController: UICollectionViewDelegate & UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hoursArray.count - 24
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourlyForecastCell.identifier,
                                                      for: indexPath) as! HourlyForecastCell
        cell.configure(hours: String(hoursArray[indexPath.item]),
                       temperature: Int(tempArrayHourly[indexPath.item]),
                       image: iconArrayHourly[indexPath.item])
        
        if indexPath.item == 0 {
            cell.configure(hours: "Now",
                           temperature: Int(tempArrayHourly[indexPath.item]),
                           image: iconArrayHourly[indexPath.item])
        }
        
        return cell
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daysArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DailyForecastCell.identifier,
                                                 for: indexPath) as! DailyForecastCell
        cell.configure(day: String(daysArray[indexPath.item]),
                       tempMin: Int(tempArrayMin[indexPath.item]),
                       tempMax: Int(tempArrayMax[indexPath.item]),
                       image: iconArrayDaily[indexPath.item])
        
        if indexPath.item == 0 {
            cell.configure(day: "Today",
                           tempMin: 15,
                           tempMax: 34,
                           image: "02d")
        }
        
        return cell
    }
}

