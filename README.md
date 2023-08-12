# STS

Convenient wrapper around os_unfair_lock and property warpper for atomic memory access on any apple platform.

``` swift
let lock = UnfairLock()
lock.lock()
// ...
lock.unlock()
```

``` swift
@ThreadSafe
var value = SomeType()

value.info.id += 1 // safe and atomic
```
