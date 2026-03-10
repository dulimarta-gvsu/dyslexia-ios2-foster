//
//  Navigator.swift
//  dyslexia
//
//  Created by Aaron Foster on 3/8/26.
//

import SwiftUI
import Combine

enum Route: Hashable{
    case GameHistory
    case SelectedGameHistory(AppViewModel.WordRecord)
    case GameOptions
}

class Navigator: ObservableObject {
    @Published var navPath: [Route] = []
    // payload is a stack for exchanging data between a parent screen
    // and its immediate child screen
    var payload: Array<Dictionary<String, Any>> = []
    
    func navigate(to dest: Route)
    {
        navPath.append(dest)
        payload.append([:])
    }
    
    func navigateBack(){
        navPath.removeLast()
        payload.removeLast()
    }
    
    func navigateBackToRoot(){
        navPath.removeAll()
        navPath.removeAll()
    }
    
    func navigateBackUntil(d: Route, inclusive: Bool){
        if navPath.isEmpty{
            return
        }
        navPath.removeLast()
        
        while navPath.last != d && !navPath.isEmpty{
            navPath.removeLast()
        }
        
        if inclusive && !navPath.isEmpty{
            navPath.removeLast()
        }
    }
    
    func previousPayloadSet<T>(key: String, value: T) {
        payload[payload.endIndex-2][key] = value
    }
    
    func currentPayloadGet<T>(key: String) -> T {
        let lastPayload = payload.last!
        return lastPayload[key] as! T
    }
    
}
