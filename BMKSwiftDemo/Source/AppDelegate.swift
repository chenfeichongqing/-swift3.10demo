//
//  AppDelegate.swift
//  BMKSwiftDemo
//
//  Created by wzy on 15/11/2.
//  Copyright © 2015年 baidu. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, BMKGeneralDelegate {

    var window: UIWindow?
    var _mapManager: BMKMapManager?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // 要使用百度地图，请先启动BaiduMapManager
        _mapManager = BMKMapManager()
        // 如果要关注网络及授权验证事件，请设定generalDelegate参数
        let ret = _mapManager?.start("5ytZHIlApbvyutdiBq6MoZPBDw69732p", generalDelegate: self)
        if ret == false {
            NSLog("manager start failed!")
        }

        let rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RootViewController")
        let navigationController = UINavigationController(rootViewController: rootViewController)
        window?.rootViewController = navigationController
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//        BMKMapView.willBackGround()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//        BMKMapView.didForeGround()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    //MARK: - BMKGeneralDelegate
    func onGetNetworkState(_ iError: Int32) {
        if (0 == iError) {
            NSLog("联网成功");
        }
        else{
            NSLog("联网失败，错误代码：Error\(iError)");
        }
    }
    
    func onGetPermissionState(_ iError: Int32) {
        if (0 == iError) {
            NSLog("授权成功");
        }
        else{
            NSLog("授权失败，错误代码：Error\(iError)");
        }
    }
}

