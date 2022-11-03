//
//  DailyForecastCell.swift
//  Simple-Forecast
//
//  Created by Alehandro on 17.06.22.
//

import UIKit

class DailyForecastCell: UITableViewCell {
    static let identifier = "DailyForecastCell"
    
    private var dayLabel = UILabel()
    private var temperatureLabel = UILabel()
    private var weatherImage = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .systemGray4
        
        dayLabel.text = "day"
        dayLabel.textAlignment = .center
        dayLabel.frame = CGRect(x: 0,
                                  y: 0,
                                  width: contentView.bounds.width / 3,
                                  height: contentView.bounds.height)
        contentView.addSubview(dayLabel)
        
        temperatureLabel.text = "min --℃, max --℃"
        temperatureLabel.textAlignment = .center
        temperatureLabel.frame = CGRect(x: contentView.bounds.midX - contentView.bounds.width / 5,
                                        y: contentView.bounds.midY - contentView.bounds.height / 2,
                                        width: contentView.frame.width / 2,
                                        height: contentView.frame.height)
        contentView.addSubview(temperatureLabel)
        
        weatherImage.image = UIImage(named: "02d")
        weatherImage.contentMode = .scaleToFill
        weatherImage.frame = CGRect(x: contentView.bounds.maxX - contentView.bounds.width / 6,
                                    y: contentView.bounds.midY - contentView.bounds.height / 1.3,
                                    width: contentView.frame.width / 5,
                                    height: contentView.frame.height * 1.5)
        contentView.addSubview(weatherImage)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(day: String, tempMin: Int, tempMax: Int, image: String) {
        dayLabel.text = "\(day)"
        temperatureLabel.text = "min \(String(tempMin))℃, max \(String(tempMax))℃"
        weatherImage.image = UIImage(named: image)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dayLabel.text = nil
        temperatureLabel.text = nil
        weatherImage.image = nil
    }
}
