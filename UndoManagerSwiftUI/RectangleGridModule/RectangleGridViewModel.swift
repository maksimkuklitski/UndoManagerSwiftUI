//
//  RectangleGridViewModel.swift
//  UndoManagerSwiftUI
//
//  Created by Maksim Kuklitski on 07/02/2025.
//

import SwiftUI

@Observable
class RectangleGridViewModel {
    var rectangles: [RectangleItem] = []
    var selectedUUID: UUID = UUID()
    
    func addRectangle(_ rectangles: Binding<[RectangleItem]>, _ selectedUUID: Binding<UUID>) {
        let id = UUID()
        let rectangle = RectangleItem(id: id, color: .random())
        rectangles.wrappedValue.append(rectangle)
        selectedUUID.wrappedValue = id
    }
    
    func updateSelectedUUID(_ uuid: UUID) {
        selectedUUID = uuid
    }
    
    func getActiveRectangleId() -> UUID? {
        rectangles.first { $0.id == selectedUUID }?.id
    }
    
    func strokeColor(for rectangle: RectangleItem) -> Color {
        selectedUUID == rectangle.id ? .orange : .clear
    }
}
