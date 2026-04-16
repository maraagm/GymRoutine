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
                
        let success1 = exec(sql: createExercises)
        let success2 = exec(sql: createRoutines)
        let success3 = exec(sql: createRoutineExercises)
        
        if success1 && success2 && success3 {
            print("Todas las tablas creadas correctamente")
        }
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
