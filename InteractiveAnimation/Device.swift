//
//  Device.swift
//  AWW
//
//  Created by Sathish on 12/24/17.
//  Copyright © 2015 AnywhereWorks. All rights reserved.
//

import Foundation
import UIKit

enum DeviceHeight: CGFloat {

    case inch_3_5 = 480
    case inches_4 = 568
    case inches_4_7 = 667
    case inches_5_5 = 736
    case inches_5_8 = 812
    case inches_6_5 = 896

    var value: CGFloat {
        return self.rawValue
    }
}

struct Device {

    private let kDeviceUniqueIDKey = "_deviceUID"

    static let shared = Device()

    func isSimulator() -> Bool {
        return UIDevice.isSimulator
    }

    func currentHeight() -> CGFloat {
        return UIScreen.main.bounds.height
    }

    func currentWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }

    func currentSize() -> CGSize {
        return UIScreen.main.bounds.size
    }

    func isPhone4AndBelow() -> Bool {
        return currentHeight() <= DeviceHeight.inches_4.rawValue
    }

    var iPhone5sAndBelow: Bool {
        return currentHeight() < DeviceHeight.inches_4_7.rawValue
    }

    /// iPhone 6, 6s, 7, 8
    var is4_7inch: Bool {
        return currentHeight() == DeviceHeight.inches_4_7.value
    }

    /// Plus Device
    var is5_5inch: Bool {
        return currentHeight() == DeviceHeight.inches_5_5.value
    }

    var isIphoneX: Bool {
        return currentHeight() == DeviceHeight.inches_5_8.value
    }

    var isIphoneXsMax: Bool {
        return currentHeight() == DeviceHeight.inches_6_5.value
    }

    var isIphoneXDevices: Bool {
        return isIphoneX || isIphoneXsMax
    }

    /// iPhoneXseries and Plus devices
    var isLargerDevices: Bool {
        return isIphoneXDevices || is5_5inch
    }

    func getStatusBarHeight() -> CGFloat {
        return UIApplication.shared.statusBarFrame.height
        //        return self.isIphoneX ? 44 : 20
    }

    func adjustedKeyboardBottomHeight(height: CGFloat) -> CGFloat {
        return isIphoneXDevices ? (height - 34) : height
    }

    var isRunningTests: Bool {
        let env: [String: String] = ProcessInfo.processInfo.environment
        return env["XCInjectBundleInto"] != nil
    }
}


extension UIDevice {

    enum DeviceType {

        case iPhone35
        case iPhone40
        case iPhone47
        case iPhone55
        case iphoneX
        case iphoneXsMax
        case iPad

        var isPhone: Bool {
            return [ .iPhone35, .iPhone40, .iPhone47, .iPhone55, .iphoneX, .iphoneXsMax].contains(self)
        }
    }

    var deviceType: DeviceType? {

        switch UIDevice.current.userInterfaceIdiom {

            case .pad:
                return .iPad

            case .phone:

                let screenSize = UIScreen.main.bounds

                let height = max(screenSize.width, screenSize.height)

                switch height {
                    case 480:
                        return .iPhone35
                    case 568:
                        return .iPhone40
                    case 667:
                        return .iPhone47
                    case 736:
                        return .iPhone55
                    case 812:
                        return .iphoneX
                    case 896:
                        return .iphoneXsMax
                    default:
                        return nil
            }

            default:
                return nil
        }
    }

    static var isSimulator: Bool = {
        var isSimulator = false
        #if targetEnvironment(simulator)
        isSimulator = true
        #endif
        return isSimulator
    }()
}

