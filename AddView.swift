//
//  AddView.swift
//  iExpense
//
//  Created by Cathal Farrell on 24/04/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import SwiftUI

struct AddView: View {

    // MARK - to dismiss...
    @Environment(\.presentationMode) var presentationMode

    //Shareable Expense Data
    @ObservedObject var expenses: Expenses

    @State private var showAlert = false
    @State private var name = ""
    @State private var type = "Personal"
    @State private var amount = ""
    static let types = ["Business", "Personal"]

    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                Picker("Type", selection: $type){
                    ForEach(Self.types, id: \.self) {
                        Text($0)
                    }
                }
                TextField("Amount", text: $amount)
                    .keyboardType(.numberPad)

            }
        .navigationBarTitle("Add New Expense")
        .navigationBarItems(trailing:
                    Button("Save") {
                        if let actualAmount = Int(self.amount) {
                            let item = ExpenseItem(name: self.name,
                                                   type: self.type,
                                                   amount: actualAmount)
                            self.expenses.items.append(item)
                            self.saveItems()
                            self.presentationMode.wrappedValue.dismiss()
                        } else {
                            self.showAlert = true
                        }
                    }
            )
        }
        .alert(isPresented: $showAlert){

            let title = "Invalid Amount"
            let message = "You must enter a valid expense amount in euros"

            return Alert(title: Text(title), message: Text(message), dismissButton: .default(Text("OK")))
        }
    }

    fileprivate func saveItems() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self.expenses.items) {
            UserDefaults.standard.set(encoded, forKey: "Items")
        }
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        //Just need to pass in an empty instance for the preview
        let dummyExpenses = Expenses()
        return AddView(expenses: dummyExpenses)
    }
}
