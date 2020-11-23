//
//  SimplifiedGateConvertible.swift
//  SwiftQuantumComputing
//
//  Created by Enrique de la Torre on 23/11/2020.
//  Copyright © 2020 Enrique de la Torre. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

// MARK: - Public types

public indirect enum SimplifiedGate {
    case not(target: Int)
    case hadamard(target: Int)
    case phaseShift(radians: Double, target: Int)
    case rotation(axis: Gate.Axis, radians: Double, target: Int)
    case matrix(matrix: Matrix, inputs: [Int])
    case oracle(truthTable: [String], controls: [Int], gate: SimplifiedGate)
    case controlled(gate: SimplifiedGate, controls: [Int])
}

// MARK: - Hashable methods

extension SimplifiedGate: Hashable {}

// MARK: - Protocol definition

public protocol SimplifiedGateConvertible {
    var simplified: SimplifiedGate { get }
}
