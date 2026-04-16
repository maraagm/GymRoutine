import SwiftUI

struct RoutinesReadOnlyView: View {
    let routine: Routine

    @State private var allExercises: [Exercise] = []
    @State private var routineExercises: [RoutineExercise] = []
    
    private let cardGradient = LinearGradient(
        colors: [
            Color(red: 180/255, green: 50/255, blue: 50/255),
            Color(red: 220/255, green: 80/255, blue: 80/255)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color(red: 20/255, green: 20/255, blue: 25/255)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if routineExercises.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "list.bullet.rectangle.portrait")
                        .font(.system(size: 55))
                        .foregroundColor(.gray.opacity(0.6))
                    Text("La rutina no tiene ejercicios")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                .padding()
            } else {
                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(Array(routineExercises.enumerated()), id: \.element.id) { index, routineExercise in
                            exerciseRow(for: routineExercise, index: index)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(routine.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            allExercises = CRUDOperations.getAllExercises()
            routineExercises = RoutineExerciseCRUD.getRoutineExercises(for: routine.id)
        }
    }

    @ViewBuilder
    private func exerciseRow(for routineExercise: RoutineExercise, index: Int) -> some View {
        let exerciseName = allExercises.first(where: { $0.id == routineExercise.exerciseId })?.name ?? "Ejercicio"
        let iconName = iconForExercise(named: exerciseName)

        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(cardGradient)
                        .frame(width: 46, height: 46)

                    Image(systemName: iconName)
                        .font(.title3)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(exerciseName)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("Ejercicio \(index + 1)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()
            }

            HStack(spacing: 10) {
                metricBadge(
                    title: "Peso",
                    value: "\(String(format: "%.1f", routineExercise.weight)) kg",
                    icon: "scalemass.fill"
                )

                metricBadge(
                    title: "Series",
                    value: routineExercise.series,
                    icon: "repeat"
                )
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 3)
    }

    private func metricBadge(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(Color(red: 220/255, green: 80/255, blue: 80/255))

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text(value.isEmpty ? "-" : value)
                    .font(.caption.bold())
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(Color.white.opacity(0.08))
        .clipShape(Capsule())
    }

    private func iconForExercise(named name: String) -> String {
        let lowercased = name.lowercased()

        if lowercased.contains("press") || lowercased.contains("pecho") {
            return "figure.strengthtraining.traditional"
        }
        if lowercased.contains("pierna") || lowercased.contains("squat") || lowercased.contains("sentadilla") {
            return "figure.run"
        }
        if lowercased.contains("espalda") || lowercased.contains("remo") {
            return "figure.rower"
        }
        if lowercased.contains("hombro") {
            return "figure.cooldown"
        }
        if lowercased.contains("cardio") {
            return "heart.fill"
        }

        return "dumbbell.fill"
    }
}
