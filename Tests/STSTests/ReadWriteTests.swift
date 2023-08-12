import STS
import XCTest

final class ReadWriteTests: XCTestCase {
    // MARK: Internal

    func testPropertyWrapperAPI() {
        let initialValue = ComplexStruct()

        let ts = ThreadSafe(wrappedValue: initialValue)

        DispatchQueue.concurrentPerform(iterations: 10000) { _ in
            _ = ts.read { $0 }

            ts.write {
                _ = $0.c
                _ = $0.x.a
                _ = $0.x.b

                if Bool.random() {
                    $0.c = .random(in: 0 ... 1000)
                } else {
                    if Bool.random() {
                        $0.x.a = .random(in: 0 ... 1000)
                    } else {
                        $0.x.b = .random(in: 0 ... 1000)
                    }
                }

                $0.c += 1
                $0.x.b += 1
                $0.x.a += 1
            }
        }

        XCTAssertNotEqual(ts.wrappedValue, initialValue)
    }

    func testLockThrowing() {
        struct Err: Swift.Error {}

        let lock = UnfairLock()

        XCTAssertThrowsError(try lock.tryExecute { throw Err() } as Int)
        XCTAssert((try? lock.tryExecute { 5 }) == 5)
    }

    // MARK: Private

    private struct ComplexStruct: Equatable {
        struct InnerStruct: Equatable {
            var a: Int = .zero
            var b: Int = .zero
        }

        var c: Int = .zero
        var x: InnerStruct = .init()
    }
}
