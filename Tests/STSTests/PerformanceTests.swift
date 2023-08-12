import STS
import XCTest

final class PerformanceTests: XCTestCase {
    // MARK: Internal

    func testSTS() {
        @ThreadSafe
        var value = ComplexStruct()

        let t1 = Date()

        for _ in 0 ..< Constants.iterations {
            _ = $value.read { $0 }

            $value.write {
                $0.modify()
            }
        }

        let t2 = Date()
        print("0️⃣", t2.timeIntervalSince(t1))
    }

    func testGCD() {
        var value = ComplexStruct()

        let queue = DispatchQueue(label: "test_queue")

        let t1 = Date()

        for _ in 0 ..< Constants.iterations {
            _ = queue.sync {
                value
            }

            queue.async {
                value.modify()
            }
        }

        let t2 = Date()
        print("1️⃣", t2.timeIntervalSince(t1))
    }

    func testActor() async {
        actor Value {
            private var value = ComplexStruct()

            @discardableResult
            func read() -> ComplexStruct {
                self.value
            }

            func update() {
                self.value.modify()
            }
        }

        let a = Value()

        let t1 = Date()

        for _ in 0 ..< Constants.iterations {
            _ = await a.read()
            await a.update()
        }

        let t2 = Date()
        print("2️⃣", t2.timeIntervalSince(t1))
    }

    // MARK: Private

    private enum Constants {
        static let iterations = 100_000
    }

    private struct ComplexStruct: Equatable {
        struct InnerStruct: Equatable {
            var a: Int = .zero
            var b: Int = .zero
        }

        var c: Int = .zero
        var x: InnerStruct = .init()

        mutating func modify() {
            _ = self.c
            _ = self.x.a
            _ = self.x.b

            if Bool.random() {
                self.c = .random(in: 0 ... 1000)
            } else {
                if Bool.random() {
                    self.x.a = .random(in: 0 ... 1000)
                } else {
                    self.x.b = .random(in: 0 ... 1000)
                }
            }

            self.c += 1
            self.x.b += 1
            self.x.a += 1
        }
    }
}
