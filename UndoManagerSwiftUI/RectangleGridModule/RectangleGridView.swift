//
//  ContentView.swift
//  UndoManagerSwiftUI
//
//  Created by Maksim Kuklitski on 07/02/2025.
//

import SwiftUI

struct RectangleGridView: View {
    @State private var viewModel: RectangleGridViewModel
    @Environment(\.undoManager) var undoManager
    
    init(viewModel: RectangleGridViewModel = RectangleGridViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        UndoProvider($viewModel.rectangles, $viewModel.selectedUUID) { rectangles, selectedUUID in
            VStack {
                rectangleGrid
                controlButtons(rectangles, selectedUUID)
            }
        }
    }
    
    // MARK: - Rectangle Grid
    private var rectangleGrid: some View {
        ScrollView {
            ScrollViewReader { proxy in
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                    ForEach(viewModel.rectangles) { rectangle in
                        Rectangle()
                            .fill(rectangle.color)
                            .frame(height: 100)
                            .clipShape(.rect(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(viewModel.strokeColor(for: rectangle), lineWidth: 5)
                            )
                            .onTapGesture { viewModel.updateSelectedUUID(rectangle.id) }
                    }
                }
                .padding()
                .onChange(of: viewModel.selectedUUID) { scrollToSelectedRectangle(proxy) }
            }
        }
    }
    
    private func scrollToSelectedRectangle(_ proxy: ScrollViewProxy) {
        if let id = viewModel.getActiveRectangleId() {
            withAnimation {
                proxy.scrollTo(id, anchor: .center)
            }
        }
    }
    
    // MARK: - Controls (Undo/Redo & Add Button)
    private func controlButtons(_ rectangles: Binding<[RectangleItem]>, _ selectedUUID: Binding<UUID>) -> some View {
        HStack {
            undoRedoButtons
            Spacer()
            addRectangleButton(rectangles, selectedUUID)
        }
        .padding(.horizontal)
    }
    
    private var undoRedoButtons: some View {
        HStack {
            undoRedoButton(
                "arrow.uturn.backward.circle.fill",
                action: undoManager?.undo,
                isEnabled: undoManager?.canUndo ?? false
            )
            undoRedoButton(
                "arrow.uturn.forward.circle.fill",
                action: undoManager?.redo,
                isEnabled: undoManager?.canRedo ?? false
            )
        }
    }
    
    private func undoRedoButton(_ systemImageName: String, action: (() -> Void)?, isEnabled: Bool) -> some View {
        Button(action: { action?() }) {
            Image(systemName: systemImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundStyle(isEnabled ? .blue : .gray)
        }
        .disabled(!isEnabled)
    }
    
    private func addRectangleButton(_ rectangles: Binding<[RectangleItem]>, _ selectedUUID: Binding<UUID>) -> some View {
        Button(action: { viewModel.addRectangle(rectangles, selectedUUID) }) {
            Image(systemName: "plus")
                .font(.largeTitle)
                .padding()
                .background(.blue)
                .foregroundColor(.white)
                .clipShape(.circle)
        }
        .padding()
    }
}

#Preview {
    RectangleGridView()
}
