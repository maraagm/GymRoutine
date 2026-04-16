import SwiftUI

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
