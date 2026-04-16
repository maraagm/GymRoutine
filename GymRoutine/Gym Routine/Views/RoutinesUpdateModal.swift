import SwiftUI

struct RoutineUpdateModal: View {
    @Environment(\.dismiss) var dismiss
    @State var routine: Routine
    @State private var allExercises: [Exercise] = []
    @State private var selectedExerciseId: Int64?
    @State private var weight = ""
    @State private var series = ""
    @State private var routineExercises: [RoutineExercise] = []
    
    var onUpdate: (Routine) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Editar rutina")) {
                    TextField("Nombre", text: $routine.name)
                    TextField("Descripción", text: $routine.description)
                }
                
                Section(header: Text("Añadir ejercicio a rutina")) {
                    Picker("Ejercicio", selection: $selectedExerciseId) {
                        Text("Selecciona").tag(Int64?.none)
                        ForEach(allExercises) { ex in
                            Text(ex.name).tag(Int64?(ex.id))
                        }
                    }
                    
                    TextField("Peso", text: $weight)
                        .keyboardType(.decimalPad)
                    TextField("Series", text: $series)
                    
                    Button("Añadir") {
                        guard let exId = selectedExerciseId else { return }
                        let re = RoutineExercise(id: 0, routineId: routine.id, exerciseId: exId,
                                                 weight: Double(weight) ?? 0, series: series)
                        RoutineExerciseCRUD.insertRoutineExercise(re)
                        routineExercises.append(re)
                        // limpiar campos
                        selectedExerciseId = nil
                        weight = ""
                        series = ""
                    }
                }
                
                Section(header: Text("Ejercicios añadidos")) {
                    List(routineExercises, id: \.id) { re in
                        if let ex = allExercises.first(where: { $0.id == re.exerciseId }) {
                            HStack {
                                Text(ex.name)
                                Spacer()
                                Text("\(re.weight) kg / \(re.series) series")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Editar Rutina")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        onUpdate(routine)
                        dismiss()
                    }
                }
            }
            .onAppear {
                allExercises = CRUDOperations.getAllExercises()
                routineExercises = RoutineExerciseCRUD.getRoutineExercises(for: routine.id)
            }
        }
    }
}

