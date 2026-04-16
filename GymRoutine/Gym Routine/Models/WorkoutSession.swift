import Foundation

struct WorkoutSession: Identifiable {
    var id: Int64
    var routineId: Int64
    var routineName: String
    var startedAt: String
    var endedAt: String?
}

struct WorkoutSessionExercise: Identifiable {
    var id: Int64
    var workoutSessionId: Int64
    var exerciseId: Int64
    var exerciseName: String
    var weight: String
    var series: String
    var isCompleted: Bool
    var completedAt: String?
}
