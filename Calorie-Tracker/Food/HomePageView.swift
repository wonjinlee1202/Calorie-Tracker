import SwiftUI
import Combine
import FirebaseAnalytics
import FirebaseAnalyticsSwift
import Firebase

@MainActor
class FoodViewModel: ObservableObject {
    @Published var list = [FoodItem]()
    private var defaults = UserDefaults.standard
    let db = Firestore.firestore()
    let dispatchGroup = DispatchGroup()
    
    @AppStorage("totalCals") var totalCals: Int = 0
    
    init() {
        self.defaults.set(0, forKey: "totalCals")
        self.defaults.synchronize() // Synchronize UserDefaults
    }
    
    func update() {
        if (self.defaults.object(forKey: "userID") is String) && (Auth.auth().currentUser!.uid == self.defaults.object(forKey: "userID") as! String) {
            print("User ID stored")
        }
        else {
            // No stored user found; store the current user
            print("Store new user ID")
            let db = Firestore.firestore()
            if let user = Auth.auth().currentUser {
                print(user.uid)
                self.dispatchGroup.enter()
                db.collection("users").whereField("userId", isEqualTo: user.uid).getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error querying documents: \(error)")
                    }
                    else {
                        print("FOUND")
                        for document in querySnapshot!.documents {
                            let userid = document.documentID
                            print("Stored User with ID: \(userid)")
                            self.defaults.set(userid, forKey: "userID")
                            self.defaults.synchronize() // Synchronize UserDefaults
                        }
                    }
                    self.dispatchGroup.leave()
                }
                print("HERE")
            }
        }
        
        let currentDate = Date()
        
        if let date = self.defaults.object(forKey: "date") as? Date {
            // A stored date exists; compare it with the current date
            print("Date stored")
            let calendar = Calendar.current
            if !calendar.isDate(date, inSameDayAs: currentDate) {
                // The stored date is not the same as the current date
                print("Stored date is different")
                if let storedUser = self.defaults.object(forKey: "userID") as? String {
                    let db = Firestore.firestore()
                    let collection = db.collection("users").document(storedUser).collection("days")
                    
                    // Create timestamps representing the start and end of the search day
                    let startOfDay = Calendar.current.startOfDay(for: currentDate)
                    let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
                    self.dispatchGroup.enter()
                    collection
                        .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
                        .whereField("date", isLessThan: Timestamp(date: endOfDay))
                        .getDocuments { (querySnapshot, error) in
                            if error != nil || querySnapshot!.documents.isEmpty {
                                print("Creating new document for today")
                                let newday: [String: Any] = [
                                    "date": Calendar.current.startOfDay(for: currentDate),
                                    "totalCals": 0
                                ]
                                let parentDocument = db.collection("users").document(self.defaults.object(forKey: "userID") as! String)
                                    .collection("days").addDocument(data: newday)
                                let foods = parentDocument.collection("foods")
                                self.defaults.set(parentDocument.documentID, forKey: "date")
                                self.defaults.synchronize() // Synchronize UserDefaults
                            }
                            else {
                                for doc in querySnapshot!.documents {
                                    print("Found document with ID: \(doc.documentID)")
                                    // Access the document's data using document.data()
                                    // Set the data to update
                                    
                                    // Update the stored date to the current date
                                    self.defaults.set(doc.documentID, forKey: "date")
                                    self.defaults.synchronize() // Synchronize UserDefaults
                                }
                            }
                            self.dispatchGroup.leave()
                        }
                }
            }
        } else {
            // No stored date found; store the current date
            print("No stored date")
            print(self.defaults.object(forKey: "userID") as! String)
            if let storedUser = self.defaults.object(forKey: "userID") as? String {
                let db = Firestore.firestore()
                let collection = db.collection("users").document(storedUser).collection("days")
                
                // Create timestamps representing the start and end of the search day
                let startOfDay = Calendar.current.startOfDay(for: currentDate)
                let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
                print("A")
                self.dispatchGroup.enter()
                print("B")
                collection
                    .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
                    .whereField("date", isLessThan: Timestamp(date: endOfDay))
                    .getDocuments { (querySnapshot, error) in
                        if error != nil || querySnapshot!.documents.isEmpty {
                            print("Creating new document for today")
                            let newday: [String: Any] = [
                                "date": Calendar.current.startOfDay(for: currentDate),
                                "totalCals": 0
                            ]
                            let parentDocument = db.collection("users").document(self.defaults.object(forKey: "userID") as! String)
                                .collection("days").addDocument(data: newday)
                            let foods = parentDocument.collection("foods")
                            self.defaults.set(parentDocument.documentID, forKey: "date")
                            self.defaults.synchronize() // Synchronize UserDefaults
                        }
                        else {
                            print("C")
                            for doc in querySnapshot!.documents {
                                print("Found document with ID: \(doc.documentID)")
                                // Access the document's data using document.data()
                                // Set the data to update
                                
                                // Update the stored date to the current date
                                self.defaults.set(doc.documentID, forKey: "date")
                                self.defaults.synchronize() // Synchronize UserDefaults
                            }
                        }
                        self.dispatchGroup.leave()
                    }
            }
        }
    }
    
    func updateData(foodToUpdate: FoodItem, newname: String, newcalories: String) {
        if let index = list.firstIndex(where: { $0.id == foodToUpdate.id }) {
            // Modify the fields of the document in your list
            self.defaults.set(self.defaults.object(forKey: "totalCals") as! Int - list[index].calories + Int(newcalories)!, forKey: "totalCals")
            self.defaults.synchronize() // Synchronize UserDefaults
            
            list[index].name = newname
            list[index].calories = Int(newcalories)!
        }
        
        let newData: [String: Any] = [
            "name": newname,
            "calories": newcalories
        ]
        
        // Set the data to update
        db.collection("users").document(defaults.object(forKey: "userID") as! String).collection("days").document(defaults.object(forKey: "date") as! String).collection("foods").document(foodToUpdate.id).updateData(newData) { error in
            // Check for errors
            if error == nil {
                // Get the new data
            }
                            
        }
    }
    
    func deleteData(foodToDelete: FoodItem) {
        self.defaults.set(self.defaults.object(forKey: "totalCals") as! Int - foodToDelete.calories, forKey: "totalCals")
        self.defaults.synchronize() // Synchronize UserDefaults
        db.collection("users").document(defaults.object(forKey: "userID") as! String).collection("days").document(defaults.object(forKey: "date") as! String).collection("foods").document(foodToDelete.id).delete { error in
            // Check for errors
            if error == nil {
                // No errors
                // Update the UI from the main thread
                DispatchQueue.main.async {
                    // Remove the todo that was just deleted
                    self.list.removeAll { todo in
                        // Check for the todo to remove
                        return todo.id == foodToDelete.id
                    }
                }
            }
        }
    }
    
    func addData(name: String, calories: Int) {
        var docref: DocumentReference?

        docref = db.collection("users").document(defaults.object(forKey: "userID") as! String)
            .collection("days").document(defaults.object(forKey: "date") as! String)
            .collection("foods").addDocument(data: ["name": name, "calories": calories]) { error in
                // Check for errors
                if let error = error {
                    print("Error adding document: \(error)")
                } else {
                    // Get the new data
                    if let documentID = docref?.documentID {
                        self.list.append(FoodItem(id: documentID, name: name, calories: calories))
                    }
                    self.defaults.set(self.defaults.object(forKey: "totalCals") as! Int + calories, forKey: "totalCals")
                    self.defaults.synchronize() // Synchronize UserDefaults
                }
            }
    }
    
    func getData() {
        self.update()
        
        self.dispatchGroup.notify(queue: .main) {
            self.db.collection("users").document(self.defaults.object(forKey: "userID") as! String).collection("days").document(self.defaults.object(forKey: "date") as! String).collection("foods").getDocuments { snapshot, error in
                    // Check for errors
                    if error == nil {
                        // No errors
                        if let snapshot = snapshot {
                            // Update the list property in the main thread
                            DispatchQueue.main.async {
                                // Get all the documents and create Todos
                                self.list = snapshot.documents.map { d in
                                    // Create a Todo item for each document returned
                                    return FoodItem(id: d.documentID,
                                        name: d["name"] as? String ?? "",
                                        calories: d["calories"] as? Int ?? 0)
                                }
                            }
                        }
                    }
                    else {
                        // Handle the error
                    }
            }
            self.db.collection("users").document(self.defaults.object(forKey: "userID") as! String).collection("days").document(self.defaults.object(forKey: "date") as! String).getDocument { (document, error) in
                if let error = error {
                    print("Error getting document: \(error)")
                } else if let document = document, document.exists {
                    if let fieldValue = document.data()?["totalCals"] as? Int {
                        // Use the retrieved field value
                        self.defaults.set(fieldValue, forKey: "totalCals")
                        self.defaults.synchronize() // Synchronize UserDefaults
                    }
                }
            }
        }
    }
}

struct FoodList: View {
    @StateObject var model = FoodViewModel()
    private var defaults = UserDefaults.standard
    
    @State var name = ""
    @State var calories = ""
    @State var newname = ""
    @State var newcalories = ""
    @State var curItem = FoodItem(id: "", name: "", calories: 0)
    
    @State private var presentingFoodSearch = false
    @State private var showingAlert = false
    @AppStorage("totalCals") var totalCals: Int = 0
    var body: some View {
        VStack {
            HStack {
                Text("\(model.list.reduce(0) { $0 + $1.calories }) Calories")
                    .font(.largeTitle.bold())
                Spacer()
                Button(action: {
                    presentingFoodSearch.toggle()
                }) {
                    Image(systemName: "magnifyingglass")
                }
            }
            .sheet(isPresented: $presentingFoodSearch, onDismiss: {
                model.getData()
            }) {
              NavigationView {
                FoodSearchView()
                  .environmentObject(FoodSearchViewModel())
              }
            }
            .padding([.leading, .trailing], 16)
            List (model.list) { item in
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.name)
                        Text("\(item.calories) cals")
                    }
                    Spacer()
                    // Update button
                    Button(action: {
                        // Delete todo
                        showingAlert.toggle()
                        curItem = item
                    }, label: {
                        Image(systemName: "pencil")
                    })
                    .alert("Edit Food Entry:", isPresented: $showingAlert) {
                                TextField("Name", text: $newname)
                                TextField("Calories", text: $newcalories)
                        Button("OK", action: {model.updateData(foodToUpdate: curItem, newname: newname, newcalories: newcalories); newname = ""; newcalories = ""})
                            } message: {
                                Text("\(curItem.name), \(curItem.calories)")
                            }
                    .buttonStyle(BorderlessButtonStyle())
                    // Delete button
                    Button(action: {
                        // Delete todo
                        model.deleteData(foodToDelete: item)
                    }, label: {
                        Image(systemName: "minus.circle")
                    })
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
            VStack(spacing: 5) {
                TextField("Name", text: $name)
                    .frame(width: 360)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Calories", text: $calories)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    // Call add data
                    model.addData(name: name, calories: Int(calories) ?? 0)
                    // Clear the text fields
                    name = ""
                    calories = ""
                }, label: {
                    Text("Add Custom Food Item")
                })
            }
            Divider()
                .padding()
        }
    .task {
        model.getData()
    }
    }
}

struct FavouriteNumberView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      FoodList()
    }
  }
}
