import SwiftUI
import Combine

struct WorkoutCheckInView: View {
    @State private var routines: [Routine] = []
    @State private var sessions: [WorkoutSession] = []
    @State private var activeSession: WorkoutSession?
    @State private var activeExercises: [WorkoutSessionExercise] = []
    @State private var selectedRoutineId: Int64 = -1
    @State private var selectedSession: WorkoutSession?
    @State private var checkInMessage: String?
    @State private var now = Date()
    @State private var sessionToDelete: WorkoutSession?

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color(red: 20/255, green: 20/255, blue: 25/255)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 18) {
                if activeSession == nil {
                    routineSelectorSection
                } else {
                    activeWorkoutSection
                }

                if let checkInMessage {
                    Text(checkInMessage)
                        .font(.footnote)
                        .foregroundColor(.green)
                        .padding(.horizontal)
                }

                historySection

                Spacer()
            }
            .padding(.top)
        }
        .navigationTitle("Fichaje")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            loadData()
        }
        .onReceive(timer) { _ in
            now = Date()
        }
        .sheet(item: $selectedSession) { session in
            WorkoutSessionDetailView(session: session)
        }
        .alert("Eliminar registro", isPresented: Binding(
            get: { sessionToDelete != nil },
            set: { if !$0 { sessionToDelete = nil } }
        )) {
            Button("Cancelar", role: .cancel) {
                sessionToDelete = nil
            }
            Button("Eliminar", role: .destructive) {
                guard let target = sessionToDelete else { return }

                if WorkoutSessionCRUD.deleteWorkoutSession(sessionId: target.id) {
                    if activeSession?.id == target.id {
                        activeSession = nil
                        activeExercises = []
                    }
                    checkInMessage = "Registro eliminado"
                    loadData()
                } else {
                    checkInMessage = "No se pudo eliminar el registro"
                }

                sessionToDelete = nil
            }
        } message: {
            if let session = sessionToDelete {
                Text("Se eliminará el registro de \(session.routineName). Esta acción no se puede deshacer.")
            } else {
                Text("Esta acción no se puede deshacer.")
            }
        }
    }

    private var routineSelectorSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(Color(red: 220/255, green: 80/255, blue: 80/255))
                Text("Fichar entrenamiento")
                    .font(.headline.bold())
                    .foregroundColor(.white)
                Spacer()
            }

            Picker("Rutina", selection: $selectedRoutineId) {
                Text("Selecciona una rutina").tag(Int64(-1))
                ForEach(routines) { routine in
                    Text(routine.name).tag(routine.id)
                }
            }
            .pickerStyle(.menu)
            .foregroundColor(.white)
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Button {
                startWorkout()
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Registrar entrada")
                        .bold()
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
                .cornerRadius(14)
                .shadow(color: Color.red.opacity(0.45), radius: 8, x: 0, y: 4)
            }
            .disabled(selectedRoutineId <= 0)
            .opacity(selectedRoutineId <= 0 ? 0.6 : 1)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }

    private var activeWorkoutSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "timer")
                    .foregroundColor(Color(red: 220/255, green: 80/255, blue: 80/255))
                Text("Entrenamiento en curso")
                    .font(.headline.bold())
                    .foregroundColor(.white)
                Spacer()
            }

            if let session = activeSession {
                VStack(alignment: .leading, spacing: 6) {
                    Text(session.routineName)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("Inicio: \(formattedDateTime(session.startedAt))")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text("Tiempo: \(elapsedText(from: session.startedAt))")
                        .font(.title3.bold())
                        .foregroundColor(Color(red: 220/255, green: 80/255, blue: 80/255))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if activeExercises.isEmpty {
                    Text("Esta rutina no tiene ejercicios para marcar")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                } else {
                    VStack(spacing: 8) {
                        ForEach(activeExercises) { exercise in
                            Button {
                                toggleExercise(exercise)
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: exercise.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .font(.title3)
                                        .foregroundColor(exercise.isCompleted ? .green : .gray)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(exercise.exerciseName)
                                            .foregroundColor(.white)
                                            .font(.subheadline.bold())

                                        Text("\(exercise.weight.isEmpty ? "-" : exercise.weight) kg · \(exercise.series.isEmpty ? "-" : exercise.series) series")
                                            .foregroundColor(.gray)
                                            .font(.caption)
                                    }
                                    Spacer()
                                }
                                .padding(10)
                                .background(Color.white.opacity(0.08))
                                .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Button {
                    finishWorkout()
                } label: {
                    HStack {
                        Image(systemName: "stop.circle.fill")
                        Text("Finalizar entrenamiento")
                            .bold()
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
                    .cornerRadius(14)
                    .shadow(color: Color.red.opacity(0.45), radius: 8, x: 0, y: 4)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                    .foregroundColor(Color(red: 220/255, green: 80/255, blue: 80/255))
                Text("Historial de entrenamientos")
                    .font(.headline.bold())
                    .foregroundColor(.white)
            }
            .padding(.horizontal)

            if sessions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 44))
                        .foregroundColor(.gray.opacity(0.7))
                    Text("Aún no hay entrenamientos registrados")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 28)
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(sessions) { session in
                            HStack(spacing: 10) {
                                Button {
                                    selectedSession = session
                                } label: {
                                    workoutSessionCard(session)
                                }
                                .buttonStyle(.plain)

                                Button {
                                    sessionToDelete = session
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.headline)
                                        .foregroundColor(.red)
                                        .frame(width: 38, height: 38)
                                        .background(Color.red.opacity(0.12))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Eliminar registro")
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)
                }
            }
        }
    }

    private func workoutSessionCard(_ session: WorkoutSession) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(session.routineName)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }

            HStack(spacing: 8) {
                Image(systemName: "play.circle")
                    .font(.caption)
                Text("Inicio: \(formattedDateTime(session.startedAt))")
                    .font(.caption)
            }
            .foregroundColor(.gray)

            HStack(spacing: 8) {
                Image(systemName: "stop.circle")
                    .font(.caption)
                Text("Fin: \(session.endedAt == nil || session.endedAt?.isEmpty == true ? "En curso" : formattedDateTime(session.endedAt ?? ""))")
                    .font(.caption)
            }
            .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
    }

    private func loadData() {
        routines = CRUDOperations.getAllRoutines()
        sessions = WorkoutSessionCRUD.getAllWorkoutSessions()
        activeSession = WorkoutSessionCRUD.getActiveWorkoutSession()

        if let activeSession {
            activeExercises = WorkoutSessionCRUD.getWorkoutSessionExercises(for: activeSession.id)
        } else {
            activeExercises = []
        }

        if selectedRoutineId <= 0, let firstRoutine = routines.first {
            selectedRoutineId = firstRoutine.id
        }
    }

    private func startWorkout() {
        guard selectedRoutineId > 0 else { return }
        if WorkoutSessionCRUD.startWorkoutSession(routineId: selectedRoutineId) != nil {
            checkInMessage = "Entrenamiento iniciado"
            loadData()
        }
    }

    private func finishWorkout() {
        guard let activeSession else { return }
        if WorkoutSessionCRUD.finishWorkoutSession(sessionId: activeSession.id) {
            checkInMessage = "Entrenamiento finalizado y guardado"
            loadData()
        }
    }

    private func toggleExercise(_ exercise: WorkoutSessionExercise) {
        let newValue = !exercise.isCompleted
        if WorkoutSessionCRUD.setExerciseCompletion(sessionExerciseId: exercise.id, isCompleted: newValue),
           let activeSession {
            activeExercises = WorkoutSessionCRUD.getWorkoutSessionExercises(for: activeSession.id)
        }
    }

    private func formattedDateTime(_ dateString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        let output = DateFormatter()
        output.locale = Locale(identifier: "es_ES")
        output.dateStyle = .medium
        output.timeStyle = .short

        guard let date = isoFormatter.date(from: dateString) else {
            return dateString
        }
        return output.string(from: date)
    }

    private func elapsedText(from startedAt: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        guard let startedDate = isoFormatter.date(from: startedAt) else {
            return "00:00:00"
        }

        let seconds = max(0, Int(now.timeIntervalSince(startedDate)))
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60

        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }
}

private struct WorkoutSessionDetailView: View {
    let session: WorkoutSession
    @Environment(\.dismiss) private var dismiss

    @State private var exercises: [WorkoutSessionExercise] = []

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                if exercises.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "list.bullet.clipboard")
                            .font(.system(size: 44))
                            .foregroundColor(.gray)
                        Text("No hay ejercicios registrados")
                            .foregroundColor(.gray)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(exercises) { exercise in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(exercise.exerciseName)
                                            .foregroundColor(.white)
                                            .font(.headline)
                                        Text("\(exercise.weight.isEmpty ? "-" : exercise.weight) kg · \(exercise.series.isEmpty ? "-" : exercise.series) series")
                                            .foregroundColor(.gray)
                                            .font(.subheadline)

                                        if exercise.isCompleted {
                                            Text("Completado")
                                                .font(.caption)
                                                .foregroundColor(.green)
                                        }
                                    }
                                    Spacer()

                                    Image(systemName: exercise.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(exercise.isCompleted ? .green : .gray)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.08))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                        )
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(session.routineName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Volver", systemImage: "chevron.left")
                    }
                }
            }
            .onAppear {
                exercises = WorkoutSessionCRUD.getWorkoutSessionExercises(for: session.id)
            }
        }
    }
}
