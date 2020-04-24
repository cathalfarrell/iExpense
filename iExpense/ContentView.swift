//
//  ContentView.swift
//  iExpense
//
//  Created by Cathal Farrell on 23/04/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import SwiftUI

/*
 Need to make sure each item is uniquely identifiable
 Identifiable ensures this by requiring an id
 that is always unique - then use this as the id in ForEach
*/

struct ExpenseItem: Identifiable, Codable {
    let id = UUID()
    let name: String
    let type: String
    let amount: Int
}

/*
As we need to share this data between views
while allowing the data to change, we must use a class which
conforms to ObservableObject and publishes changing data with
@Published to any view sharing this data.
*/

class Expenses: ObservableObject {

    /* As Per Tutorial...but didnt work
    @Published var items: [ExpenseItem] {
        didSet {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(items) {
                print("Item encoded: \(encoded.count .byteSwapped)")
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
    */

    @Published var items: [ExpenseItem]

    // MARK: Initialise using stored items on each launch here
    init() {
        if let items = UserDefaults.standard.data(forKey: "Items") {
            print("Items found as data: \(items.count)")
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([ExpenseItem].self, from: items){
                print("Items count: \(decoded.count)")
                self.items = decoded
                return
            }
        }

        //Empty array in case no stored items found
        self.items = []
    }
}

struct ContentView: View {

    @ObservedObject var expenses = Expenses()
    @State private var showingAdExpense = false

    var body: some View {
        NavigationView {
            List {
                /*
                No longer need to specify id as item is Itentifiable now
                ForEach(expenses.items, id: \.id){ item in
                    Text(item.name)
                }
                */
                ForEach(expenses.items){ item in
                    HStack {
                        VStack(alignment: .leading){
                            Text(item.name).font(.headline)
                            Text(item.type)
                        }

                        Spacer()

                        Text("€\(item.amount)")
                    }
                }
                .onDelete(perform: removeItems)

            }
            .navigationBarTitle("iExpense")
            .navigationBarItems(trailing:
                    Button(action: {
                        self.showingAdExpense = true
                    }) {
                        Image(systemName: "plus")
                        Text("Add expense")
                    }
            )
            .sheet(isPresented: $showingAdExpense) {
                //show AdView here - and share expenses object
                AddView(expenses: self.expenses)
            }
        }
    }

    // MARK: - To remove items from a ForEach List
    func removeItems(at offsets: IndexSet) {
        expenses.items.remove(atOffsets: offsets)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
