//
//  CircuitStatevector+Probabilities.swift
//  SwiftQuantumComputing
//
//  Created by Enrique de la Torre on 14/06/2020.
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

extension CircuitStatevector {

    // MARK: - Public methods

    /**
     Returns the probabilities of each possible combinations of qubits.

     - Returns: A list in which each position represents a qubit combination and the value in a position the probability of
     such combination.
     */
    public func probabilities() -> [Double] {
        return statevector.map { $0.lengthSquared }
    }
}
