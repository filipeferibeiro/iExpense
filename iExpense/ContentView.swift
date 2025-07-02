//
//  ContentView.swift
//  iExpense
//
//  Created by Filipe Fernandes on 01/07/25.
//

import SwiftUI

struct ExpenseItem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let type: String
    let amount: Double
}

@Observable
class Expenses {
    var items = [ExpenseItem]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
    
    init() {
        if let savedItems = UserDefaults.standard.data(forKey: "Items") {
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedItems) {
                self.items = decodedItems
                return
            }
        }
        
        self.items = []
    }
}

struct ContentView: View {
    @State private var expenses = Expenses()
    @State private var showingAddExpense: Bool = false
    @State private var expenseTypeSelected = "Business"
    
    let currencyFormat = Locale.current.currency?.identifier ?? "USD"
    
    let expenseTypes: [String] = ["Business", "Personal"]
    
    var filteredExpenses: [ExpenseItem] {
        if expenseTypeSelected == "Business" {
            return expenses.items.filter({ $0.type == "Business" })
        }
        
        return expenses.items.filter({$0.type != "Business"})
    }
    
    var body: some View {
        NavigationStack {
            Picker("Expense type", selection: $expenseTypeSelected) {
                ForEach(expenseTypes, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            List {
                ForEach(filteredExpenses) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.headline)
                            
                            Text(item.type)
                                .font(.caption)
                        }
                        
                        Spacer()
                        
                        Text(item.amount, format: .currency(code: currencyFormat))
                            .foregroundStyle(expenseStyle(value: item.amount))
                    }
                }
                .onDelete(perform: removeItems)
            }
            .navigationTitle("iExpense")
            .toolbar {
                EditButton()
                Button("Add Expense", systemImage: "plus") {
                    showingAddExpense = true
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddView(expenses: expenses)
            }
        }
    }
    
    func removeItems(at offsets: IndexSet) {
        let expensesToRemove = offsets.map({ filteredExpenses[$0] })
        
        expenses.items.removeAll { expense in
            expensesToRemove.contains(where: { expense.id == $0.id })
        }
    }
    
    func expenseStyle(value: Double) -> Color {
        switch value {
        case 0..<10.0:
            return .blue
        case 10.0..<100.0:
            return .yellow
        default:
            return .red
        }
    }
    
    func filterExpenses(by type: String) -> [ExpenseItem] {
        if expenseTypeSelected == "Business" {
            return expenses.items.filter({ $0.type == "Business" })
        }
        
        return expenses.items.filter({ $0.type != "Business" })
    }
}

#Preview {
    ContentView()
}
