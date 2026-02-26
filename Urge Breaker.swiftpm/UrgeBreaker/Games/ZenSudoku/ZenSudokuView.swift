import SwiftUI

// MARK: - Zen Sudoku View
struct ZenSudokuView: View {
    @StateObject var viewModel: ZenSudokuViewModel
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var shakeErrors = false
    @State private var showSuccessGlow = false
    
    var body: some View {
        ZStack {
            Color.ubBackground.ignoresSafeArea()
            CalmBackgroundView()
            
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 4) {
                    Text("Zen Sudoku")
                        .font(Theme.fontTitle)
                        .foregroundColor(.ubTextPrimary)
                    HStack(spacing: 4) {
                        Text("Moves:")
                            .font(Theme.fontCaption)
                            .foregroundColor(.secondary)
                        SmoothScoreText(
                            value: viewModel.moveCount,
                            font: Theme.fontCaption,
                            color: .secondary
                        )
                    }
                }
                .padding(.top, 20)
                .scrollReveal(index: 0)
                
                Spacer()
                
                // Grid
                sudokuGrid
                    .shake(trigger: $shakeErrors)
                    .scrollReveal(index: 1)
                
                Spacer()
                
                // Number Keypad
                if !viewModel.isComplete {
                    numberKeypad
                        .scrollReveal(index: 2)
                }
                
                // Reset Button
                Button(action: { viewModel.reset() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("New Puzzle")
                    }
                    .font(Theme.fontHeadline)
                    .foregroundColor(.ubPrimary)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.ubSurface)
                    .cornerRadius(20)
                }
                .buttonStyle(CardPressStyle())
                .padding(.bottom, 20)
            }
            
            // Completion Overlay
            if viewModel.isComplete {
                completionOverlay
                    .overlayTransition()
                    .successGlow(trigger: $showSuccessGlow)
            }
        }
        .onChange(of: viewModel.isComplete) { complete in
            if complete { showSuccessGlow = true }
        }
        .onChange(of: viewModel.cells.filter({ $0.hasError }).count) { errorCount in
            if errorCount > 0 { shakeErrors = true }
        }
    }
    
    // MARK: - Sudoku Grid
    private var sudokuGrid: some View {
        VStack(spacing: 0) {
            ForEach(0..<4, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<4, id: \.self) { col in
                        let index = row * 4 + col
                        let cell = viewModel.cells[index]
                        
                        cellView(cell: cell, index: index)
                            .border(Color.ubPrimary.opacity(0.15), width: 1)
                            .overlay(boxBorder(row: row, col: col))
                    }
                }
            }
        }
        .background(Color.ubPrimary.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal, 40)
    }
    
    // MARK: - Cell View
    private func cellView(cell: ZenSudokuViewModel.Cell, index: Int) -> some View {
        let isSelected = viewModel.selectedCellIndex == index
        
        return Button(action: { viewModel.selectCell(index) }) {
            Text(cell.value > 0 ? "\(cell.value)" : "")
                .font(.system(size: 26, weight: cell.isFixed ? .bold : .medium, design: .rounded))
                .foregroundColor(cellTextColor(cell: cell))
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .background(cellBackground(cell: cell, isSelected: isSelected))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isSelected ? Color.ubPrimary : Color.clear, lineWidth: 2.5)
                        .animation(.easeInOut(duration: 0.2), value: isSelected)
                )
                .scaleEffect(cell.value > 0 && !cell.isFixed ? 1.0 : 1.0)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: cell.value)
        }
        .disabled(cell.isFixed)
        .accessibilityLabel("Row \(cell.row + 1), Column \(cell.col + 1), Value: \(cell.value > 0 ? "\(cell.value)" : "empty")")
    }
    
    // MARK: - Number Keypad
    private var numberKeypad: some View {
        HStack(spacing: 12) {
            ForEach(1...4, id: \.self) { number in
                Button(action: { viewModel.placeNumber(number) }) {
                    Text("\(number)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.ubPrimary)
                        .frame(width: 56, height: 56)
                        .background(Color.ubSurface)
                        .cornerRadius(14)
                        .shadow(color: Theme.Shadows.card, radius: 4, x: 0, y: 2)
                }
                .buttonStyle(KeypadButtonStyle())
                .disabled(viewModel.selectedCellIndex == nil)
                .accessibilityLabel("Place number \(number)")
            }
            
            // Clear button
            Button(action: { viewModel.clearCell() }) {
                Image(systemName: "xmark.circle")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.ubDanger)
                    .frame(width: 56, height: 56)
                    .background(Color.ubSurface)
                    .cornerRadius(14)
                    .shadow(color: Theme.Shadows.card, radius: 4, x: 0, y: 2)
            }
            .buttonStyle(KeypadButtonStyle())
            .disabled(viewModel.selectedCellIndex == nil)
            .accessibilityLabel("Clear cell")
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Completion Overlay
    private var completionOverlay: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 50))
                .foregroundColor(.ubSuccess)
            Text("Puzzle Complete!")
                .font(Theme.fontTitle)
                .foregroundColor(.ubSuccess)
            HStack(spacing: 4) {
                Text("Solved in")
                    .font(Theme.fontSubheadline)
                    .foregroundColor(.secondary)
                SmoothScoreText(
                    value: viewModel.moveCount,
                    font: Theme.fontSubheadline,
                    color: .secondary
                )
                Text("moves")
                    .font(Theme.fontSubheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(30)
        .background(Color.ubCardBackground.opacity(0.95))
        .cornerRadius(Theme.layoutRadius)
        .shadow(color: Theme.Shadows.floating, radius: 20, x: 0, y: 10)
    }
    
    // MARK: - Helpers
    
    private func cellTextColor(cell: ZenSudokuViewModel.Cell) -> Color {
        if cell.hasError { return .ubDanger }
        if cell.isFixed { return .ubTextPrimary }
        return .ubPrimary
    }
    
    private func cellBackground(cell: ZenSudokuViewModel.Cell, isSelected: Bool) -> Color {
        if isSelected { return Color.ubPrimary.opacity(0.15) }
        if cell.hasError { return Color.ubDanger.opacity(0.08) }
        return Color.ubSurface
    }
    
    private func boxBorder(row: Int, col: Int) -> some View {
        let right = col == 1 ? Color.ubPrimary.opacity(0.4) : Color.clear
        let bottom = row == 1 ? Color.ubPrimary.opacity(0.4) : Color.clear
        
        return ZStack {
            HStack {
                Spacer()
                Rectangle().fill(right).frame(width: 2)
            }
            VStack {
                Spacer()
                Rectangle().fill(bottom).frame(height: 2)
            }
        }
    }
}
