import Foundation

public enum SeedType{
    
    case singlton
    case strong
    case normal
    
}

public protocol Context{
    func of<T:Seed>(type:T.Type)->T?
}

public class WeakSeed<T:AnyObject>{
    
    weak var seed:T?
    
    init(seed:T){
        self.seed = seed
    }
}
public protocol SeedContext{
    
}
public typealias SeedFactory = ()->Seed

public protocol Seed:AnyObject{
    
    
    static func type()->SeedType
    
    static var factory:SeedFactory { get }
    
    var bucket:SeedBucket? { get set }
    
    var name:String { get set }
    
}
extension Seed{
    public func update(){
        self.bucket?.center.post(name: NSNotification.Name.init(rawValue: self.name), object: self.bucket)
    }
}

public class SeedBucket:Context{
    
    public static var shared:SeedBucket = SeedBucket()
    
    public var center:NotificationCenter = NotificationCenter()
    
    public var queue:OperationQueue = OperationQueue()
    
    public lazy var notificationQueue = {
        NotificationQueue(notificationCenter: self.center)
    }()
    
    public var seeds:[String:Seed.Type] = [:]
    
    public var sigltenObject:[String:Seed] = [:]
    
    public var strongObject:[String:WeakSeed<AnyObject>] = [:]
    
    public func addSeed<T:Seed>(type:T.Type,name:String){
        pthread_rwlock_wrlock(self.rwlock)
        seeds[name] = type
        pthread_rwlock_unlock(self.rwlock)
    }
   
    public func addSeed<T:Seed>(type:T.Type){
        
        self.addSeed(type: type, name: "\(type)")
        
    }
    
    var rwlock:UnsafeMutablePointer<pthread_rwlock_t> = UnsafeMutablePointer<pthread_rwlock_t>.allocate(capacity: 1)
    
    init() {
        pthread_rwlock_init(self.rwlock, nil)
    }
    
    deinit {
        pthread_rwlock_destroy(self.rwlock)
        self.rwlock.deallocate()
    }
    
    public func of<T:Seed>(type: T.Type) -> T? {
        self.create(name: "\(type)", type: type)
    }
    
    func create<T:Seed>(name:String,type:T.Type)->T?{
        pthread_rwlock_rdlock(self.rwlock)
        if nil == self.seeds[name]{
            pthread_rwlock_unlock(self.rwlock)
            self.addSeed(type: type, name: name)
        }else{
            pthread_rwlock_unlock(self.rwlock)
        }
        pthread_rwlock_rdlock(self.rwlock)
        guard let cls = self.seeds[name] as? T.Type else {
            pthread_rwlock_unlock(self.rwlock)
            return nil
        }
        pthread_rwlock_unlock(self.rwlock)
        if cls.type() == .singlton{
            if let obj = self.readSiglton(name: name,type:type){
                return obj
            }else{
                return self.createSiglton(cls: cls, name: name)
            }
        }else if cls.type() == .strong{
            if let obj = self.readStrong(name: name, type: type){
                return obj
            }else{
                return self.createStrong(cls: cls, name: name)
            }
        }
        else{
            let obj = cls.factory()
            obj.bucket = self
            obj.name = name
            return obj as? T
        }
    }
    
    private func createSiglton<T:Seed>(cls:T.Type,name:String)->T{
        pthread_rwlock_wrlock(self.rwlock)
        let obj = cls.factory()
        obj.name = name
        self.sigltenObject[name] = obj
        obj.bucket = self
        pthread_rwlock_unlock(self.rwlock)
        return obj as! T
    }
    private func createStrong<T:Seed>(cls:T.Type,name:String)->T{
        pthread_rwlock_wrlock(self.rwlock)
        let obj = cls.factory()
        obj.bucket = self
        obj.name = name
        let ws = WeakSeed(seed: obj as AnyObject)
        self.strongObject[name] = ws
        pthread_rwlock_unlock(self.rwlock)
        return obj as! T
    }
    private func readSiglton<T:Seed>(name:String,type:T.Type)->T?{
        pthread_rwlock_rdlock(self.rwlock)
        let s = self.sigltenObject[name]
        pthread_rwlock_unlock(self.rwlock)
        return s as? T
    }
    
    private func readStrong<T:Seed>(name:String,type:T.Type)->T?{
        pthread_rwlock_rdlock(self.rwlock)
        let s = self.strongObject[name]?.seed
        pthread_rwlock_unlock(self.rwlock)
        return s as? T
    }
}

@propertyWrapper
public class Carrot<T:Seed>{
    
    public private(set) var name:String
    
    public private(set) var strongObject:T?
    
    public private(set) var bucket:SeedBucket
    
    public var observer:((T?)->Void)?

    public var wrappedValue:T? {
        
        if T.type() == .strong{
            if (self.strongObject != nil){
                return self.strongObject
            }else{
                self.strongObject = self.bucket.create(name: self.name,type: T.self);
                
                return self.strongObject
            }
        }else{
            return self.bucket.create(name: self.name,type: T.self)
        }
    }
    public init(name:String = "\(T.self)",bucket:SeedBucket = SeedBucket.shared) {
        self.name = name
        self.bucket = bucket
        self.bucket.center.addObserver(forName: .init(name), object: bucket, queue: bucket.queue) { n in
            self.observer?(self.wrappedValue)
        }
    }
    public var projectedValue:Carrot{
        return self
    }
}
