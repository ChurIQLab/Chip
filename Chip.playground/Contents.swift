import Foundation

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
    private let accessQueue = DispatchQueue(label: "ChipStorageAccess", attributes: .concurrent)

    func push(chip: Chip) {
        accessQueue.async {
            self.chips.append(chip)
        }
    }

    func pop() -> Chip? {
        var chip: Chip?
        accessQueue.async {
            if !self.chips.isEmpty {
                chip = self.chips.removeLast()
            }
        }
        return chip
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
    }
}
