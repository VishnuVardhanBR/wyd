import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import UIKit

// MARK: - Goal Model
struct Goal: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var createdAt: Date = Date()
}

// MARK: - GoalsViewModel (User-Specific)
class GoalsViewModel: ObservableObject {
    @Published var goals: [Goal] = []
    
    private var db = Firestore.firestore()
    private var authUser: FirebaseAuth.User
    private var listener: ListenerRegistration?
    
    init(authUser: FirebaseAuth.User) {
        self.authUser = authUser
        fetchGoals()
    }
    
    deinit {
        listener?.remove()
    }
    
    /// Listen to /users/{uid}/goals for the signed-in user
    func fetchGoals() {
        db.collection("users")
            .document(authUser.uid)
            .collection("goals")
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching goals: \(error.localizedDescription)")
                    return
                }
                self.goals = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Goal.self)
                } ?? []
            }
    }
    
    /// Add a new goal to /users/{uid}/goals
    func addGoal(title: String) {
        let newGoal = Goal(title: title, createdAt: Date())
        do {
            try db.collection("users")
                 .document(authUser.uid)
                 .collection("goals")
                 .addDocument(from: newGoal)
        } catch {
            print("Error adding goal: \(error.localizedDescription)")
        }
    }
    
    /// Delete a goal from /users/{uid}/goals
    func deleteGoal(goal: Goal) {
        guard let goalID = goal.id else { return }
        db.collection("users")
            .document(authUser.uid)
            .collection("goals")
            .document(goalID)
            .delete { error in
                if let error = error {
                    print("Error deleting goal: \(error.localizedDescription)")
                }
            }
    }
}

// MARK: - GoalsView
struct GoalsView: View {
    @StateObject private var viewModel: GoalsViewModel
    
    // For presenting the add-goal sheet
    @State private var showAddGoalSheet = false
    // For delete confirmation
    @State private var showDeleteAlert = false
    @State private var goalToDelete: Goal?

    /// Pass in the FirebaseAuth.User from ContentView (where `authViewModel.user` is available)
    init(user: FirebaseAuth.User) {
        _viewModel = StateObject(wrappedValue: GoalsViewModel(authUser: user))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#F3F1EA")
                    .ignoresSafeArea()
                
                if viewModel.goals.isEmpty {
                    // Empty state
                    VStack {
                        Text("Let's get started")
                            .font(.custom("EBGaramond-Italic", size: 24))
                            .foregroundColor(.black)
                        
                        Button(action: {
                            showAddGoalSheet = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.black)
                                .padding(.top, 20)
                        }
                    }
                } else {
                    // Goals list
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Goals")
                                .font(.custom("EBGaramond-Italic", size: 32))
                                .foregroundColor(.black)
                            Spacer()
                            Button(action: {
                                showAddGoalSheet = true
                            }) {
                                Image(systemName: "plus")
                                    .font(.title)
                                    .foregroundColor(.black)
                            }
                        }
                        .padding([.top, .horizontal])
                        
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.goals) { goal in
                                    GoalRowView(goal: goal) {
                                        goalToDelete = goal
                                        showDeleteAlert = true
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Delete Goal"),
                    message: Text("Are you sure you want to delete this goal?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let goal = goalToDelete {
                            viewModel.deleteGoal(goal: goal)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $showAddGoalSheet) {
                AddGoalView { title in
                    viewModel.addGoal(title: title)
                }
            }
        }
    }
}

// MARK: - GoalRowView
struct GoalRowView: View {
    var goal: Goal
    var onDelete: () -> Void
    
    @State private var showDeleteButton = false
    @State private var offset: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .leading) {
            HStack {
                // The delete button
                if showDeleteButton {
                    Button(action: {
                        onDelete()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                    .padding(.leading, 8)
                }
                
                // Navigate to CrumbsView (placeholder)
                NavigationLink(destination: CrumbsView(goal: goal)) {
                    HStack {
                        Text(goal.title)
                            .font(.custom("EBGaramond-Italic", size: 28))
                            .foregroundColor(.black)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                }
            }
            .offset(x: offset)
            .gesture(
                LongPressGesture(minimumDuration: 1.0)
                    .onEnded { _ in
                        withAnimation(.easeInOut) {
                            showDeleteButton = true
                            offset = 30
                        }
                    }
            )
            .onTapGesture {
                // If user taps anywhere on the row, reset
                withAnimation(.easeInOut) {
                    showDeleteButton = false
                    offset = 0
                }
            }
        }
    }
}

// MARK: - AddGoalView
struct AddGoalView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var goalTitle: String = ""
    var onAdd: (String) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter goal title", text: $goalTitle)
                    .font(.custom("EBGaramond-Italic", size: 24))
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                    .padding()
                
                Spacer()
            }
            .navigationBarTitle("New Goal", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Add") {
                    let trimmed = goalTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty {
                        onAdd(trimmed)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
    }
}

// MARK: - CrumbsView (Placeholder)
struct CrumbsView: View {
    var goal: Goal
    
    var body: some View {
        VStack {
            // The back button is handled automatically by NavigationView
            HStack {
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .padding()
                }
                Spacer()
            }
            .background(BlurView(style: .systemMaterial))
            
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Crumbs for \"\(goal.title)\"")
                        .font(.custom("EBGaramond-Italic", size: 24))
                        .padding(.bottom, 8)
                    
                    // Placeholder crumbs
                    ForEach(0..<10) { index in
                        Text("Crumb \(index + 1)")
                            .font(.custom("EBGaramond-Regular", size: 18))
                            .foregroundColor(.black)
                            .padding(.vertical, 4)
                    }
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
        .background(Color(hex: "#F3F1EA").ignoresSafeArea())
    }
}

// MARK: - BlurView (UIKit wrapper for a blur effect)
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

