import Foundation

func performTask(id: Int) {
    print("Task \(id) started")
    sleep(1)
    print("Task \(id) finished")
}

func runConcurrentTasks() {

    let semaphore = DispatchSemaphore(value: 2)

    let threads = (1...5).map { id in
        Thread {
            semaphore.wait()

            performTask(id: id)

            semaphore.signal()
        }
    }

    threads.forEach { $0.start() }

    while threads.contains(where: { $0.isExecuting }) {
        usleep(100_000)
    }

    print("All tasks completed.")
}

runConcurrentTasks()
