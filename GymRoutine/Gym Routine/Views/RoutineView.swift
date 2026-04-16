import SwiftUI

struct RoutinesView: View {
    @State private var routines: [Routine] = []
    @State private var showAddModal = false
    @State private var selectedRoutine: Routine?

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.black, Color(red: 20/255, green: 20/255, blue: 25/255)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Button(action: { showAddModal = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Añadir Rutina")
                            .bold()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(colors: [Color(red: 100/255, green: 50/255, blue: 50/255),
                                                Color(red: 160/255, green: 80/255, blue: 80/255)],
                                       startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(16)
                    .shadow(color: Color.red.opacity(0.5), radius: 8, x: 0, y: 4)
                }
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
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(routines) { routine in
                                RoutineCard(routine: routine)
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
        
        // MODAL PARA AÑADIR
        .sheet(isPresented: $showAddModal) {
            RoutineInsertModal { name, description in
                if let id = CRUDOperations.insertRoutine(name: name, description: description) {
                    let newRoutine = Routine(id: id, name: name, description: description)
                    routines.append(newRoutine)
                }
            }
        }
        
        // MODAL PARA EDITAR Y AÑADIR EJERCICIOS
        .sheet(item: $selectedRoutine) { routine in
            RoutineUpdateModal(routine: routine, onUpdate: { updated in
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
