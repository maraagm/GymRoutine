import SwiftUI

struct RoutinesInsertModal: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var description = ""
    
    var onSave: (String, String) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Nueva Rutina")) {
                    TextField("Nombre", text: $name)
                    TextField("Descripción", text: $description)
                }
            }
            .navigationTitle("Añadir Rutina")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        guard !name.isEmpty else { return }
                        onSave(name, description)
                        dismiss()
                    }
                }
            }
        }
    }
}
