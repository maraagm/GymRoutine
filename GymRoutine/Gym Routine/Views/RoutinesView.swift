import SwiftUI

struct RoutinesView: View {
    @State private var routines: [Routine] = []
    @State private var searchText = ""
    @State private var showAddModal = false
    @State private var selectedRoutine: Routine?

    private var filteredRoutines: [Routine] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return routines
        }

        let query = searchText.lowercased()
        return routines.filter {
            $0.name.lowercased().contains(query) ||
            $0.description.lowercased().contains(query)
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.black, Color(red: 20/255, green: 20/255, blue: 25/255)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                 Button(action: { showAddModal = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        Text("Añadir Rutina")
                            .font(.title3.bold())
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 180/255, green: 50/255, blue: 50/255),
                                Color(red: 220/255, green: 80/255, blue: 80/255)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: Color.red.opacity(0.5), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal)

                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Buscar rutina...", text: $searchText)
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)

                if routines.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "list.bullet")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("No hay rutinas")
                            .font(.title3)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                } else if filteredRoutines.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 52))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("No se encontraron rutinas")
                            .font(.title3)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(filteredRoutines) { routine in
                                RoutinesCard(routine: routine)
                                    .onTapGesture {
                                        selectedRoutine = routine
                                    }
                            }
                        }
                        .padding()
                    }
                }
                Spacer()
            }
        }
        .navigationTitle("Rutinas")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { loadRoutines() }

        .sheet(isPresented: $showAddModal) {
            RoutinesInsertModal { name, description in
                if let id = CRUDOperations.insertRoutine(name: name, description: description) {
                    let newRoutine = Routine(id: id, name: name, description: description)
                    routines.append(newRoutine)
                }
            }
        }

        .sheet(item: $selectedRoutine) { routine in
            RoutinesUpdateModal(routine: routine, onUpdate: { updated in
                if CRUDOperations.updateRoutine(routine: updated) {
                    if let idx = routines.firstIndex(where: { $0.id == updated.id }) {
                        routines[idx] = updated
                    }
                }
            }, onDelete: { routineToDelete in
                if CRUDOperations.deleteRoutine(routine: routineToDelete) {
                    routines.removeAll { $0.id == routineToDelete.id }
                }
            })
        }
    }

    private func loadRoutines() {
        routines = CRUDOperations.getAllRoutines()
    }
}
