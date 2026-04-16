import SwiftUI

struct ExercisesView: View {
    @State private var showAddModal = false
    @State private var showUpdateModal = false
    @State private var searchText = ""
    @State private var exercises: [Exercise] = []
    @State private var selectedExercise: Exercise?

    var filteredExercises: [Exercise] {
        if searchText.isEmpty { return exercises }
        return exercises.filter { $0.name.lowercased().contains(searchText.lowercased()) }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 20/255, green: 20/255, blue: 25/255),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                // Botón añadir
                Button(action: { showAddModal = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        Text("Añadir Ejercicio")
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
                
                // Barra de búsqueda
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Buscar ejercicio...", text: $searchText)
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Tabla de ejercicios
                if filteredExercises.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        Text(searchText.isEmpty ? "No hay ejercicios" : "No se encontraron resultados")
                            .font(.title3)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(filteredExercises) { exercise in
                                ExerciseCard(exercise: exercise)
                                    .onTapGesture {
                                        selectedExercise = exercise
                                        showUpdateModal = true
                                    }
                            }
                        }
                        .padding()
                    }
                }
                
                Spacer()
            }
            .padding(.top)
        }
        .navigationTitle("Ejercicios")
        .navigationBarTitleDisplayMode(.large)
        
        .onAppear {
            loadExercises()
        }
        
        // ADD MODAL
        .sheet(isPresented: $showAddModal) {
            ExercisesInsertModal { name, description in
                if let id = CRUDOperations.insertExercise(name: name, description: description) {
                    let newExercise = Exercise(id: id, name: name, description: description)
                    exercises.append(newExercise)
                    print("✅ Ejercicio añadido: ID=\(id), Nombre='\(name)', Desc='\(description)'")
                }
            }
        }
        
        // UPDATE MODAL
        .sheet(item: $selectedExercise) { exercise in
            ExercisesUpdateModal(
                exercise: exercise,
                onUpdate: { updated in
                    if CRUDOperations.updateExercise(exercise: updated) {
                        if let idx = exercises.firstIndex(where: { $0.id == updated.id }) {
                            exercises[idx] = updated
                        }
                        print("✅ Ejercicio actualizado: \(updated.name)")
                    }
                },
                onDelete: { exerciseToDelete in
                    if CRUDOperations.deleteExercise(exercise: exerciseToDelete) {
                        exercises.removeAll { $0.id == exerciseToDelete.id }
                        print("✅ Ejercicio eliminado: \(exerciseToDelete.name)")
                    }
                }
            )
        }
    }
    
    private func loadExercises() {
        exercises = CRUDOperations.getAllExercises()
        print("📋 Ejercicios cargados: \(exercises.count)")
        
        // Debug: mostrar los datos de cada ejercicio
        for (index, ex) in exercises.enumerated() {
            print("  [\(index)] ID=\(ex.id), Name='\(ex.name)', Desc='\(ex.description)'")
        }
    }
}

// Componente de tarjeta de ejercicio
struct ExerciseCard: View {
    let exercise: Exercise
    
    var body: some View {
        HStack(spacing: 15) {
            // Icono
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 180/255, green: 50/255, blue: 50/255),
                                Color(red: 220/255, green: 80/255, blue: 80/255)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: "dumbbell.fill")
                    .font(.title3)
                    .foregroundColor(.white)
            }
            
            // Contenido
            VStack(alignment: .leading, spacing: 5) {
                Text(exercise.name.isEmpty ? "Sin nombre" : exercise.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(exercise.description.isEmpty ? "Sin descripción" : exercise.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Indicador
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
    }
}
