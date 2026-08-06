#if os(macOS)
import Darwin
import Foundation
import Testing

@testable import ContainerXPC

@Test func settingFileHandlePreservesCallerOwnership() throws {
    let pipe = Pipe()
    defer {
        try? pipe.fileHandleForReading.close()
        try? pipe.fileHandleForWriting.close()
    }
    let descriptor = pipe.fileHandleForWriting.fileDescriptor

    let message = XPCMessage(route: "test")
    message.set(key: "descriptor", value: pipe.fileHandleForWriting)

    #expect(fcntl(descriptor, F_GETFD) != -1)
}

@Test func settingFileHandlesPreservesCallerOwnership() throws {
    let first = Pipe()
    let second = Pipe()
    defer {
        for pipe in [first, second] {
            try? pipe.fileHandleForReading.close()
            try? pipe.fileHandleForWriting.close()
        }
    }
    let handles = [first.fileHandleForWriting, second.fileHandleForWriting]
    let descriptors = handles.map(\.fileDescriptor)

    let message = XPCMessage(route: "test")
    try message.set(key: "descriptors", value: handles)

    #expect(descriptors.allSatisfy { fcntl($0, F_GETFD) != -1 })
}
#endif
