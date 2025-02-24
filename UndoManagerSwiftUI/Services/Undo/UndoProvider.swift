//
//  UndoProvider.swift
//  UndoManagerSwiftUI
//
//  Created by Maksim Kuklitski on 07/02/2025.
//

import SwiftUI

class UndoHandler<Value1: Equatable, Value2: Equatable>: ObservableObject {
    var binding1: Binding<Value1>? // rectangles
    var binding2: Binding<Value2>? // selectedUUID
    weak var undoManager: UndoManager?
    
    func registerUndo(from oldValue1: Value1, to newValue1: Value1,
                      from oldValue2: Value2, to newValue2: Value2) {
        undoManager?.registerUndo(withTarget: self) { handler in
            handler.registerUndo(from: newValue1, to: oldValue1,
                                 from: newValue2, to: oldValue2)
            
            handler.binding1?.wrappedValue = oldValue1
            handler.binding2?.wrappedValue = oldValue2
        }
    }
    
    init() {}
}

struct UndoProvider<WrappedView, Value1: Equatable, Value2: Equatable>: View where WrappedView: View {
    @Environment(\.undoManager)
    var undoManager
    
    @StateObject
    var handler: UndoHandler<Value1, Value2> = UndoHandler()
    
    var wrappedView: (
        Binding<Value1>,
        Binding<Value2>
    ) -> WrappedView
    
    var binding1: Binding<Value1>
    var binding2: Binding<Value2>
    
    init(
        _ binding1: Binding<Value1>,
        _ binding2: Binding<Value2>,
        
        @ViewBuilder wrappedView: @escaping (
            Binding<Value1>,
            Binding<Value2>
        ) -> WrappedView
    ) {
        self.binding1 = binding1
        self.binding2 = binding2
        self.wrappedView = wrappedView
    }
    
    var interceptedBinding1: Binding<Value1> {
        Binding {
            self.binding1.wrappedValue
        } set: { newValue1 in
            if self.binding1.wrappedValue != newValue1 {
                self.handler.registerUndo(
                    from: self.binding1.wrappedValue,
                    to: newValue1,
                    from: self.binding2.wrappedValue,
                    to: self.binding2.wrappedValue
                )
            }
            self.binding1.wrappedValue = newValue1
        }
    }
    
    var interceptedBinding2: Binding<Value2> {
        Binding {
            self.binding2.wrappedValue
        } set: { newValue2 in
            if self.binding2.wrappedValue != newValue2 {
                self.handler.registerUndo(
                    from: self.binding1.wrappedValue,
                    to: self.binding1.wrappedValue,
                    from: self.binding2.wrappedValue,
                    to: newValue2
                )
            }
            self.binding2.wrappedValue = newValue2
        }
    }
    
    var body: some View {
        wrappedView(
            self.interceptedBinding1,
            self.interceptedBinding2
        )
        .onAppear {
            self.handler.binding1 = self.binding1
            self.handler.binding2 = self.binding2
            self.handler.undoManager = self.undoManager
        }
        .onChange(of: self.undoManager) { _, undoManager in
            self.handler.undoManager = undoManager
        }
    }
}
