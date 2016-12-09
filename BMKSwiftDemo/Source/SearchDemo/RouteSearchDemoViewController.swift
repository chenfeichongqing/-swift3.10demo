//
//  RouteSearchDemoViewController.swift
//  BMKSwiftDemo
//
//  Created by wzy on 15/11/6.
//  Copyright © 2015年 baidu. All rights reserved.
//

import UIKit

class RouteSearchDemoViewController: UIViewController, BMKMapViewDelegate, BMKRouteSearchDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var _mapView: BMKMapView!
    @IBOutlet weak var fromCityField: UITextField!
    @IBOutlet weak var fromAddressField: UITextField!
    @IBOutlet weak var toCityField: UITextField!
    @IBOutlet weak var toAddressField: UITextField!
    
    var routeSearch: BMKRouteSearch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        routeSearch = BMKRouteSearch()
        
        // 界面初始化
        fromCityField.text = "北京"
        fromAddressField.text = "天安门"
        toCityField.text = "北京"
        toAddressField.text = "百度大厦"
        fromAddressField.delegate = self
        fromAddressField.delegate = self
        toCityField.delegate = self
        toAddressField.delegate = self
        
        // 在导航栏上添加“途径点”按钮
        let screenshotBarButton = UIBarButtonItem(title: "途经点", style: .plain, target: self, action: #selector(RouteSearchDemoViewController.wayPointsRouteSearch))
        self.navigationItem.rightBarButtonItem = screenshotBarButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _mapView.viewWillAppear()
        _mapView.delegate = self
        routeSearch.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _mapView.viewWillDisappear()
        _mapView.delegate = nil
        routeSearch.delegate = nil
    }
    
    // MARK: - IBAction
    
    @IBAction func busRouteSearch(_ sender: UIButton) {
        let from = BMKPlanNode()
        from.name = fromAddressField.text
        let to = BMKPlanNode()
        to.name = toAddressField.text
        
        let transitRouteSearchOption = BMKTransitRoutePlanOption()
        transitRouteSearchOption.city = fromCityField.text
        transitRouteSearchOption.from = from
        transitRouteSearchOption.to = to
        
        let flag = routeSearch.transitSearch(transitRouteSearchOption)
        if flag {
            print("公交检索发送成功")
        }else {
            print("公交检索发送失败")
        }
    }
    
    @IBAction func carRouteSearch(_ sender: UIButton) {
        let from = BMKPlanNode()
        from.name = fromAddressField.text
        from.cityName = fromCityField.text
        let to = BMKPlanNode()
        to.name = toAddressField.text
        to.cityName = toCityField.text
        
        let drivingRouteSearchOption = BMKDrivingRoutePlanOption()
        drivingRouteSearchOption.from = from
        drivingRouteSearchOption.to = to
        drivingRouteSearchOption.drivingRequestTrafficType = BMK_DRIVING_REQUEST_TRAFFICE_TYPE_NONE//不获取路况信息
        
        let flag = routeSearch.drivingSearch(drivingRouteSearchOption)
        if flag {
            print("驾乘检索发送成功")
        }else {
            print("驾乘检索发送失败")
        }
    }
    
    @IBAction func walkRouteSearch(_ sender: UIButton) {
        let from = BMKPlanNode()
        from.name = fromAddressField.text
        from.cityName = fromCityField.text
        let to = BMKPlanNode()
        to.name = toAddressField.text
        to.cityName = toCityField.text
        
        let walkingRouteSearchOption = BMKWalkingRoutePlanOption()
        walkingRouteSearchOption.from = from
        walkingRouteSearchOption.to = to
        let flag = routeSearch.walkingSearch(walkingRouteSearchOption)
        
        if flag {
            print("步行检索发送成功")
        }else {
            print("步行检索发送失败")
        }

    }
    
    @IBAction func rideRouteSearch(_ sender: UIButton) {
        let from = BMKPlanNode()
        from.name = fromAddressField.text
        from.cityName = fromCityField.text
        let to = BMKPlanNode()
        to.name = toAddressField.text
        to.cityName = toCityField.text
        
        let option = BMKRidingRoutePlanOption()
        option.from = from
        option.to = to
        let flag = routeSearch.ridingSearch(option)
        
        if flag {
            print("骑行检索发送成功")
        }else {
            print("骑行检索发送失败")
        }
    }
    
    
    func wayPointsRouteSearch() {
        let wayPointsRouteSearch = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WayPointsSearchDemoViewController")
        self.navigationController!.pushViewController(wayPointsRouteSearch, animated: true)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        fromCityField.resignFirstResponder()
        fromAddressField.resignFirstResponder()
        toCityField.resignFirstResponder()
        toAddressField.resignFirstResponder()
        return true
    }
    
    // MARK: - BMKRouteSearchDelegate

    /**
    *返回公交搜索结果
    *@param searcher 搜索对象
    *@param result 搜索结果，类型为BMKTransitRouteResult
    *@param error 错误号，@see BMKSearchErrorCode
    */
    func onGetTransitRouteResult(_ searcher: BMKRouteSearch!, result: BMKTransitRouteResult!, errorCode error: BMKSearchErrorCode) {
        print("onGetTransitRouteResult: \(error)")

        _mapView.removeAnnotations(_mapView.annotations)
        _mapView.removeOverlays(_mapView.overlays)
        
        if error == BMK_SEARCH_NO_ERROR {
            let plan = result.routes[0] as! BMKTransitRouteLine

            let size = plan.steps.count
            var planPointCounts = 0
            for i in 0..<size {
                let transitStep = plan.steps[i] as! BMKTransitStep
                if i == 0 {
                    let item = RouteAnnotation()
                    item.coordinate = plan.starting.location
                    item.title = "起点"
                    item.type = 0
                    _mapView.addAnnotation(item)  // 添加起点标注
                }else if i == size - 1 {
                    let item = RouteAnnotation()
                    item.coordinate = plan.terminal.location
                    item.title = "终点"
                    item.type = 1
                    _mapView.addAnnotation(item)  // 添加终点标注
                }
                let item = RouteAnnotation()
                item.coordinate = transitStep.entrace.location
                item.title = transitStep.instruction
                item.type = 3
                _mapView.addAnnotation(item)
                
                // 轨迹点总数累计
                planPointCounts = Int(transitStep.pointsCount) + planPointCounts
            }
            
            // 轨迹点
            var tempPoints = Array(repeating: BMKMapPoint(x: 0, y: 0), count: planPointCounts)
            var i = 0
            for j in 0..<size {
                let transitStep = plan.steps[j] as! BMKTransitStep
                for k in 0..<Int(transitStep.pointsCount) {
                    tempPoints[i].x = transitStep.points[k].x
                    tempPoints[i].y = transitStep.points[k].y
                    i += 1
                }
            }
            
            // 通过 points 构建 BMKPolyline
            let polyLine = BMKPolyline(points: &tempPoints, count: UInt(planPointCounts))
            // 添加路线 overlay
            _mapView.add(polyLine)
            
            mapViewFitPolyLine(polyLine)
        }
    }
    
    /**
     *返回驾乘搜索结果
     *@param searcher 搜索对象
     *@param result 搜索结果，类型为BMKDrivingRouteResult
     *@param error 错误号，@see BMKSearchErrorCode
     */
    func onGetDrivingRouteResult(_ searcher: BMKRouteSearch!, result: BMKDrivingRouteResult!, errorCode error: BMKSearchErrorCode) {
        print("onGetDrivingRouteResult: \(error)")

        _mapView.removeAnnotations(_mapView.annotations)
        _mapView.removeOverlays(_mapView.overlays)
        
        if error == BMK_SEARCH_NO_ERROR {
            let plan = result.routes[0] as! BMKDrivingRouteLine

            let size = plan.steps.count
            var planPointCounts = 0
            for i in 0..<size {
                let transitStep = plan.steps[i] as! BMKDrivingStep
                if i == 0 {
                    let item = RouteAnnotation()
                    item.coordinate = plan.starting.location
                    item.title = "起点"
                    item.type = 0
                    _mapView.addAnnotation(item)  // 添加起点标注
                }else if i == size - 1 {
                    let item = RouteAnnotation()
                    item.coordinate = plan.terminal.location
                    item.title = "终点"
                    item.type = 1
                    _mapView.addAnnotation(item)  // 添加终点标注
                }
                
                // 添加 annotation 节点
                let item = RouteAnnotation()
                item.coordinate = transitStep.entrace.location
                item.title = transitStep.instruction
                item.degree = Int(transitStep.direction) * 30
                item.type = 4
                _mapView.addAnnotation(item)
                
                // 轨迹点总数累计
                planPointCounts = Int(transitStep.pointsCount) + planPointCounts
            }
            
            // 添加途径点
            if plan.wayPoints != nil {
                for tempNode in plan.wayPoints as! [BMKPlanNode] {
                    let item = RouteAnnotation()
                    item.coordinate = tempNode.pt
                    item.type = 5
                    item.title = tempNode.name
                    _mapView.addAnnotation(item)
                }
            }
            
            // 轨迹点
            var tempPoints = Array(repeating: BMKMapPoint(x: 0, y: 0), count: planPointCounts)
            var i = 0
            for j in 0..<size {
                let transitStep = plan.steps[j] as! BMKDrivingStep
                for k in 0..<Int(transitStep.pointsCount) {
                    tempPoints[i].x = transitStep.points[k].x
                    tempPoints[i].y = transitStep.points[k].y
                    i += 1
                }
            }
            
            // 通过 points 构建 BMKPolyline
            let polyLine = BMKPolyline(points: &tempPoints, count: UInt(planPointCounts))
            // 添加路线 overlay
            _mapView.add(polyLine)
            mapViewFitPolyLine(polyLine)
        }
    }
    
    /**
     *返回步行搜索结果
     *@param searcher 搜索对象
     *@param result 搜索结果，类型为BMKWalkingRouteResult
     *@param error 错误号，@see BMKSearchErrorCode
     */
    func onGetWalkingRouteResult(_ searcher: BMKRouteSearch!, result: BMKWalkingRouteResult!, errorCode error: BMKSearchErrorCode) {
        print("onGetWalkingRouteResult: \(error)")
        _mapView.removeAnnotations(_mapView.annotations)
        _mapView.removeOverlays(_mapView.overlays)
        
        if error == BMK_SEARCH_NO_ERROR {
            let plan = result.routes[0] as! BMKWalkingRouteLine

            let size = plan.steps.count
            var planPointCounts = 0
            for i in 0..<size {
                let transitStep = plan.steps[i] as! BMKWalkingStep
                if i == 0 {
                    let item = RouteAnnotation()
                    item.coordinate = plan.starting.location
                    item.title = "起点"
                    item.type = 0
                    _mapView.addAnnotation(item)  // 添加起点标注
                }else if i == size - 1 {
                    let item = RouteAnnotation()
                    item.coordinate = plan.terminal.location
                    item.title = "终点"
                    item.type = 1
                    _mapView.addAnnotation(item)  // 添加终点标注
                }
                // 添加 annotation 节点
                let item = RouteAnnotation()
                item.coordinate = transitStep.entrace.location
                item.title = transitStep.entraceInstruction
                item.degree = Int(transitStep.direction) * 30
                item.type = 4
                _mapView.addAnnotation(item)
                
                // 轨迹点总数累计
                planPointCounts = Int(transitStep.pointsCount) + planPointCounts
            }
            
            // 轨迹点
            var tempPoints = Array(repeating: BMKMapPoint(x: 0, y: 0), count: planPointCounts)
            var i = 0
            for j in 0..<size {
                let transitStep = plan.steps[j] as! BMKWalkingStep
                for k in 0..<Int(transitStep.pointsCount) {
                    tempPoints[i].x = transitStep.points[k].x
                    tempPoints[i].y = transitStep.points[k].y
                    i += 1
                }
            }
            
            // 通过 points 构建 BMKPolyline
            let polyLine = BMKPolyline(points: &tempPoints, count: UInt(planPointCounts))
            _mapView.add(polyLine)  // 添加路线 overlay
            mapViewFitPolyLine(polyLine)
        }
    }
    
    /**
     *返回骑行搜索结果
     *@param searcher 搜索对象
     *@param result 搜索结果，类型为BMKRidingRouteResult
     *@param error 错误号，@see BMKSearchErrorCode
     */
    func onGetRidingRouteResult(_ searcher: BMKRouteSearch!, result: BMKRidingRouteResult!, errorCode error: BMKSearchErrorCode) {
        print("onGetRidingRouteResult: \(error)")
        _mapView.removeAnnotations(_mapView.annotations)
        _mapView.removeOverlays(_mapView.overlays)
        
        if error == BMK_SEARCH_NO_ERROR {
            let plan = result.routes[0] as! BMKRidingRouteLine
            
            let size = plan.steps.count
            var planPointCounts = 0
            for i in 0..<size {
                let transitStep = plan.steps[i] as! BMKRidingStep
                if i == 0 {
                    let item = RouteAnnotation()
                    item.coordinate = plan.starting.location
                    item.title = "起点"
                    item.type = 0
                    _mapView.addAnnotation(item)  // 添加起点标注
                } else if i == size - 1 {
                    let item = RouteAnnotation()
                    item.coordinate = plan.terminal.location
                    item.title = "终点"
                    item.type = 1
                    _mapView.addAnnotation(item)  // 添加终点标注
                }
                // 添加 annotation 节点
                let item = RouteAnnotation()
                item.coordinate = transitStep.entrace.location
                item.title = transitStep.entraceInstruction
                item.degree = Int(transitStep.direction) * 30
                item.type = 4
                _mapView.addAnnotation(item)
                
                // 轨迹点总数累计
                planPointCounts = Int(transitStep.pointsCount) + planPointCounts
            }
            
            // 轨迹点
            var tempPoints = Array(repeating: BMKMapPoint(x: 0, y: 0), count: planPointCounts)
            var i = 0
            for j in 0..<size {
                let transitStep = plan.steps[j] as! BMKRidingStep
                for k in 0..<Int(transitStep.pointsCount) {
                    tempPoints[i].x = transitStep.points[k].x
                    tempPoints[i].y = transitStep.points[k].y
                    i += 1
                }
            }
            
            // 通过 points 构建 BMKPolyline
            let polyLine = BMKPolyline(points: &tempPoints, count: UInt(planPointCounts))
            _mapView.add(polyLine)  // 添加路线 overlay
            mapViewFitPolyLine(polyLine)
        }
    }
    
    // MARK: - BMKMapViewDelegate
    
    /**
    *根据anntation生成对应的View
    *@param mapView 地图View
    *@param annotation 指定的标注
    *@return 生成的标注View
    */
    func mapView(_ mapView: BMKMapView!, viewFor annotation: BMKAnnotation!) -> BMKAnnotationView! {
        if let routeAnnotation = annotation as! RouteAnnotation? {
            return getViewForRouteAnnotation(routeAnnotation)
        }
        return nil
    }
    
    /**
     *根据overlay生成对应的View
     *@param mapView 地图View
     *@param overlay 指定的overlay
     *@return 生成的覆盖物View
     */
    func mapView(_ mapView: BMKMapView!, viewFor overlay: BMKOverlay!) -> BMKOverlayView! {
        if overlay as! BMKPolyline? != nil {
            let polylineView = BMKPolylineView(overlay: overlay as! BMKPolyline)
            polylineView?.strokeColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.7)
            polylineView?.lineWidth = 3
            return polylineView
        }
        return nil
    }
    
    // MARK: - 
    
    func getViewForRouteAnnotation(_ routeAnnotation: RouteAnnotation!) -> BMKAnnotationView? {
        var view: BMKAnnotationView?
        
        var imageName: String?
        switch routeAnnotation.type {
        case 0:
            imageName = "nav_start"
        case 1:
            imageName = "nav_end"
        case 2:
            imageName = "nav_bus"
        case 3:
            imageName = "nav_rail"
        case 4:
            imageName = "direction"
        case 5:
            imageName = "nav_waypoint"
        default:
            return nil
        }
        let identifier = "\(imageName)_annotation"
        view = _mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if view == nil {
            view = BMKAnnotationView(annotation: routeAnnotation, reuseIdentifier: identifier)
            view?.centerOffset = CGPoint(x: 0, y: -(view!.frame.size.height * 0.5))
            view?.canShowCallout = true
        }
        
        view?.annotation = routeAnnotation

        let bundlePath = (Bundle.main.resourcePath)! + "/mapapi.bundle/"
        let bundle = Bundle(path: bundlePath)
       let imagePath = (bundle?.resourcePath)! + "/images/icon_"+imageName!+".png"
    //        if let imagePath = (bundle?.resourcePath)! + "/images/icon_\(imageName!).png" {
        if !(imagePath == nil){
            var image = UIImage(contentsOfFile: imagePath)
            if routeAnnotation.type == 4 {
                image = imageRotated(image, degrees: routeAnnotation.degree)
            }
            if image != nil {
                view?.image = image
            }
        }

        return view
    }

    
    //根据polyline设置地图范围
    func mapViewFitPolyLine(_ polyline: BMKPolyline!) {
        if polyline.pointCount < 1 {
            return
        }
        
        let pt = polyline.points[0]
        var ltX = pt.x
        var rbX = pt.x
        var ltY = pt.y
        var rbY = pt.y
        
        for i in 1..<polyline.pointCount {
            let pt = polyline.points[Int(i)]
            if pt.x < ltX {
                ltX = pt.x
            }
            if pt.x > rbX {
                rbX = pt.x
            }
            if pt.y > ltY {
                ltY = pt.y
            }
            if pt.y < rbY {
                rbY = pt.y
            }
        }

        let rect = BMKMapRectMake(ltX, ltY, rbX - ltX, rbY - ltY)
        _mapView.visibleMapRect = rect
        _mapView.zoomLevel = _mapView.zoomLevel - 0.3
    }
    
    //旋转图片
    func imageRotated(_ image: UIImage!, degrees: Int!) -> UIImage {
        let width = (image.cgImage)?.width
        let height = (image.cgImage)?.height
        let rotatedSize = CGSize(width: width!, height: height!)
        UIGraphicsBeginImageContext(rotatedSize);
        let bitmap = UIGraphicsGetCurrentContext();
        bitmap?.translateBy(x: rotatedSize.width/2, y: rotatedSize.height/2);
        bitmap?.rotate(by: CGFloat(Double(degrees) * M_PI / 180.0));
        bitmap?.rotate(by: CGFloat(M_PI));
        bitmap?.scaleBy(x: -1.0, y: 1.0);
        bitmap?.draw(image.cgImage!, in: CGRect(x: -rotatedSize.width/2, y: -rotatedSize.height/2, width: rotatedSize.width, height: rotatedSize.height));
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage!;
    }
}
