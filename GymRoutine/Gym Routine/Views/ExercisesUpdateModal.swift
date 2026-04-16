import SwiftUI

struct ExercisesUpdateModal: View {
    @Environment(\.dismiss) var dismiss
    
    @State var exercise: Exercise
    
    var onUpdate: (Exercise) -> Void
    var onDelete: (Exercise) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Editar ejercicio")) {
                    TextField("Nombre", text: $exercise.name)
                    TextField("Descripción", text: $exercise.description)
                }

                Section {
                    Button(role: .destructive) {
                        onDelete(exercise)
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Eliminar ejercicio")
                        }
                    }
                }
            }
            .navigationTitle("Editar")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        onUpdate(exercise)
                        dismiss()
                    }
                }
            }
        }
    }
}
