//
//  SCMStatevectorRegister.swift
//  SwiftQuantumComputing
//
//  Created by Enrique de la Torre on 13/10/2019.
//  Copyright © 2019 Enrique de la Torre. All rights reserved.
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

struct SCMStatevectorRegister {

    // MARK: - Private properties

    private let vector: Vector
    private let matrixFactory: SimulatorCircuitMatrixFactory

    private let qubitCount: Int

    // MARK: - Internal init methods

    enum InitError: Error {
        case vectorCountHasToBeAPowerOfTwo
    }
    
    init(vector: Vector, matrixFactory: SimulatorCircuitMatrixFactory) throws {
        guard vector.count.isPowerOfTwo else {
            throw InitError.vectorCountHasToBeAPowerOfTwo
        }

        qubitCount = Int.log2(vector.count)

        self.vector = vector
        self.matrixFactory = matrixFactory
    }
}

// MARK: - StatevectorRegister methods

extension SCMStatevectorRegister: StatevectorRegister {
    func statevector() throws -> Vector {
        guard vector.isAdditionOfSquareModulusEqualToOne() else {
            throw StatevectorRegisterError.statevectorAdditionOfSquareModulusIsNotEqualToOne
        }

        return vector
    }

    func applying(_ gate: SimulatorGate) throws -> SCMStatevectorRegister {
        let matrix = try matrixFactory.makeCircuitMatrix(qubitCount: qubitCount, gate: gate)
        let nextVector = try! matrix * vector

        return try! SCMStatevectorRegister(vector: nextVector, matrixFactory: matrixFactory)
    }
}
