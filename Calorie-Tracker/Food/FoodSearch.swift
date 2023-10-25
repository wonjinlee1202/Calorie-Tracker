import SwiftUI
import Combine
import FirebaseAnalytics
import FirebaseAnalyticsSwift
import Firebase

class FoodSearchViewModel: ObservableObject {
    @Published var searchResults = [FoodItem]()
    private var defaults = UserDefaults.standard
    let db = Firestore.firestore()
    
    func search(query: String) {
        let baseURL = "https://api.edamam.com/api/food-database/v2/parser" // Replace with your API endpoint
        var urlComponents = URLComponents(string: baseURL)
        urlComponents?.queryItems = [
            URLQueryItem(name: "app_id", value: "01ed6b06"),
            URLQueryItem(name: "app_key", value: "ef04be612e769fe39caaffeac5a6e86a"),
            URLQueryItem(name: "ingr", value: query)
            // Add more query parameters as needed
        ]
        guard let url = urlComponents?.url else {
            print("Invalid URL")
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                // Handle the error
            } else if let data = data {
                do {
                    // Decode the JSON data into a Person instance
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(Response.self, from: data)
                    // Now you have a Person instance with the data from the JSON response
                    //print("Name: \(person.name), Age: \(person.age)")
                    
                    if (response.parsed.count == 0)
                    {
                        self.searchResults = [FoodItem(id: "2", name: response.hints[0].food.label, calories: Int(response.hints[0].food.nutrients.ENERC_KCAL!)), FoodItem(id: "3", name: response.hints[1].food.label, calories: Int(response.hints[1].food.nutrients.ENERC_KCAL!)), FoodItem(id: "4", name: response.hints[2].food.label, calories: Int(response.hints[2].food.nutrients.ENERC_KCAL!)), FoodItem(id: "5", name: response.hints[3].food.label, calories: Int(response.hints[3].food.nutrients.ENERC_KCAL!)), FoodItem(id: "1", name: response.hints[4].food.label, calories: Int(response.hints[4].food.nutrients.ENERC_KCAL!)), FoodItem(id: "6", name: response.hints[5].food.label, calories: Int(response.hints[5].food.nutrients.ENERC_KCAL!)), FoodItem(id: "7", name: response.hints[6].food.label, calories: Int(response.hints[6].food.nutrients.ENERC_KCAL!)), FoodItem(id: "8", name: response.hints[7].food.label, calories: Int(response.hints[7].food.nutrients.ENERC_KCAL!)), FoodItem(id: "9", name: response.hints[8].food.label, calories: Int(response.hints[8].food.nutrients.ENERC_KCAL!)), FoodItem(id: "10", name: response.hints[9].food.label, calories: Int(response.hints[9].food.nutrients.ENERC_KCAL!))]
                    }
                    else {
                        self.searchResults = [FoodItem(id: "1", name: response.parsed[0].food.label, calories: Int(response.parsed[0].food.nutrients.ENERC_KCAL!)), FoodItem(id: "2", name: response.hints[0].food.label, calories: Int(response.hints[0].food.nutrients.ENERC_KCAL!)), FoodItem(id: "3", name: response.hints[1].food.label, calories: Int(response.hints[1].food.nutrients.ENERC_KCAL!)), FoodItem(id: "4", name: response.hints[2].food.label, calories: Int(response.hints[2].food.nutrients.ENERC_KCAL!)), FoodItem(id: "5", name: response.hints[3].food.label, calories: Int(response.hints[3].food.nutrients.ENERC_KCAL!)), FoodItem(id: "6", name: response.hints[4].food.label, calories: Int(response.hints[4].food.nutrients.ENERC_KCAL!)), FoodItem(id: "7", name: response.hints[5].food.label, calories: Int(response.hints[5].food.nutrients.ENERC_KCAL!)), FoodItem(id: "8", name: response.hints[6].food.label, calories: Int(response.hints[6].food.nutrients.ENERC_KCAL!)), FoodItem(id: "9", name: response.hints[7].food.label, calories: Int(response.hints[7].food.nutrients.ENERC_KCAL!))]
                    }
                    
                } catch {
                    print("Error decoding JSON: \(error)")
                    // Handle the decoding error
                }
            }
        }

        // Start the data task
        task.resume()
    }
    
    func addFood(foodToAdd: FoodItem) {
        db.collection("users").document(defaults.object(forKey: "userID") as! String)
            .collection("days").document(defaults.object(forKey: "date") as! String)
            .collection("foods").addDocument(data: ["name": foodToAdd.name, "calories": foodToAdd.calories]) { error in
                // Check for errors
                if let error = error {
                    print("Error adding document: \(error)")
                }
            }
    }
}

struct FoodSearchView: View {
    @StateObject var viewModel = FoodSearchViewModel()
    @Environment(\.dismiss) var dismiss
    private var defaults = UserDefaults.standard
    
    @State var searchQuery = ""

    var body: some View {
        VStack(spacing: 5) {
            TextField("Food Item", text: $searchQuery)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button(action: {
                // Call add data
                viewModel.search(query: searchQuery)
            }, label: {
                Text("Search")
            })
            List (viewModel.searchResults) { item in
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.name)
                        Text("\(item.calories) cals")
                    }
                    Spacer()
                    // Select button
                    Button(action: {
                        // Delete todo
                        viewModel.addFood(foodToAdd: item)
                        self.defaults.set(self.defaults.object(forKey: "totalCals") as! Int + item.calories, forKey: "totalCals")
                        self.defaults.synchronize() // Synchronize UserDefaults
                        dismiss()
                    }, label: {
                        Image(systemName: "plus.circle")
                    })
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
        }
        .navigationTitle("Food Search")
    }
}

struct FoodSearchView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      FoodSearchView()
        .environmentObject(FoodSearchViewModel())
    }
  }
}
