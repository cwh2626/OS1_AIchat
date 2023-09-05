//
//  ChatRepository.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/08/24.
//

import FMDB
import RxSwift

class ChatRepository {
    // 싱글톤 적용 SQL인스턴스는 DB안정성을 위해 하나로 돌려쓰는걸로
    static let shared = ChatRepository()
    private let queue = DispatchQueue(label: "com.cwh2626.chat-AI.OS1.chatrepository")
    
    lazy var fmdb: FMDatabase! = {
        // 번들에 내장되어있는 DB경로
//        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last ?? "")

        // 1. 파일 매니저 객체를 생성
        let fileMgr = FileManager.default
        
        // 2. 샌드박스 내 문서 디렉터리에서 데이터베이스 파일 경로를 확인
        let docPathURL = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbPath = docPathURL.appendingPathComponent("ChatStorage.db").path

        // 3. 샌드박스 경로에 파일이 없다면 메인 번들에 만들어 둔 hr.sqlite를 가져와 복사
        if fileMgr.fileExists(atPath: dbPath) == false {
            let dbSource = Bundle.main.path(forResource: "ChatStorage", ofType: "db")
            try! fileMgr.copyItem(atPath: dbSource!, toPath: dbPath)
        }
        
        // 4. 준비된 데이터베이스 파일을 바탕으로 FMDatabase 객체를 생성
        let db = FMDatabase(path: dbPath)
        return db
    }()
    
    private func performDatabaseTask(_ task: @escaping () -> Void) {
        queue.sync {
            task()
        }
    }
    
    private init() {
        self.openDatabase()
    }
    
    // static으로 인스턴스를 생성했기에 앱을종료해도 호출되지않겠지만 습관, 또는 명시해두면 가독성에 굿?
    deinit {
        self.closeDatabase()
    }
    
    func closeDatabase() {
        guard self.fmdb.isOpen else { return }
        self.fmdb.close()
    }
    
    func openDatabase() {
        guard !self.fmdb.isOpen else { return }
        self.fmdb.open()
    }
    
    func getAllSysContent() -> [Chat] {
        // 반환할 데이터를 담을 [chatVO] 타입의 객체 정의
        var chatList = [Chat]()
        
        // 1. 채팅내용을 가져올 SQL 작성 및 쿼리 실행
        do {
            let sql = """
                SELECT *
                FROM CHAT_HISTORY_TB
                WHERE ROLE = \(ChatRoleType.SYS.rawValue)
                ORDER BY NUMBER ASC
            """
            
            let rs = try self.fmdb.executeQuery(sql, values: nil)
            
            // 2. 결과 집합 추출
            while rs.next() {
                var record = Chat()
                
                record.chatNum = Int(rs.int(forColumn: "NUMBER"))
                record.content = rs.string(forColumn: "CONTENT")!
                record.time = rs.string(forColumn: "TIMESTAMP")!
                
                let cd: Int = Int(rs.int(forColumn: "ROLE")) // DB에서 읽어온 ROLE 값
                record.role = ChatRoleType(rawValue: cd)!

                
                chatList.append(record)
            }
        }catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        
        return chatList
    }
    
    
    /// 채팅내용가져오기
    /// - Parameter chatNM: 채팅 인덱스, default : 전체 기록 가져오기
    /// - Returns: 채팅내용리스트
    func get(sysRole: Bool) -> [Chat] {
        // 반환할 데이터를 담을 [chatVO] 타입의 객체 정의
        var chatList = [Chat]()
        
        // 1. 채팅내용을 가져올 SQL 작성 및 쿼리 실행
        do {
            // 1-1 조건절 정의
            let conditon = sysRole ? "WHERE ROLE = 0": "WHERE ROLE != 0"
            
            let sql = """
                SELECT *
                FROM CHAT_HISTORY_TB
                \(conditon)
                ORDER BY NUMBER ASC
            """
            
            let rs = try self.fmdb.executeQuery(sql, values: nil)
            
            // 2. 결과 집합 추출
            while rs.next() {
                var record = Chat()
                
                record.chatNum = Int(rs.int(forColumn: "NUMBER"))
                record.content = rs.string(forColumn: "CONTENT")!
                record.time = rs.string(forColumn: "TIMESTAMP")!
                
                let cd: Int = Int(rs.int(forColumn: "ROLE")) // DB에서 읽어온 ROLE 값
                record.role = ChatRoleType(rawValue: cd)!

                
                chatList.append(record)
            }
        }catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        
        return chatList
    }
    
    func getCurrentMessageToken() -> Single<Int> {
        return Single.create { [weak self] single in
            self?.performDatabaseTask {
                var messageToken:Int?
                
                do {
                    let sql = """
                        SELECT TOTAL_TOKENS
                        FROM CHAT_TOKEN_TB
                    """
                    
                    let rs = try self?.fmdb.executeQuery(sql, values: nil)
                    
                    while rs!.next() {
                        messageToken = Int(rs!.int(forColumn: "TOTAL_TOKENS"))
                    }
                    
                    if let _messageToken = messageToken {
                        single(.success(_messageToken))
                    } else {
                        single(.failure(DatabaseErrorHelper.dataNotFoundError()))
                    }
                    
                }catch let error as NSError {
                    print("failed: \(error.localizedDescription)")
                    single(.failure(error))
                }
            }
            
            return Disposables.create()
        }
    }
    
    func getMixmumMessageToken() -> Single<Int> {
        return Single.create { [weak self] single in
            self?.performDatabaseTask {
                var maximumToken:Int?
                do {
                    let sql = """
                        SELECT MAXIMUM_TOKENS
                        FROM CHAT_TOKEN_TB
                    """
                    
                    let rs = try self?.fmdb.executeQuery(sql, values: nil)
                    
                    // 2. 결과 집합 추출
                    while rs!.next() {
                        maximumToken = Int(rs!.int(forColumn: "MAXIMUM_TOKENS"))
                    }
                    if let _maximumToken = maximumToken {
                        single(.success(_maximumToken))
                    } else {
                        single(.failure(DatabaseErrorHelper.dataNotFoundError()))
                    }
                }catch let error as NSError {
                    print("failed: \(error.localizedDescription)")
                    single(.failure(error))
                }
                   
            }
            return Disposables.create()
        }
    }
    
    func updateMessageToken(promptTokens: Int, updateTime: String) -> Bool {
        do {

            let sql = """
                UPDATE CHAT_TOKEN_TB
                SET TOTAL_TOKENS = ? ,TIMESTAMP = ?
                WHERE NUMBER = 1
            """
            var params = [Any]()
            params.append(promptTokens)
            params.append(updateTime)
//            print(#function, "룰 : \(param.role) - > \(params)")
            try self.fmdb.executeUpdate(sql, values: params)
            
            return true
        } catch let error as NSError {
            print("Insert Error: \(error.localizedDescription)")
            return false
        }
    }
        
    func getOwnedToken() -> Single<Double> {
        return Single.create { [weak self] single in
            
            self?.performDatabaseTask {
                var OwnedToken:Double?
                
                do {
                    let sql = """
                        SELECT OWNED_TOKENS
                        FROM USER_TOKEN_TB
                    """
                    
                    let rs = try self?.fmdb.executeQuery(sql, values: nil)
                    
                    // 2. 결과 집합 추출
                    while rs!.next() {
                        OwnedToken = rs!.double(forColumn: "OWNED_TOKENS")
                    }
                    
                    if let _OwnedToken = OwnedToken {
                        single(.success(_OwnedToken))
                    } else {
                        single(.failure(DatabaseErrorHelper.dataNotFoundError()))
                    }

                }catch let error as NSError {
                    print("failed: \(error.localizedDescription)")
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
    
    func getTokenLimit() -> Double? {
        var TokenLimit:Double?
        
        do {
            let sql = """
                SELECT TOKEN_LIMIT
                FROM USER_TOKEN_TB
            """
            
            let rs = try self.fmdb.executeQuery(sql, values: nil)
            
            // 2. 결과 집합 추출
            while rs.next() {
                TokenLimit = rs.double(forColumn: "TOKEN_LIMIT")
            }
        }catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        
        return TokenLimit
    }
    
    func updateOwnedToken(ownedTokens: Double, updateTime: String) -> Completable {
        return Completable.create { [weak self] completable in
            self?.performDatabaseTask {
                do {
                    let sql = """
                       UPDATE USER_TOKEN_TB
                       SET OWNED_TOKENS = ? ,TIMESTAMP = ?
                       WHERE NUMBER = 1
                    """
                    var params = [Any]()
                    params.append(ownedTokens)
                    params.append(updateTime)
                    try self?.fmdb.executeUpdate(sql, values: params)
                    
                    completable(.completed)
                } catch let error {
                    print("Insert Error: \(error.localizedDescription)")
                    completable(.error(error))
                }
            }
           return Disposables.create()
       }
    }
    
    /// 채팅생성
    /// - Parameter param: 채팅내용
    /// - Returns: 생성성공여부
    func create(param: Chat) -> Bool {
        do {
            let sql = """
                INSERT INTO CHAT_HISTORY_TB (ROLE, CONTENT, TIMESTAMP)
                VALUES ( ?, ?, ? )
            """
            var params = [Any]()
            params.append(param.role.rawValue)
            params.append(param.content)
            params.append(param.time)

            try self.fmdb.executeUpdate(sql, values: params)
            
            return true
        } catch let error as NSError {
            
            print("Insert Error: \(error.localizedDescription)")
            return false
        }
    }

    func update(param: Chat) -> Bool {
        do {

            let sql = """
                UPDATE CHAT_HISTORY_TB
                SET CONTENT = ? ,TIMESTAMP = ?
                WHERE NUMBER = \(param.chatNum)
            """
            var params = [Any]()
            params.append(param.content)
            params.append(param.time)

            try self.fmdb.executeUpdate(sql, values: params)
            
            return true
        } catch let error as NSError {
            print("Insert Error: \(error.localizedDescription)")
            return false
        }
    }
    
    func delete(number: Int) -> Bool {
        do {

            let sql = """
                DELETE FROM CHAT_HISTORY_TB
                WHERE NUMBER = \(number)
            """
            try self.fmdb.executeUpdate(sql, values: nil)
            
            return true
        } catch let error as NSError {
            print("Insert Error: \(error.localizedDescription)")
            return false
        }
    }
    
    func clearAllChatData(updateTime: String) -> Completable {
        return Completable.create { [weak self] completable in
            self?.performDatabaseTask {
                do {
                    var sql = """
                        DELETE FROM CHAT_HISTORY_TB
                        WHERE ROLE != 0
                    """
                    try self?.fmdb.executeUpdate(sql, values: nil)
                    
                    sql = """
                        UPDATE CHAT_TOKEN_TB
                        SET TOTAL_TOKENS = 0 ,TIMESTAMP = ?
                        WHERE NUMBER = 1
                    """
                    var params = [Any]()
                    params.append(updateTime)
                    
                    try self?.fmdb.executeUpdate(sql, values: params)
                    completable(.completed)
                    
                } catch let error as NSError {
                    print("Insert Error: \(error.localizedDescription)")
                    completable(.error(error))
                    
                }
            }
            return Disposables.create()
        }
    }
}
