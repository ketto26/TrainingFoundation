import Foundation

class Counter {
    private var value = 0
    private let queue = DispatchQueue(label: "com.example.counterQueue", attributes: .concurrent)


    func increment() {
        queue.sync(flags: .barrier) {
            value += 1
        }
    }

    func getValue() -> Int {
        var currentValue = 0
        queue.sync {
            currentValue = value
        }
        return currentValue
    }
}

func runCounterTask() {
    let counter = Counter()
    let incrementOperation: () -> Void = {
        for _ in 1...1000 {
            counter.increment()
        }
    }

    let thread1 = Thread {
        incrementOperation()
    }

    let thread2 = Thread {
        incrementOperation()
    }

    thread1.start()
    thread2.start()

    while thread1.isExecuting || thread2.isExecuting {
        usleep(100)
    }

    print("Final counter value: \(counter.getValue()) (Expected: 2000)")
}

runCounterTask()
