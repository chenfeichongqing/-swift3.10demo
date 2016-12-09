//
//  OpenGLDemoViewController.swift
//  BMKSwiftDemo
//
//  Created by wzy on 15/11/9.
//  Copyright © 2015年 baidu. All rights reserved.
//

import UIKit

struct GLPoint {
    var x: GLfloat = 0
    var y: GLfloat = 0
}

class OpenGLDemoViewController: UIViewController, BMKMapViewDelegate {
    
    @IBOutlet weak var _mapView: BMKMapView!
    
    var mapDidFinishLoad: Bool = false
    var coordinate = [CLLocationCoordinate2D]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _mapView.viewWillAppear()
        _mapView.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _mapView.viewWillDisappear()
        _mapView.delegate = nil
    }
    
    // MARK: - BMKMapViewDelegate
    
    /**
    *地图初始化完毕时会调用此接口
    */
    func mapViewDidFinishLoading(_ mapView: BMKMapView!) {
        coordinate.append(CLLocationCoordinate2DMake(39.965, 116.604))
        coordinate.append(CLLocationCoordinate2DMake(39.865, 116.604))
        coordinate.append(CLLocationCoordinate2DMake(39.865, 116.704))
        coordinate.append(CLLocationCoordinate2DMake(39.965, 116.704))
        mapDidFinishLoad = true
    }
    
    /**
     *地图渲染每一帧画面过程中，以及每次需要重绘地图时（例如添加覆盖物）都会调用此接口
     *@param mapview 地图View
     *@param status 此时地图的状态
     */
    func mapView(_ mapView: BMKMapView!, onDrawMapFrame status: BMKMapStatus!) {
        /*
        *do openGL render
        */

        if mapDidFinishLoad {
            glRender(status)
        }
    }
    
    // MARK: - glRender
    func glRender(_ status: BMKMapStatus) {
        let centerPoint = BMKMapPointForCoordinate(status.targetGeoPt)
        let components = UIColor.red.cgColor.components
        let red = components?[0]
        let green = components?[1]
        let blue = components?[2]
        let alpha = components?[3]
        
        var glPoints = [GLPoint]()
        // 坐标系圆点为地图中心点，此处转换坐标为相对坐标
        for i in 0...3 {
            let point = BMKMapPointForCoordinate(coordinate[i])
            var glPoint = GLPoint()
            glPoint.x = GLfloat(point.x - centerPoint.x)
            glPoint.y = GLfloat(-point.y + centerPoint.y)
            glPoints.append(glPoint)
        }
        // 获取缩放比例，18级比例尺为1:1基准
        var fZoomUnites = powf(2, 18-status.fLevel)
        
        glPushMatrix()
        glRotatef(status.fOverlooking, 1, 0, 0)
        glRotatef(status.fRotation, 0, 0, 1)
        
        fZoomUnites = 1 / fZoomUnites
        // 缩放使随地图放大或缩小
        glScalef(fZoomUnites, fZoomUnites, fZoomUnites)
        glEnableClientState(GLenum(GL_VERTEX_ARRAY))
        glEnable(GLenum(GL_BLEND))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
        
        glColor4f(GLfloat(red!), GLfloat(green!), GLfloat(blue!), GLfloat(alpha!))
        glVertexPointer(2, GLenum(GL_FLOAT), 0, glPoints)
        // 绘制的点个数
        glDrawArrays(GLenum(GL_TRIANGLE_FAN), 0, 4)
        
        glDisable(GLenum(GL_BLEND))
        glDisableClientState(GLenum(GL_VERTEX_ARRAY))
        glPopMatrix()
        glColor4f(1, 1, 1, 1)
    }

}
