import Foundation
import Capacitor
import flic2lib

@objc(FlicButtonPlugin)
public class FlicButtonPlugin: CAPPlugin, CAPBridgedPlugin {
   
    public let identifier = "FlicButtonPlugin"
    public let jsName = "FlicButton"
    
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "echo", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getButtons", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "isScanning", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "scanForButtons", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "connectButton", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "disconnectButton", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "removeAllButtons", returnType: CAPPluginReturnPromise),
    ]
    
    private var flicManager: FLICManager?

    @objc func echo(_ call: CAPPluginCall) {
        call.resolve(["value": "Flic Called"])
    }
    
    override public func load() {
        FLICManager.configure(with: self, buttonDelegate: self, background: true)
        flicManager = FLICManager.shared()
    }

    @objc public func getButtons(_ call: CAPPluginCall) {
        guard let buttons = FLICManager.shared()?.buttons as? [FLICButton] else {
            call.resolve(["buttons": []])
            return
        }

        let buttonList = buttons.map { button in
            return [
                "buttonId": button.bluetoothAddress,
                "name": button.name ?? "",
                "state": button.state.rawValue
            ]
        }
        call.resolve(["buttons": buttonList])
    }

    // MARK: - Start Scanning for Buttons
    @objc public func isScanning(_ call: CAPPluginCall) {
        let scanning = FLICManager.shared()?.isScanning ?? false
        call.resolve(["isScanning": scanning])
    }
    
    @objc public func stopScanning(_ call: CAPPluginCall) {
        FLICManager.shared()?.stopScan()
        call.resolve(["stopScan": "true"])
    }
    
    @objc func scanForButtons(_ call: CAPPluginCall) {
        guard let flicManager = flicManager else {
            call.reject("Flic Manager is not initialized")
            return
        }
        if (flicManager.isScanning) {
            flicManager.stopScan()
        }

        flicManager.scanForButtons(stateChangeHandler: { event in
            var stateMessage = ""
            switch event {
            case .discovered: stateMessage = "A Flic was discovered."
            case .connected: stateMessage = "A Flic is being verified."
            case .verified: stateMessage = "The Flic was verified successfully."
            case .verificationFailed: stateMessage = "The Flic verification failed."
            default: break
            }
            self.notifyListeners("scanEvent", data: ["message": stateMessage])
        }) { (button, error) in
            if let error = error {
                self.notifyListeners("scanFailed", data: ["error": error])
                call.reject("<IOS FLIC:> Scan failed : \(error.localizedDescription) : \(error)")
                return
            }
            if let button = button {
                button.triggerMode = .clickAndDoubleClickAndHold
                self.notifyListeners("scanSuccess", data: ["buttonId": button.bluetoothAddress])
                call.resolve(["message" : "<IOS FLIC:> Scan Successful"])
            }
        }
    }

    // MARK: - Connect to a Button
    @objc func connectButton(_ call: CAPPluginCall) {
        guard let buttonId = call.getString("buttonId"),
              let button = flicManager?.buttons().first(where: { $0.bluetoothAddress == buttonId }) else {
            call.reject("Button not found")
            return
        }
        button.connect()
        notifyListeners("buttonConnecting", data: ["buttonId": button.bluetoothAddress])
        call.resolve(["message": "Button connecting..."])
    }

    // MARK: - Disconnect a Button
    @objc func disconnectButton(_ call: CAPPluginCall) {
        guard let buttonId = call.getString("buttonId"),
              let button = flicManager?.buttons().first(where: { $0.bluetoothAddress == buttonId }) else {
            call.reject("Button not found")
            return
        }
        button.disconnect()
        notifyListeners("buttonDisconnected", data: ["buttonId": button.bluetoothAddress])
        call.resolve(["message": "Button disconnected"])
    }

    // MARK: - Remove All Buttons
    @objc func removeAllButtons(_ call: CAPPluginCall) {
        for button in flicManager?.buttons() ?? [] {
            flicManager?.forgetButton(button, completion: { (uuid, error) in
                self.notifyListeners("buttonRemoved", data: ["buttonId": uuid.uuidString])
            })
        }
        call.resolve(["message": "All buttons removed"])
    }
}

// MARK: - FLICButtonDelegate
extension FlicButtonPlugin: FLICButtonDelegate {
    public func buttonDidConnect(_ button: FLICButton) {
        notifyListeners("buttonConnected", data: [
            "buttonId": button.bluetoothAddress,
            "name": button.name ?? "",
            "state": button.state.rawValue,
        ])
    }

    public func button(_ button: FLICButton, didDisconnectWithError error: (any Error)?) {
        notifyListeners("buttonDisconnected", data: [
            "buttonId": button.bluetoothAddress,
            "name": button.name ?? "",
            "state": button.state.rawValue,
            "error": error?.localizedDescription ?? "Unknown error"
        ])
    }

    public func button(_ button: FLICButton, didFailToConnectWithError error: (any Error)?) {
        notifyListeners("buttonConnectionFailed", data: [
            "buttonId": button.bluetoothAddress,
            "name": button.name ?? "",
            "state": button.state.rawValue,
            "error": error?.localizedDescription ?? "Unknown error"
        ])
    }

    public func buttonIsReady(_ button: FLICButton) {
        notifyListeners("buttonReady", data: [
            "buttonId": button.bluetoothAddress,
            "name": button.name ?? "",
            "state": button.state.rawValue,
        ])
    }

    public func button(_ button: FLICButton, didReceiveButtonClick queued: Bool, age: Int) {
        notifyListeners("buttonClick", data: [
            "buttonId": button.bluetoothAddress,
            "name": button.name ?? "",
            "state": button.state.rawValue,
            "event": "single_click"
        ])
    }
    
    public func button(_ button: FLICButton, didReceiveButtonDoubleClick queued: Bool, age: Int) {
        notifyListeners("buttonClick", data: [
            "buttonId": button.bluetoothAddress,
            "name": button.name ?? "",
            "state": button.state.rawValue,
            "event": "double_click"
        ])
    }
    
    public func button(_ button: FLICButton, didReceiveButtonHold queued: Bool, age: Int) {
        notifyListeners("buttonClick", data: [
            "buttonId": button.bluetoothAddress,
            "name": button.name ?? "",
            "state": button.state.rawValue,
            "event": "hold"
        ])
    }
}

// MARK: - FLICManagerDelegate
extension FlicButtonPlugin:  FLICManagerDelegate{
    public func managerDidRestoreState(_ manager: FLICManager) {
        notifyListeners("restoreState", data: ["message": "State restored with \(manager.buttons().count) buttons"])
    }

    public func manager(_ manager: FLICManager, didUpdate state: FLICManagerState) {
        notifyListeners("managerStateUpdate", data: ["state": state.rawValue])
    }
}
