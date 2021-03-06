//
//  DirectStatevectorTransformation.swift
//  SwiftQuantumComputing
//
//  Created by Enrique de la Torre on 15/04/2020.
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

import ComplexModule
import Foundation

// MARK: - Main body

struct DirectStatevectorTransformation {

    // MARK: - Private properties

    private let maxConcurrency: Int

    // MARK: - Internal init methods

    enum InitError: Error {
        case maxConcurrencyHasToBiggerThanZero
    }

    init(maxConcurrency: Int) throws {
        guard maxConcurrency > 0 else {
            throw InitError.maxConcurrencyHasToBiggerThanZero
        }

        self.maxConcurrency = maxConcurrency
    }
}

// MARK: - StatevectorTransformation methods

extension DirectStatevectorTransformation: StatevectorTransformation {
    func apply(components: SimulatorGate.Components, toStatevector vector: Vector) -> Vector {
        var nextVector: Vector!

        switch components.simulatorGateMatrix {
        case .singleQubitMatrix(let matrix):
            nextVector = apply(oneQubitMatrix: matrix,
                               toStatevector: vector,
                               atInput: components.inputs[0])
        case .fullyControlledSingleQubitMatrix(let controlledMatrix, _):
            let lastIndex = components.inputs.count - 1

            let target = components.inputs[lastIndex]

            let controls = Array(components.inputs[0..<lastIndex])
            let filter = Int.mask(activatingBitsAt: controls)

            nextVector = apply(oneQubitMatrix: controlledMatrix,
                               toStatevector: vector,
                               atInput: target,
                               selectingStatesWith: filter)
        case .otherMultiQubitMatrix(let matrix):
            nextVector = apply(multiQubitMatrix: matrix,
                               toStatevector: vector,
                               atInputs: components.inputs)
        }

        return nextVector
    }
}

// MARK: - Private body

private extension DirectStatevectorTransformation {

    // MARK: - Private methods

    func apply(oneQubitMatrix: SimulatorMatrix,
               toStatevector vector: Vector,
               atInput input: Int,
               selectingStatesWith filter: Int? = nil) -> Vector {
        let mask = Int.mask(activatingBitAt: input)
        let invMask = ~mask

        return try! Vector.makeVector(count: vector.count, maxConcurrency: maxConcurrency, value: { index in
            var value: Complex<Double>!

            if let filter = filter, index & filter != filter {
                value = vector[index]
            } else if index & mask == 0 {
                let otherIndex = index | mask

                value = oneQubitMatrix[0, 0] * vector[index] + oneQubitMatrix[0, 1] * vector[otherIndex]
            } else {
                let otherIndex = index & invMask

                value = oneQubitMatrix[1, 0] * vector[otherIndex] + oneQubitMatrix[1, 1] * vector[index]
            }

            return value
        }).get()
    }

    func apply(multiQubitMatrix matrix: SimulatorMatrix,
               toStatevector vector: Vector,
               atInputs inputs: [Int]) -> Vector {
        var rearranger: [BitwiseShift] = []
        var selectedBitMask = 0
        var activationMasks: [Int] = []
        for (destination, origin) in inputs.reversed().enumerated() {
            let action = BitwiseShift(origin: origin, destination: destination)

            rearranger.append(action)

            selectedBitMask |= action.selectMask

            activationMasks.append(action.selectMask)
            let partialCount = activationMasks.count - 1
            for index in 0..<partialCount {
                activationMasks.append(activationMasks[index] | action.selectMask)
            }
        }

        let unselectedBitMask = ~selectedBitMask

        return try! Vector.makeVector(count: vector.count, maxConcurrency: maxConcurrency, value: { vectorIndex in
            let matrixRow = rearranger.rearrangeBits(in: vectorIndex)

            let derivedIndex = vectorIndex & unselectedBitMask
            var vectorValue = matrix[matrixRow, 0] * vector[derivedIndex]

            for index in 0..<activationMasks.count {
                vectorValue += matrix[matrixRow, index + 1] * vector[derivedIndex | activationMasks[index]]
            }

            return vectorValue
        }).get()
    }
}
