import os

public final class UnfairLock {
    // MARK: Lifecycle

    public init() {
        self.pointer = .allocate(capacity: 1)
        self.pointer.initialize(to: os_unfair_lock())
    }

    deinit {
        self.pointer.deinitialize(count: 1)
        self.pointer.deallocate()
    }

    // MARK: Public

    public func lock() {
        os_unfair_lock_lock(self.pointer)
    }

    public func unlock() {
        os_unfair_lock_unlock(self.pointer)
    }

    public func tryLock() -> Bool {
        os_unfair_lock_trylock(self.pointer)
    }

    @discardableResult
    @inlinable
    public func execute<T>(_ action: () -> T) -> T {
        self.lock(); defer { self.unlock() }
        return action()
    }

    @discardableResult
    @inlinable
    public func tryExecute<T>(_ action: () throws -> T) throws -> T {
        try self.execute { Result(catching: action) }.get()
    }

    // MARK: Private

    private let pointer: os_unfair_lock_t
}
