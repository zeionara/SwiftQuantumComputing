//
//  Gate+Matrix.swift
//  SwiftQuantumComputing
//
//  Created by Enrique de la Torre on 15/11/2020.
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

extension Gate {

    // MARK: - Public class methods

    /// Returns a generic quantum gate built with a `matrix` (it is expected to be unitary) and any number of `inputs`
    /// (as many inputs as `matrix` is able to handle)
    public static func matrix(matrix: Matrix, inputs: [Int]) -> Gate {
        return Gate(gate: FixedMatrixGate(matrix: matrix, inputs: inputs))
    }
}
