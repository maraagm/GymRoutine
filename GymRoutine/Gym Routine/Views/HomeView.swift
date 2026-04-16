import SwiftUI

struct HomeView: View {
    private enum WeekDay: String, CaseIterable, Identifiable {
        case monday = "Lunes"
        case tuesday = "Martes"
        case wednesday = "Miércoles"
        case thursday = "Jueves"
        case friday = "Viernes"
        case saturday = "Sábado"
        case sunday = "Domingo"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .monday: return "figure.strengthtraining.traditional"
            case .tuesday: return "flame.fill"
            case .wednesday: return "bolt.fill"
            case .thursday: return "heart.fill"
            case .friday: return "trophy.fill"
            case .saturday: return "sun.max.fill"
            case .sunday: return "leaf.fill"
            }
        }
    }

    @State private var routines: [Routine] = []

    @AppStorage("schedule_monday") private var mondayRoutineId: Int = -1
    @AppStorage("schedule_tuesday") private var tuesdayRoutineId: Int = -1
    @AppStorage("schedule_wednesday") private var wednesdayRoutineId: Int = -1
    @AppStorage("schedule_thursday") private var thursdayRoutineId: Int = -1
    @AppStorage("schedule_friday") private var fridayRoutineId: Int = -1
    @AppStorage("schedule_saturday") private var saturdayRoutineId: Int = -1
    @AppStorage("schedule_sunday") private var sundayRoutineId: Int = -1

    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        Text("GYM ROUTINE")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)

                        Image("rat")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 170, height: 170)
                            .shadow(color: Color.red.opacity(0.4), radius: 15)

                        weeklyScheduleSection

                        homeActionCard(
                            title: "Gestión de Ejercicios",
                            subtitle: "Crea y edita tus ejercicios",
                            icon: "dumbbell.fill",
                            destination: ExercisesView()
                        )

                        homeActionCard(
                            title: "Gestión de Rutinas",
                            subtitle: "Configura tus rutinas completas",
                            icon: "list.clipboard.fill",
                            destination: RoutinesView()
                        )

                        Spacer(minLength: 20)
                    }
                    
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
                .navigationBarHidden(true)
            }
            .onAppear {
                routines = CRUDOperations.getAllRoutines()
            }
        }
    }

    private var weeklyScheduleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(Color(red: 220/255, green: 80/255, blue: 80/255))
                Text("Horario semanal")
                    .font(.title2.bold())
                    .foregroundColor(.white)
            }

            if routines.isEmpty {
                Text("Crea una rutina para poder asignarla a un día.")
                    .foregroundColor(.gray)
                    .font(.subheadline)
            } else {
                ForEach(WeekDay.allCases) { day in
                    HStack(spacing: 10) {
                        Image(systemName: day.icon)
                            .foregroundColor(Color(red: 220/255, green: 80/255, blue: 80/255))
                            .frame(width: 20)

                        Text(day.rawValue)
                            .foregroundColor(.white)
                            .font(.headline)

                        Spacer()

                        Menu {
                            Button("Sin rutina") {
                                setRoutineId(-1, for: day)
                            }

                            ForEach(routines) { routine in
                                Button(routine.name) {
                                    setRoutineId(Int(routine.id), for: day)
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text(routineName(for: day))
                                    .lineLimit(1)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.14))
                            .clipShape(Capsule())
                        }

                        if let assignedRoutine = routine(for: day) {
                            NavigationLink(destination: RoutinesReadOnlyView(routine: assignedRoutine)) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(Color(red: 220/255, green: 80/255, blue: 80/255))
                            }
                        }
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
    }

    private func routine(for day: WeekDay) -> Routine? {
        let savedId = Int64(routineId(for: day))
        guard savedId > 0 else { return nil }
        return routines.first(where: { $0.id == savedId })
    }

    private func routineName(for day: WeekDay) -> String {
        if let routine = routine(for: day) {
            return routine.name
        }
        return "Asignar rutina"
    }

    private func routineId(for day: WeekDay) -> Int {
        switch day {
        case .monday: return mondayRoutineId
        case .tuesday: return tuesdayRoutineId
        case .wednesday: return wednesdayRoutineId
        case .thursday: return thursdayRoutineId
        case .friday: return fridayRoutineId
        case .saturday: return saturdayRoutineId
        case .sunday: return sundayRoutineId
        }
    }

    private func setRoutineId(_ value: Int, for day: WeekDay) {
        switch day {
        case .monday: mondayRoutineId = value
        case .tuesday: tuesdayRoutineId = value
        case .wednesday: wednesdayRoutineId = value
        case .thursday: thursdayRoutineId = value
        case .friday: fridayRoutineId = value
        case .saturday: saturdayRoutineId = value
        case .sunday: sundayRoutineId = value
        }
    }

    private func homeActionCard<Destination: View>(
        title: String,
        subtitle: String,
        icon: String,
        destination: Destination
    ) -> some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 14) {
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
                        .frame(width: 48, height: 48)

                    Image(systemName: icon)
                        .foregroundColor(.white)
                        .font(.title3)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.bold())
                        .foregroundColor(.white)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Spacer()

                Image(systemName: "chevron.right.circle.fill")
                    .foregroundColor(Color(red: 220/255, green: 80/255, blue: 80/255))
                    .font(.title3)
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
            .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 3)
        }
    }
}


