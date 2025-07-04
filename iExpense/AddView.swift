//
//  AddView.swift
//  iExpense
//
//  Created by Filipe Fernandes on 01/07/25.
//

import SwiftUI

struct AddView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = "New item name"
    @State private var type: String = "Personal"
    @State private var amount: Double = 0.0
    
    var expenses: Expenses
    
    let types: [String] = ["Business", "Personal"]
    
    let currencyFormat = Locale.current.currency?.identifier ?? "USD"
    
    var body: some View {
        Form {
            Picker("Type", selection: $type) {
                ForEach(types, id: \.self) {
                    Text($0)
                }
            }
            
            TextField("Amount", value: $amount, format: .currency(code: currencyFormat))
                .keyboardType(.decimalPad)
        }
        .navigationTitle($name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem {
                Button("Save") {
                    let item = ExpenseItem(name: name, type: type, amount: amount)
                    expenses.items.append(item)
                    
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AddView(expenses: Expenses())
    }
}
