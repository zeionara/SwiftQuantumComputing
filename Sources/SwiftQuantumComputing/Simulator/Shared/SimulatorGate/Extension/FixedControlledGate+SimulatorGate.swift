//
//  FixedControlledGate+SimulatorGate.swift
//  SwiftQuantumComputing
//
//  Created by Enrique de la Torre on 14/11/2020.
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

// MARK: - SimulatorGate methods

extension FixedControlledGate: SimulatorGate {}

// MARK: - SimulatorComponents methods

extension FixedControlledGate: SimulatorComponents {
    func extractRawInputs() -> [Int] {
        return controls + gate.extractRawInputs()
    }

    func extractMatrix() -> Result<SimulatorGateMatrix, GateError> {
        guard !controls.isEmpty else {
            return .failure(.gateControlsCanNotBeAnEmptyList)
        }

        switch gate.extractMatrix() {
        case .failure(let error):
            return .failure(error)
        case .success(.singleQubitMatrix(let matrix)):
            return .success(.fullyControlledSingleQubitMatrix(controlledMatrix: matrix,
                                                              controlCount: controls.count))
        case .success(.fullyControlledSingleQubitMatrix(let ctrlMatrix, let ctrlCount)):
            return .success(.fullyControlledSingleQubitMatrix(controlledMatrix: ctrlMatrix,
                                                              controlCount: ctrlCount + controls.count))
        case .success(.otherMultiQubitMatrix(let matrix)):
            let result = OracleSimulatorMatrix(equivalentToControlledGateWithControlCount: controls.count,
                                               controlledMatrix: matrix)
            return .success(.otherMultiQubitMatrix(matrix: result))
        }
    }
}
