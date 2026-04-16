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





