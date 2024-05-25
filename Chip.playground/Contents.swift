import Foundation

let dateFormatter = DateFormatter()
dateFormatter.dateStyle = .medium
dateFormatter.timeStyle = .medium
dateFormatter.locale = Locale(identifier: "ru_RU")

func getCurrentFormattedDate() -> String {
    return dateFormatter.string(from: Date())
}

public struct Chip {
    public enum ChipType: UInt32 {
        case small = 1
        case medium
        case big
    }

    public let chipType: ChipType

    public static func make() -> Chip {
        guard let chipType = Chip.ChipType(rawValue: UInt32(arc4random_uniform(3) + 1)) else {
            fatalError("Incorrect random value")
        }

        return Chip(chipType: chipType)
    }

    public func sodering() {
        let soderingTime = chipType.rawValue
        sleep(UInt32(soderingTime))
    }
}

class ChipStorage {
    private var chips : [Chip] = []
    private let mutex = NSLock()

    func push(chip: Chip) {
        mutex.lock()
        self.chips.append(chip)
        mutex.unlock()
    }

    func pop() -> Chip? {
        mutex.lock()
        defer {
            mutex.unlock()
        }
        return chips.popLast()
    }
}

class ChipGeneratingThread: Thread {
    let storage: ChipStorage
    let duration: TimeInterval = 20

    init(storage: ChipStorage) {
        self.storage = storage
    }

    override func main() {
        let startDate = Date()
        while Date().timeIntervalSince(startDate) < duration {
            let chip = Chip.make()
            storage.push(chip: chip)
            print("Генератор: создана микросхема \(chip.chipType)")
            Thread.sleep(forTimeInterval: 2)
        }
        print("Генератор завершил работу")
    }
}


class ChipWorkerThread: Thread {
    let storage: ChipStorage
    let generatorThread: ChipGeneratingThread

    init(storage: ChipStorage, generatorThread: ChipGeneratingThread) {
        self.storage = storage
        self.generatorThread = generatorThread
    }

    override func main() {
        while !isCancelled {
            guard let chip = storage.pop() else {
                if generatorThread.isFinished {
                    print("Рабочий завершил работу")
                    break
                }
                print("Рабочий: микросхемы отсутствуют, ждем...")
                Thread.sleep(forTimeInterval: 1)
                continue
            }
            print("Рабочий: пайка микросхемы \(chip.chipType)")
            chip.sodering()
            print("Рабочий: пайка микросхемы \(chip.chipType) завершена")
        }
    }
}

let storage = ChipStorage()
let generatorThread = ChipGeneratingThread(storage: storage)
let workerThread = ChipWorkerThread(storage: storage, generatorThread: generatorThread)

generatorThread.start()
workerThread.start()

while !workerThread.isFinished {
    Thread.sleep(forTimeInterval: 0.1)
}

print("Все зхадачи выполнены!")
