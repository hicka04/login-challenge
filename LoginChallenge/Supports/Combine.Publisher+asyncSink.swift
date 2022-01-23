//
//  Combine.Publisher+asyncSink.swift
//  LoginChallenge
//
//  Created by hicka04 on 2022/01/23.
//

import Foundation
import Combine

extension Publisher where Output: Sendable, Failure == Never {
    func asyncSink(receiveValue: @Sendable @escaping (Output) async -> Void) -> AnyCancellable {
        self.sink { output in
            Task {
                await receiveValue(output)
            }
        }
    }
}
