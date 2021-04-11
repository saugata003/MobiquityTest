//
//  ViewController.swift
//  Mobiquity
//
//  Created by Saugata Chakraborty on 10/04/21.
//  Copyright © 2021 Azure. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let forecastVM = ForecastVM()
    var cityArrayList = [CitiesResponseModelElement]()
    override func viewDidLoad() {
        super.viewDidLoad()
        forecastVM.delegate = self
        forecastVM.getCities()
    }
    
    func weatherReport() {
        let params = WeatherRequestModel(lat: 0.000000, lon: 0.0000000, appid: APIConstants.appId, units: "metric")
        showProgressHUD()
        forecastVM.delegate = self
        forecastVM.getWeatherList(params: params)
    }
    
    func forecastReport() {
        let params = ForecastRequestModel(lat: 0.000000, lon: 0.0000000, appid: APIConstants.appId)
        forecastVM.delegate = self
        forecastVM.getForecastList(params: params)
    }
}

extension ViewController: ViewModelDelegate {
    func viewModelDidUpdate(sender: WeatherViewModel) {
        hideProgressHUD()
        DispatchQueue.main.async {
            if self.forecastVM.reason == .cities {
                self.cityArrayList = self.forecastVM.citiesModel!
            }
        }
    }
    
    func viewModelUpdateFailed(error: WeatherAppError) {
        hideProgressHUD()
    }
}

