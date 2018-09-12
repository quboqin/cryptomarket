//
//  ExpandViewController.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 8/26/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import UIKit
import Charts

enum Option {
    case toggleValues
    case toggleIcons
    case toggleHighlight
    case animateX
    case animateY
    case animateXY
    case saveToGallery
    case togglePinchZoom
    case toggleAutoScaleMinMax
    case toggleData
    case toggleBarBorders
    // CandleChart
    case toggleShadowColorSameAsCandle
    case toggleShowCandleBar
    // CombinedChart
    case toggleLineValues
    case toggleBarValues
    case removeDataSet
    // CubicLineSampleFillFormatter
    case toggleFilled
    case toggleCircles
    case toggleCubic
    case toggleHorizontalCubic
    case toggleStepped
    // HalfPieChartController
    case toggleXValues
    case togglePercent
    case toggleHole
    case spin
    case drawCenter
    // RadarChart
    case toggleXLabels
    case toggleYLabels
    case toggleRotate
    case toggleHighlightCircle
    
    var label: String {
        switch self {
        case .toggleValues: return "Toggle Y-Values"
        case .toggleIcons: return "Toggle Icons"
        case .toggleHighlight: return "Toggle Highlight"
        case .animateX: return "Animate X"
        case .animateY: return "Animate Y"
        case .animateXY: return "Animate XY"
        case .saveToGallery: return "Save to Camera Roll"
        case .togglePinchZoom: return "Toggle PinchZoom"
        case .toggleAutoScaleMinMax: return "Toggle auto scale min/max"
        case .toggleData: return "Toggle Data"
        case .toggleBarBorders: return "Toggle Bar Borders"
        // CandleChart
        case .toggleShadowColorSameAsCandle: return "Toggle shadow same color"
        case .toggleShowCandleBar: return "Toggle show candle bar"
        // CombinedChart
        case .toggleLineValues: return "Toggle Line Values"
        case .toggleBarValues: return "Toggle Bar Values"
        case .removeDataSet: return "Remove Random Set"
        // CubicLineSampleFillFormatter
        case .toggleFilled: return "Toggle Filled"
        case .toggleCircles: return "Toggle Circles"
        case .toggleCubic: return "Toggle Cubic"
        case .toggleHorizontalCubic: return "Toggle Horizontal Cubic"
        case .toggleStepped: return "Toggle Stepped"
        // HalfPieChartController
        case .toggleXValues: return "Toggle X-Values"
        case .togglePercent: return "Toggle Percent"
        case .toggleHole: return "Toggle Hole"
        case .spin: return "Spin"
        case .drawCenter: return "Draw CenterText"
        // RadarChart
        case .toggleXLabels: return "Toggle X-Labels"
        case .toggleYLabels: return "Toggle Y-Labels"
        case .toggleRotate: return "Toggle Rotate"
        case .toggleHighlightCircle: return "Toggle highlight circle"
        }
    }
}

enum DataSource {
    case cryptoCompare
    case houbi
    
    init(source: Int) {
        switch source {
        case 0: self = .cryptoCompare
        case 1: self = .houbi
        default:
            self = .cryptoCompare
        }
    }
}

class ExpandViewController: UIViewController, ChartViewDelegate {
    @IBOutlet weak var chartView: CandleStickChartView!
    
    fileprivate var histoHourVolumes = [OHLCV]()
    
    var symbol: String = "BTC" {
        didSet {
            reloadData()
        }
    }
    
    var options: [Option]!
    
    private func setupUI() {
        self.options = [.toggleValues,
                        .toggleIcons,
                        .toggleHighlight,
                        .animateX,
                        .animateY,
                        .animateXY,
                        .saveToGallery,
                        .togglePinchZoom,
                        .toggleAutoScaleMinMax,
                        .toggleShadowColorSameAsCandle,
                        .toggleShowCandleBar,
                        .toggleData]
        
        chartView.delegate = self
        
        chartView.chartDescription?.enabled = false
        
        chartView.dragEnabled = false
        chartView.setScaleEnabled(true)
        chartView.maxVisibleCount = 200
        chartView.pinchZoomEnabled = true
        
        chartView.leftAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size: 10)!
        chartView.leftAxis.spaceTop = 0.3
        chartView.leftAxis.spaceBottom = 0.3
        chartView.leftAxis.axisMinimum = 6000
        
        chartView.rightAxis.enabled = false
        
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size: 10)!
    }
    
    func reloadData() {
        if KLineSource.shared.dataSource == DataSource.cryptoCompare {
            let cryptoCompareNetworkManager = CryptoCompareNetworkManager.shared
            _ = cryptoCompareNetworkManager.getDataFromEndPoint(.histohour(fsym: symbol, tsym: "USD", limit: 11), type: HistoHourResponse.self) { [weak self]
                (data, error) in
                if let histoHourResponse = data as? HistoHourResponse {
                    Log.i(histoHourResponse)
                    self?.histoHourVolumes = histoHourResponse.data
                    self?.setDataCount()
                }
            }
        } else {
            let huobiNetworkManager = HuobiNetworkManager.shared
            _ = huobiNetworkManager.getDataFromEndPoint(.historyKline(symbol: symbol.lowercased() + "usdt", period: "5min", size: 150), type: KlineResponse.self) { [weak self]
                (data, error) in
                if let kLineResponse = data as? KlineResponse {
                    Log.i(kLineResponse.data)
                    let kLineItems = kLineResponse.data
                    
                    kLineItems.forEach({ (kLineItem) in
                        let ohlcv = OHLCV(time: 0, open: kLineItem.open!, close: kLineItem.close!, low: kLineItem.low!, high: kLineItem.high!, volumefrom: 0.0, volumeto: 0.0)
                        self?.histoHourVolumes.append(ohlcv)
                        self?.setDataCount()
                    })

                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        
        chartView.delegate = self
    }
    
    fileprivate func setDataCount() -> Void {
        let count = self.histoHourVolumes.count
        
        if count == 0 {
            return
        }
        
        let yVals1 = (0 ..< count).map { (i) -> CandleChartDataEntry? in
            let high = self.histoHourVolumes[i].high
            let low = self.histoHourVolumes[i].low
            let open = self.histoHourVolumes[i].open
            let close = self.histoHourVolumes[i].close
            
            return CandleChartDataEntry(x: Double(i), shadowH: high, shadowL: low, open: open, close: close, icon: UIImage(named: "icon")!)
        }
        
        chartView.leftAxis.axisMinimum = self.histoHourVolumes.map {
            $0.low
            }.min()!
        
        let set1 = CandleChartDataSet(values: yVals1 as? [ChartDataEntry], label: "Data Set")
        set1.axisDependency = .left
        set1.setColor(UIColor(white: 80/255, alpha: 1))
        set1.drawIconsEnabled = false
        set1.shadowColor = .darkGray
        set1.shadowWidth = 0.7
        set1.decreasingColor = .red
        set1.decreasingFilled = true
        set1.increasingColor = UIColor(red: 122/255, green: 242/255, blue: 84/255, alpha: 1)
        set1.increasingFilled = false
        set1.neutralColor = .blue
        
        let data = CandleChartData(dataSet: set1)
        chartView.data = data
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ExpandViewController: SettingsViewControllerKLineDelegate {
    func settingsViewController(_ viewController: SettingsViewController, didSelectDataSource dataSource: DataSource) {
        Log.v("Select kLine Datasource \(dataSource)")
        self.reloadData()
    }
}
