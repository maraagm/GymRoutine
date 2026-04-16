import Foundation
import SQLite3

final class DatabaseManager {
    static let shared = DatabaseManager()
    private(set) var db: OpaquePointer?
    
    private init(){
        openDatabase()
        createTables()
    }
    
    deinit {
        if db != nil {
            sqlite3_close(db)
        }
    }
    
    private func openDatabase(){
        do {
            let fileURL = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                    .appendingPathComponent("AppListApp.sqlite")
                
            if sqlite3_open(fileURL.path, &db) != SQLITE_OK{
                let err = String(cString: sqlite3_errmsg(db))
                    print("Unable to open database. Error: \(err)")
            } else {
                print("Database opened at \(fileURL.path)")
            }
        }catch{
            print("FileManager error: \(error.localizedDescription)")
        }
    }
            
    private func createTables(){
        let createExercises = """
            CREATE TABLE IF NOT EXISTS Exercises(
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                description TEXT);
            """
        
        let createRoutines = """
            CREATE TABLE IF NOT EXISTS Routines(
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                description TEXT);
            """
                
        let createRoutineExercises = """
            CREATE TABLE IF NOT EXISTS RoutineExercises(
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                routineId INTEGER NOT NULL,
                exerciseId INTEGER NOT NULL,
                weight TEXT,
                series TEXT,
                FOREIGN KEY(routineId) REFERENCES Routines(id) ON DELETE CASCADE,
                FOREIGN KEY(exerciseId) REFERENCES Exercises(id) ON DELETE CASCADE
                );
            """

        let createWorkoutSessions = """
            CREATE TABLE IF NOT EXISTS WorkoutSessions(
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                routineId INTEGER NOT NULL,
                startedAt TEXT,
                endedAt TEXT,
                FOREIGN KEY(routineId) REFERENCES Routines(id) ON DELETE CASCADE
                );
            """

        let createWorkoutSessionExercises = """
            CREATE TABLE IF NOT EXISTS WorkoutSessionExercises(
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                workoutSessionId INTEGER NOT NULL,
                exerciseId INTEGER NOT NULL,
                weight TEXT,
                series TEXT,
                isCompleted INTEGER DEFAULT 0,
                completedAt TEXT,
                FOREIGN KEY(workoutSessionId) REFERENCES WorkoutSessions(id) ON DELETE CASCADE,
                FOREIGN KEY(exerciseId) REFERENCES Exercises(id) ON DELETE CASCADE
                );
            """
                
        let success1 = exec(sql: createExercises)
        let success2 = exec(sql: createRoutines)
        let success3 = exec(sql: createRoutineExercises)
        let success4 = exec(sql: createWorkoutSessions)
        let success5 = exec(sql: createWorkoutSessionExercises)
        
        if success1 && success2 && success3 && success4 && success5 {
            print("Todas las tablas creadas correctamente")
        }

        migrateWorkoutTablesIfNeeded()
    }

    private func migrateWorkoutTablesIfNeeded() {
        ensureColumnExists(table: "WorkoutSessions", column: "startedAt", definition: "TEXT")
        ensureColumnExists(table: "WorkoutSessions", column: "endedAt", definition: "TEXT")
        ensureColumnExists(table: "WorkoutSessionExercises", column: "isCompleted", definition: "INTEGER DEFAULT 0")
        ensureColumnExists(table: "WorkoutSessionExercises", column: "completedAt", definition: "TEXT")

        if columnExists(table: "WorkoutSessions", column: "checkInAt") {
            _ = exec(sql: """
                UPDATE WorkoutSessions
                SET startedAt = checkInAt
                WHERE (startedAt IS NULL OR startedAt = '')
                AND checkInAt IS NOT NULL;
                """)
        }
    }

    private func ensureColumnExists(table: String, column: String, definition: String) {
        guard !columnExists(table: table, column: column) else { return }
        _ = exec(sql: "ALTER TABLE \(table) ADD COLUMN \(column) \(definition);")
    }

    private func columnExists(table: String, column: String) -> Bool {
        let query = "PRAGMA table_info(\(table));"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
            return false
        }

        defer { sqlite3_finalize(statement) }

        while sqlite3_step(statement) == SQLITE_ROW {
            if let columnName = sqlite3_column_text(statement, 1) {
                if String(cString: columnName).caseInsensitiveCompare(column) == .orderedSame {
                    return true
                }
            }
        }

        return false
    }
            
    @discardableResult
    func exec(sql: String) -> Bool {
        var errMsg: UnsafeMutablePointer<Int8>?
        if sqlite3_exec(db, sql, nil, nil, &errMsg) != SQLITE_OK {
            if let e = errMsg {
                print("SQL error: \(String(cString: e))")
                sqlite3_free(errMsg)
            }
            return false
        }
        return true
    }
}
