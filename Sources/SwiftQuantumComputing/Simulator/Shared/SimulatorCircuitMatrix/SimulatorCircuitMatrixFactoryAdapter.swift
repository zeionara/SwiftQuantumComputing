//
//  SimulatorCircuitMatrixFactoryAdapter.swift
//  SwiftQuantumComputing
//
//  Created by Enrique de la Torre on 03/02/2020.
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

// MARK: - Main body

struct SimulatorCircuitMatrixFactoryAdapter {}

// MARK: - SimulatorCircuitMatrixFactory methods

extension SimulatorCircuitMatrixFactoryAdapter: SimulatorCircuitMatrixFactory {
    func makeCircuitMatrix(qubitCount: Int, baseMatrix: Matrix, inputs: [Int]) -> Matrix {
        let count = Int.pow(2, qubitCount)

        let remainingInputs = (0..<qubitCount).reversed().filter { !inputs.contains($0) }

        var derives: [Int: (base: Int, remaining: Int)] = [:]
        for value in 0..<count {
            derives[value] = (value.derived(takingBitsAt: inputs),
                              value.derived(takingBitsAt: remainingInputs))
        }

        return try! Matrix.makeMatrix(rowCount: count, columnCount: count) { r, c -> Complex in
            let baseRow = derives[r]!.base
            let baseColumn = derives[c]!.base

            let remainingRow = derives[r]!.remaining
            let remainingColumn = derives[c]!.remaining

            return (remainingRow == remainingColumn ?
                baseMatrix[baseRow, baseColumn] :
                Complex.zero)
        }
    }
}
