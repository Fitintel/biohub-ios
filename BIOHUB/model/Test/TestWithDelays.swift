//
//  TestWithDelays.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-04.
//

import Foundation

public protocol TestWithDelays {
    
}

extension TestWithDelays {
    // 0 to 0.1 seconds
    func doNow(_ action: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + [0, 0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.08, 0.1].randomElement()!) {
            action()
        }
    }
    
    // 0.1 to 0.4 seconds
    func doImmediately(_ action: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + [0.1, 0.15, 0.2, 0.25, 0.3, 0.33, 0.4].randomElement()!) {
            action()
        }
    }

    // 0.1 to 1 second
    func doQuickly(_ action: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + [0.1, 0.3, 0.4, 0.45, 0.5, 0.6, 0.7, 0.8, 0.9, 1].randomElement()!) {
            action()
        }
    }
    
    // 0.7 to 2 seconds
    func doSoon(_ action: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + [0.7, 0.8, 0.9, 1, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.9, 2].randomElement()!) {
            action()
        }
    }
    
    // 2 to 5 seconds
    func doEventually(_ action: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + [2, 2.1, 2.2, 2.4, 2.6, 2.9, 3, 3.5, 3.6, 4, 4.1, 4.5, 4.8, 5].randomElement()!) {
            action()
        }
    }
    
    // 0.1-5 seconds
    func doAtSomePoint(_ action: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + [0.1, 0.3, 0.4, 0.45, 0.5, 0.6, 0.7, 0.8, 0.9, 1, 1.5, 2, 2.1, 2.2, 2.4, 2.6, 2.9, 3, 3.5, 3.6, 4, 4.1, 4.5, 4.8, 5].randomElement()!) {
            action()
        }
    }
}
