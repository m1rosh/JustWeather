//
//  ForecastTableViewCell.swift
//  JustWeather
//
//  Created by Сергей Мирошниченко on 23.03.2024.
//

import UIKit

final class ForecastTableViewCell: UITableViewCell {
    
    var weatherConditionImage: UIImageView = {
        let imageview = UIImageView()
        imageview.translatesAutoresizingMaskIntoConstraints = false
        
        return imageview
    }()

    var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()

    var MaxtemperatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()

    var MintempretureLbael: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let dataManager = DataManager()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with weather: OneForecast) {
        dateLabel.text = weather.date
        
        if weather.day.maxtemp_c > 0 {
            MaxtemperatureLabel.text = "+\(weather.day.maxtemp_c)"
        }
        else {
            MaxtemperatureLabel.text = String(weather.day.maxtemp_c)
        }
        
        if weather.day.mintemp_c > 0 {
            MintempretureLbael.text = "+\(weather.day.mintemp_c)"
        }
        else {
            MintempretureLbael.text = String(weather.day.mintemp_c)
        }
        
        if let url = URL(string: "https:\(weather.day.condition.icon)") {
            dataManager.downloadImage(from: url) { image in
                if let image = image {
                    DispatchQueue.main.async {
                        self.weatherConditionImage.image = image
                    }
                }
            }
        }
    }
    
    private func setup() {
        contentView.addSubview(weatherConditionImage)
        contentView.addSubview(dateLabel)
        contentView.addSubview(MaxtemperatureLabel)
        contentView.addSubview(MintempretureLbael)
        
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
        
        NSLayoutConstraint.activate([
            MintempretureLbael.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            MintempretureLbael.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            MaxtemperatureLabel.trailingAnchor.constraint(equalTo: MintempretureLbael.leadingAnchor, constant: -15),
            MaxtemperatureLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            weatherConditionImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            weatherConditionImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            weatherConditionImage.widthAnchor.constraint(equalToConstant: 60),
            weatherConditionImage.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

