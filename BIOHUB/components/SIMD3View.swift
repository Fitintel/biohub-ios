//
//  SIMD3View.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-05.
//

import SwiftUI
import simd

struct SIMD3View: View {
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.simd3 == rhs.simd3
    }
    
    let simd3: SIMD3<Float>?
    
    var body: some View {
        HStack {
            Text("\(String(format: "%.2f", simd3?.x ?? 0))").monospaced().font(.system(size: 9))
            Spacer()
            Text("\(String(format: "%.2f", simd3?.y ?? 0))").monospaced().font(.system(size: 9))
            Spacer()
            Text("\(String(format: "%.2f", simd3?.z ?? 0))").monospaced().font(.system(size: 9))
        }
        .animation(nil, value: UUID())
    }
    
}
