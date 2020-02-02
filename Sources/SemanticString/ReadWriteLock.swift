import Foundation

final class ReadWriteLock {
    private let rwlock: UnsafeMutablePointer<pthread_rwlock_t> = .allocate(capacity: 1)

    init() {
        let err = pthread_rwlock_init(rwlock, nil)
        precondition(err == 0)
    }

    deinit {
        let err = pthread_rwlock_destroy(rwlock)
        precondition(err == 0)
        rwlock.deallocate()
    }

    public func lockRead() {
        let err = pthread_rwlock_rdlock(rwlock)
        precondition(err == 0)
    }

    public func lockWrite() {
        let err = pthread_rwlock_wrlock(rwlock)
        precondition(err == 0)
    }

    public func unlock() {
        let err = pthread_rwlock_unlock(rwlock)
        precondition(err == 0)
    }
}
