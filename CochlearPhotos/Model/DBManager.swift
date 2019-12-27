
import Foundation
import GRDB

class DBManager: NSObject {

    static let shared: DBManager = DBManager()
    let databaseFileName = "locations.db"
    var pathToDatabase: String!
    var sourceSqliteURL: URL!
    var destinationSqliteURL: URL!
    var dbMethod: DatabaseQueue!
    var foundEmbeddedDB = true

    override init() {
        super.init()
        
        sourceSqliteURL = Bundle.main.url(forResource:"locations", withExtension: "db")
        if sourceSqliteURL == nil {
            print("NO EMBEDDED SQL DB FOUND: " + databaseFileName)
            foundEmbeddedDB = false
        }
        let documentsDirectory = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString) as String
        pathToDatabase = documentsDirectory.appending("/\(databaseFileName)")
        
        let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        destinationSqliteURL = documentsPath.appendingPathComponent(databaseFileName)
    }
    
    func openOrCopyDatabase() -> Bool {
        // Start of Database copy from Bundle to App Document Directory
        if !foundEmbeddedDB{
            return false
        }
        do {
            if !FileManager.default.fileExists(atPath: pathToDatabase) {
                // var error:NSError? = nil
                do {
                    try FileManager.default.copyItem(at: sourceSqliteURL, to: destinationSqliteURL)
                    print("DB Copied")
                    
                } catch let error as NSError {
                    print("Unable to create database \(error.debugDescription)")
                }
            }
            dbMethod = try DatabaseQueue(path: destinationSqliteURL.path)
        }catch{
            print(error.localizedDescription)
        }
        print(destinationSqliteURL.path) // the database in the Finder.
        return true
    }
    
}
