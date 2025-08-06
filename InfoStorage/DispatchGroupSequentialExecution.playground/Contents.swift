import Foundation
import PlaygroundSupport

func executeTask(_ taskNumber: Int, delay: UInt32) {
    print("Task \(taskNumber) started")
    sleep(delay)
    print("Task \(taskNumber) finished")
}

func executeTasks() {
    
    let queue1 = DispatchQueue(label: "com.example.queue1", attributes: .concurrent)
    let queue2 = DispatchQueue(label: "com.example.queue2", attributes: .concurrent)
    let queueFinal = DispatchQueue(label: "com.example.finalQueue")
    let dispatchGroup = DispatchGroup()
    
    queue1.async(group: dispatchGroup) {
        executeTask(1, delay: 2)
    }
    
    queue2.async(group: dispatchGroup) {
        executeTask(2, delay: 3)
    }
    
    dispatchGroup.notify(queue: queueFinal) {
        executeTask(3, delay: 1)
        print("All tasks sequence completed.")
        PlaygroundSupport.PlaygroundPage.current.finishExecution()
    }
    
    print("Initial tasks dispatched. Waiting for them to finish before Task 3.")
}

executeTasks()

PlaygroundSupport.PlaygroundPage.current.needsIndefiniteExecution = true

