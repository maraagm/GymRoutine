import SwiftUI

struct RoutinesUpdateModal: View {
    @Environment(\.dismiss) var dismiss
    @State var routine: Routine
    @State private var allExercises: [Exercise] = []
    @State private var selectedExerciseId: Int64 = -1
    @State private var weight = ""
    @State private var series = ""
    @State private var routineExercises: [RoutineExercise] = []
    @State private var editingRoutineExercise: RoutineExercise?
    @State private var editWeight = ""
    @State private var editSeries = ""
    
    var onUpdate: (Routine) -> Void
    var onDelete: (Routine) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Editar rutina")) {
                    TextField("Nombre", text: $routine.name)
                    TextField("Descripción", text: $routine.description)
                }
                
                Section(header: Text("Añadir ejercicio a rutina")) {
                    Picker("Ejercicio", selection: $selectedExerciseId) {
                        Text("Selecciona").tag(Int64(-1))
                        ForEach(allExercises) { ex in
                            Text(ex.name).tag(ex.id)
                        }
                    }
                    
                    TextField("Peso (kg)", text: $weight)
                        .keyboardType(.decimalPad)
                    TextField("Series", text: $series)
                    
                    Button("Añadir") {
                        guard selectedExerciseId > 0 else { return }
                        let exId = selectedExerciseId
                        let re = RoutineExercise(id: 0, routineId: routine.id, exerciseId: exId,
                                                 weight: Double(weight) ?? 0, series: series)
                        if RoutineExerciseCRUD.insertRoutineExercise(re) != nil {
                            routineExercises = RoutineExerciseCRUD.getRoutineExercises(for: routine.id)
                        }
                        weight = ""
                        series = ""
                    }
                    .disabled(selectedExerciseId <= 0)
                }
                
                Section(header: Text("Ejercicios añadidos")) {
                    ForEach(routineExercises) { re in
                        if let ex = allExercises.first(where: { $0.id == re.exerciseId }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(ex.name)
                                    Text("\(re.weight, specifier: "%.1f") kg · \(re.series) series")
                                        .foregroundColor(.gray)
                                        .font(.subheadline)
                                }
                                Spacer()

                                Button {
                                    editingRoutineExercise = re
                                    editWeight = String(format: "%.1f", re.weight)
                                    editSeries = re.series
                                } label: {
                                    Image(systemName: "pencil.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.title3)
                                }
                                .buttonStyle(.plain)

                                Button {
                                    if RoutineExerciseCRUD.deleteRoutineExercise(re) {
                                        routineExercises.removeAll { $0.id == re.id }
                                    }
                                } label: {
                                    Image(systemName: "trash.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.title3)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        for idx in indexSet {
                            RoutineExerciseCRUD.deleteRoutineExercise(routineExercises[idx])
                        }
                        routineExercises.remove(atOffsets: indexSet)
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        onDelete(routine)
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Eliminar rutina")
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
            .sheet(item: $editingRoutineExercise) { re in
                NavigationView {
                    Form {
                        Section(header: Text("Editar carga")) {
                            TextField("Peso (kg)", text: $editWeight)
                                .keyboardType(.decimalPad)
                            TextField("Series", text: $editSeries)
                        }
                    }
                    .navigationTitle("Editar ejercicio")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancelar") {
                                editingRoutineExercise = nil
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Guardar") {
                                let updated = RoutineExercise(
                                    id: re.id,
                                    routineId: re.routineId,
                                    exerciseId: re.exerciseId,
                                    weight: Double(editWeight) ?? re.weight,
                                    series: editSeries
                                )

                                if RoutineExerciseCRUD.updateRoutineExercise(updated) {
                                    routineExercises = RoutineExerciseCRUD.getRoutineExercises(for: routine.id)
                                    editingRoutineExercise = nil
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

