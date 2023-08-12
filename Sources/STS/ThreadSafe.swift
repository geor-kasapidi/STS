@propertyWrapper
public final class ThreadSafe<T> {
    // MARK: Lifecycle

    public init(wrappedValue: T) {
        self.value = wrappedValue
    }

    // MARK: Public

    public var projectedValue: ThreadSafe<T> { self }

    public var wrappedValue: T {
        get {
            self.lock.lock(); defer { self.lock.unlock() }
            return self.value
        }
        _modify {
            self.lock.lock(); defer { self.lock.unlock() }
            yield &self.value
        }
    }

    public func read<V>(_ f: (T) -> V) -> V {
        self.lock.lock(); defer { self.lock.unlock() }
        return f(self.value)
    }

    @discardableResult
    public func write<V>(_ f: (inout T) -> V) -> V {
        self.lock.lock(); defer { self.lock.unlock() }
        return f(&self.value)
    }

    // MARK: Private

    private let lock = UnfairLock()

    private var value: T
}
