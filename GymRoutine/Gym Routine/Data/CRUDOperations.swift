import Foundation
import SQLite3

class CRUDOperations {

    // INSERTS
    @discardableResult
    static func insertExercise(name: String, description: String) -> Int64? {
        let query = "INSERT INTO Exercises (name, description) VALUES (?,?);"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(DatabaseManager.shared.db, query, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparing INSERT")
            return nil
        }

        sqlite3_bind_text(statement, 1, (name as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 2, (description as NSString).utf8String, -1, nil)

        if sqlite3_step(statement) != SQLITE_DONE {
            print("❌ Error executing INSERT")
            sqlite3_finalize(statement)
            return nil
        }

        let lastId = sqlite3_last_insert_rowid(DatabaseManager.shared.db)
        sqlite3_finalize(statement)
        print("✅ INSERT doned - ID: \(lastId), Name: '\(name)', Description: '\(description)'")
        return lastId
    }
    
    @discardableResult
    static func insertRoutine(name: String, description: String) -> Int64? {
        let query = "INSERT INTO Routines(name, description) VALUES (?,?);"
        var statement: OpaquePointer?
        
        guard sqlite3_prepare_v2(DatabaseManager.shared.db, query, -1, &statement, nil) == SQLITE_OK else { return nil }
        
        sqlite3_bind_text(statement, 1, (name as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 2, (description as NSString).utf8String, -1, nil)
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            sqlite3_finalize(statement)
            return nil
        }
        
        let lastId = sqlite3_last_insert_rowid(DatabaseManager.shared.db)
        sqlite3_finalize(statement)
        return lastId
    }



    // DELETE
    static func deleteExercise(exercise: Exercise) -> Bool {
        let query = "DELETE FROM Exercises WHERE id = ?;"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(DatabaseManager.shared.db, query, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparing DELETE")
            return false
        }

        sqlite3_bind_int64(statement, 1, exercise.id)

        let success = sqlite3_step(statement) == SQLITE_DONE
        if success {
            print("✅ Exercise deleted - ID: \(exercise.id)")
        } else {
            print("❌ Error deleting exercise")
        }

        sqlite3_finalize(statement)
        return success
    }
    
    static func deleteRoutine(routine: Routine) -> Bool {
        let query = "DELETE FROM Routines WHERE id = ?;"
        var statement: OpaquePointer?
        
        guard sqlite3_prepare_v2(DatabaseManager.shared.db, query, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparing DELETE")
            return false
        }
        
        sqlite3_bind_int64(statement, 1, routine.id)
        
        let success = sqlite3_step(statement) == SQLITE_DONE
        if success {
            print("✅ Routine deleted - ID: \(routine.id)")
        } else {
            print("❌ Error deleting routine")
        }
        
        sqlite3_finalize(statement)
        return success
    }


    // UPDATE
    static func updateExercise(exercise: Exercise) -> Bool {
        let query = "UPDATE Exercises SET name = ?, description = ? WHERE id = ?;"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(DatabaseManager.shared.db, query, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparing UPDATE")
            return false
        }

        sqlite3_bind_text(statement, 1, (exercise.name as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 2, (exercise.description as NSString).utf8String, -1, nil)
        sqlite3_bind_int64(statement, 3, exercise.id)

        let success = sqlite3_step(statement) == SQLITE_DONE
        if success {
            print("✅ Exercise updated - ID: \(exercise.id), Name: '\(exercise.name)'")
        } else {
            print("❌ Error updating exercise")
        }

        sqlite3_finalize(statement)
        return success
    }
    
    static func updateRoutine(routine: Routine) -> Bool {
        let query = "UPDATE Routines SET name = ?, description = ? WHERE id = ?;"
        var statement: OpaquePointer?
        
        guard sqlite3_prepare_v2(DatabaseManager.shared.db, query, -1, &statement, nil) == SQLITE_OK else { return false }
        
        sqlite3_bind_text(statement, 1, (routine.name as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 2, (routine.description as NSString).utf8String, -1, nil)
        sqlite3_bind_int64(statement, 3, routine.id)
        
        let success = sqlite3_step(statement) == SQLITE_DONE
        sqlite3_finalize(statement)
        return success
    }

    // SELECT ALL
    static func getAllExercises() -> [Exercise] {
        var list: [Exercise] = []
        let query = "SELECT id, name, description FROM Exercises;"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(DatabaseManager.shared.db, query, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparing SELECT")
            return []
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            let id = sqlite3_column_int64(statement, 0)
            
            // Manejo seguro de strings que pueden ser NULL
            let namePtr = sqlite3_column_text(statement, 1)
            let name = namePtr != nil ? String(cString: namePtr!) : ""
            
            let descPtr = sqlite3_column_text(statement, 2)
            let description = descPtr != nil ? String(cString: descPtr!) : ""

            let exercise = Exercise(id: id, name: name, description: description)
            list.append(exercise)
            
            print("🔍 Read in BD: ID=\(id), Name='\(name)', Description='\(description)'")
        }

        sqlite3_finalize(statement)
        print("📊 Total exercises readed: \(list.count)")
        return list
    }
    
    static func getAllRoutines() -> [Routine] {
        var list: [Routine] = []
        let query = "SELECT id, name, description FROM Routines;"
        var statement: OpaquePointer?
        
        guard sqlite3_prepare_v2(DatabaseManager.shared.db, query, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparing SELECT")
            return []
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            let id = sqlite3_column_int64(statement, 0)
            
            let namePtr = sqlite3_column_text(statement, 1)
            let name = namePtr != nil ? String(cString: namePtr!) : ""
            
            let descPtr = sqlite3_column_text(statement, 2)
            let description = descPtr != nil ? String(cString: descPtr!) : ""

            let routine = Routine(id: id, name: name, description: description)
            list.append(routine)
            
            print("🔍 Read in BD: ID=\(id), Name='\(name)'")
        }
        
        sqlite3_finalize(statement)
        print("📊 Total routines readed: \(list.count)")
        return list
    }
}

class RoutineExerciseCRUD {

    @discardableResult
    static func insertRoutineExercise(_ re: RoutineExercise) -> Int64? {
        let query = "INSERT INTO RoutineExercises (routineId, exerciseId, weight, series) VALUES (?,?,?,?);"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(DatabaseManager.shared.db, query, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparing INSERT RoutineExercise")
            return nil
        }

        sqlite3_bind_int64(statement, 1, re.routineId)
        sqlite3_bind_int64(statement, 2, re.exerciseId)
        let weightStr = String(re.weight)
        sqlite3_bind_text(statement, 3, (weightStr as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 4, (re.series as NSString).utf8String, -1, nil)

        guard sqlite3_step(statement) == SQLITE_DONE else {
            print("❌ Error executing INSERT RoutineExercise")
            sqlite3_finalize(statement)
            return nil
        }

        let lastId = sqlite3_last_insert_rowid(DatabaseManager.shared.db)
        sqlite3_finalize(statement)
        print("✅ RoutineExercise inserted - ID: \(lastId)")
        return lastId
    }

    static func getRoutineExercises(for routineId: Int64) -> [RoutineExercise] {
        var list: [RoutineExercise] = []
        let query = "SELECT id, routineId, exerciseId, weight, series FROM RoutineExercises WHERE routineId = ?;"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(DatabaseManager.shared.db, query, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparing SELECT RoutineExercises")
            return []
        }

        sqlite3_bind_int64(statement, 1, routineId)

        while sqlite3_step(statement) == SQLITE_ROW {
            let id = sqlite3_column_int64(statement, 0)
            let rId = sqlite3_column_int64(statement, 1)
            let exId = sqlite3_column_int64(statement, 2)

            let weightPtr = sqlite3_column_text(statement, 3)
            let weightStr = weightPtr != nil ? String(cString: weightPtr!) : "0"
            let weight = Double(weightStr) ?? 0

            let seriesPtr = sqlite3_column_text(statement, 4)
            let series = seriesPtr != nil ? String(cString: seriesPtr!) : ""

            list.append(RoutineExercise(id: id, routineId: rId, exerciseId: exId, weight: weight, series: series))
        }

        sqlite3_finalize(statement)
        return list
    }

    @discardableResult
    static func deleteRoutineExercise(_ re: RoutineExercise) -> Bool {
        let query = "DELETE FROM RoutineExercises WHERE id = ?;"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(DatabaseManager.shared.db, query, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparing DELETE RoutineExercise")
            return false
        }

        sqlite3_bind_int64(statement, 1, re.id)

        let success = sqlite3_step(statement) == SQLITE_DONE
        sqlite3_finalize(statement)
        if success { print("✅ RoutineExercise deleted - ID: \(re.id)") }
        return success
    }

    @discardableResult
    static func updateRoutineExercise(_ re: RoutineExercise) -> Bool {
        let query = "UPDATE RoutineExercises SET weight = ?, series = ? WHERE id = ?;"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(DatabaseManager.shared.db, query, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparing UPDATE RoutineExercise")
            return false
        }

        let weightStr = String(re.weight)
        sqlite3_bind_text(statement, 1, (weightStr as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 2, (re.series as NSString).utf8String, -1, nil)
        sqlite3_bind_int64(statement, 3, re.id)

        let success = sqlite3_step(statement) == SQLITE_DONE
        sqlite3_finalize(statement)
        if success { print("✅ RoutineExercise updated - ID: \(re.id)") }
        return success
    }
}

class WorkoutSessionCRUD {

    private static func workoutSessionsHasLegacyCheckInAt() -> Bool {
        let query = "PRAGMA table_info(WorkoutSessions);"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(DatabaseManager.shared.db, query, -1, &statement, nil) == SQLITE_OK else {
            return false
        }

        defer { sqlite3_finalize(statement) }

        while sqlite3_step(statement) == SQLITE_ROW {
            if let colPtr = sqlite3_column_text(statement, 1) {
                let col = String(cString: colPtr)
                if col.caseInsensitiveCompare("checkInAt") == .orderedSame {
                    return true
                }
            }
        }

        return false
    }

    @discardableResult
    static func startWorkoutSession(routineId: Int64) -> Int64? {
        let hasLegacyCheckInAt = workoutSessionsHasLegacyCheckInAt()
        let insertSession = hasLegacyCheckInAt
            ? "INSERT INTO WorkoutSessions (routineId, startedAt, checkInAt, endedAt) VALUES (?, ?, ?, NULL);"
            : "INSERT INTO WorkoutSessions (routineId, startedAt, endedAt) VALUES (?, ?, NULL);"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(DatabaseManager.shared.db, insertSession, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparing INSERT WorkoutSession")
            return nil
        }

        let now = ISO8601DateFormatter().string(from: Date())
        sqlite3_bind_int64(statement, 1, routineId)
        sqlite3_bind_text(statement, 2, (now as NSString).utf8String, -1, nil)
        if hasLegacyCheckInAt {
            sqlite3_bind_text(statement, 3, (now as NSString).utf8String, -1, nil)
        }

        guard sqlite3_step(statement) == SQLITE_DONE else {
            print("❌ Error executing INSERT WorkoutSession")
            sqlite3_finalize(statement)
            return nil
        }

        let sessionId = sqlite3_last_insert_rowid(DatabaseManager.shared.db)
        sqlite3_finalize(statement)

        let snapshotSQL = """
            INSERT INTO WorkoutSessionExercises (workoutSessionId, exerciseId, weight, series, isCompleted, completedAt)
            SELECT ?, exerciseId, weight, series, 0, NULL
            FROM RoutineExercises
            WHERE routineId = ?;
            """

        var snapshotStmt: OpaquePointer?
        guard sqlite3_prepare_v2(DatabaseManager.shared.db, snapshotSQL, -1, &snapshotStmt, nil) == SQLITE_OK else {
            print("❌ Error preparing snapshot exercises for WorkoutSession")
            return sessionId
        }

        sqlite3_bind_int64(snapshotStmt, 1, sessionId)
        sqlite3_bind_int64(snapshotStmt, 2, routineId)

        if sqlite3_step(snapshotStmt) != SQLITE_DONE {
            print("❌ Error creating exercise snapshot for WorkoutSession")
        }

        sqlite3_finalize(snapshotStmt)
        print("✅ Workout iniciado - ID: \(sessionId)")
        return sessionId
    }

    @discardableResult
    static func finishWorkoutSession(sessionId: Int64) -> Bool {
        let query = "UPDATE WorkoutSessions SET endedAt = ? WHERE id = ?;"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(DatabaseManager.shared.db, query, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparing finish WorkoutSession")
            return false
        }

        let now = ISO8601DateFormatter().string(from: Date())
        sqlite3_bind_text(statement, 1, (now as NSString).utf8String, -1, nil)
        sqlite3_bind_int64(statement, 2, sessionId)

        let success = sqlite3_step(statement) == SQLITE_DONE
        sqlite3_finalize(statement)
        return success
    }

    static func getActiveWorkoutSession() -> WorkoutSession? {
        let query = """
            SELECT ws.id, ws.routineId, r.name, COALESCE(ws.startedAt, ws.checkInAt, ''), ws.endedAt
            FROM WorkoutSessions ws
            LEFT JOIN Routines r ON ws.routineId = r.id
            WHERE ws.endedAt IS NULL OR ws.endedAt = ''
            ORDER BY COALESCE(ws.startedAt, ws.checkInAt, '') DESC
            LIMIT 1;
            """
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(DatabaseManager.shared.db, query, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparing SELECT active WorkoutSession")
            return nil
        }

        defer { sqlite3_finalize(statement) }

        guard sqlite3_step(statement) == SQLITE_ROW else {
            return nil
        }

        let id = sqlite3_column_int64(statement, 0)
        let routineId = sqlite3_column_int64(statement, 1)
        let routineNamePtr = sqlite3_column_text(statement, 2)
        let routineName = routineNamePtr != nil ? String(cString: routineNamePtr!) : "Rutina"
        let startedAtPtr = sqlite3_column_text(statement, 3)
        let startedAt = startedAtPtr != nil ? String(cString: startedAtPtr!) : ""
        let endedAtPtr = sqlite3_column_text(statement, 4)
        let endedAt = endedAtPtr != nil ? String(cString: endedAtPtr!) : nil

        return WorkoutSession(
            id: id,
            routineId: routineId,
            routineName: routineName,
            startedAt: startedAt,
            endedAt: endedAt
        )
    }

    @discardableResult
    static func setExerciseCompletion(sessionExerciseId: Int64, isCompleted: Bool) -> Bool {
        let query = "UPDATE WorkoutSessionExercises SET isCompleted = ?, completedAt = ? WHERE id = ?;"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(DatabaseManager.shared.db, query, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparing UPDATE workout exercise completion")
            return false
        }

        sqlite3_bind_int(statement, 1, isCompleted ? 1 : 0)

        if isCompleted {
            let now = ISO8601DateFormatter().string(from: Date())
            sqlite3_bind_text(statement, 2, (now as NSString).utf8String, -1, nil)
        } else {
            sqlite3_bind_null(statement, 2)
        }

        sqlite3_bind_int64(statement, 3, sessionExerciseId)

        let success = sqlite3_step(statement) == SQLITE_DONE
        sqlite3_finalize(statement)
        return success
    }

    @discardableResult
    static func checkInWorkout(routineId: Int64) -> Int64? {
        startWorkoutSession(routineId: routineId)
    }

    static func getAllWorkoutSessions() -> [WorkoutSession] {
        var list: [WorkoutSession] = []
        let query = """
            SELECT ws.id, ws.routineId, r.name, COALESCE(ws.startedAt, ws.checkInAt, ''), ws.endedAt
            FROM WorkoutSessions ws
            LEFT JOIN Routines r ON ws.routineId = r.id
            ORDER BY COALESCE(ws.startedAt, ws.checkInAt, '') DESC;
            """
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(DatabaseManager.shared.db, query, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparing SELECT WorkoutSessions")
            return []
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            let id = sqlite3_column_int64(statement, 0)
            let routineId = sqlite3_column_int64(statement, 1)

            let routineNamePtr = sqlite3_column_text(statement, 2)
            let routineName = routineNamePtr != nil ? String(cString: routineNamePtr!) : "Rutina"

            let startedAtPtr = sqlite3_column_text(statement, 3)
            let startedAt = startedAtPtr != nil ? String(cString: startedAtPtr!) : ""

            let endedAtPtr = sqlite3_column_text(statement, 4)
            let endedAt = endedAtPtr != nil ? String(cString: endedAtPtr!) : nil

            list.append(
                WorkoutSession(
                    id: id,
                    routineId: routineId,
                    routineName: routineName,
                    startedAt: startedAt,
                    endedAt: endedAt
                )
            )
        }

        sqlite3_finalize(statement)
        return list
    }

    static func getWorkoutSessionExercises(for sessionId: Int64) -> [WorkoutSessionExercise] {
        var list: [WorkoutSessionExercise] = []
        let query = """
            SELECT wse.id, wse.workoutSessionId, wse.exerciseId, e.name, wse.weight, wse.series, wse.isCompleted, wse.completedAt
            FROM WorkoutSessionExercises wse
            LEFT JOIN Exercises e ON wse.exerciseId = e.id
            WHERE wse.workoutSessionId = ?
            ORDER BY wse.id ASC;
            """
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(DatabaseManager.shared.db, query, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparing SELECT WorkoutSessionExercises")
            return []
        }

        sqlite3_bind_int64(statement, 1, sessionId)

        while sqlite3_step(statement) == SQLITE_ROW {
            let id = sqlite3_column_int64(statement, 0)
            let workoutSessionId = sqlite3_column_int64(statement, 1)
            let exerciseId = sqlite3_column_int64(statement, 2)

            let exerciseNamePtr = sqlite3_column_text(statement, 3)
            let exerciseName = exerciseNamePtr != nil ? String(cString: exerciseNamePtr!) : "Ejercicio"

            let weightPtr = sqlite3_column_text(statement, 4)
            let weight = weightPtr != nil ? String(cString: weightPtr!) : ""

            let seriesPtr = sqlite3_column_text(statement, 5)
            let series = seriesPtr != nil ? String(cString: seriesPtr!) : ""

            let isCompleted = sqlite3_column_int(statement, 6) == 1

            let completedAtPtr = sqlite3_column_text(statement, 7)
            let completedAt = completedAtPtr != nil ? String(cString: completedAtPtr!) : nil

            list.append(
                WorkoutSessionExercise(
                    id: id,
                    workoutSessionId: workoutSessionId,
                    exerciseId: exerciseId,
                    exerciseName: exerciseName,
                    weight: weight,
                    series: series,
                    isCompleted: isCompleted,
                    completedAt: completedAt
                )
            )
        }

        sqlite3_finalize(statement)
        return list
    }

    @discardableResult
    static func deleteWorkoutSession(sessionId: Int64) -> Bool {
        let deleteChildrenSQL = "DELETE FROM WorkoutSessionExercises WHERE workoutSessionId = ?;"
        var childrenStmt: OpaquePointer?

        guard sqlite3_prepare_v2(DatabaseManager.shared.db, deleteChildrenSQL, -1, &childrenStmt, nil) == SQLITE_OK else {
            print("❌ Error preparing DELETE WorkoutSessionExercises")
            return false
        }

        sqlite3_bind_int64(childrenStmt, 1, sessionId)
        let childrenDeleted = sqlite3_step(childrenStmt) == SQLITE_DONE
        sqlite3_finalize(childrenStmt)

        guard childrenDeleted else {
            print("❌ Error deleting WorkoutSessionExercises")
            return false
        }

        let deleteSessionSQL = "DELETE FROM WorkoutSessions WHERE id = ?;"
        var sessionStmt: OpaquePointer?

        guard sqlite3_prepare_v2(DatabaseManager.shared.db, deleteSessionSQL, -1, &sessionStmt, nil) == SQLITE_OK else {
            print("❌ Error preparing DELETE WorkoutSession")
            return false
        }

        sqlite3_bind_int64(sessionStmt, 1, sessionId)
        let sessionDeleted = sqlite3_step(sessionStmt) == SQLITE_DONE
        sqlite3_finalize(sessionStmt)

        if sessionDeleted {
            print("✅ WorkoutSession deleted - ID: \(sessionId)")
        }

        return sessionDeleted
    }
}





