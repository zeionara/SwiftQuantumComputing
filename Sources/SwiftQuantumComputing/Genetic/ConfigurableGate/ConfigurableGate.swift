//
//  ConfigurableGate.swift
//  SwiftQuantumComputing
//
//  Created by Enrique de la Torre on 15/12/2018.
//  Copyright © 2018 Enrique de la Torre. All rights reserved.
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

// MARK: - Protocol definition

/// A quantum gate used on genetic programming
public protocol ConfigurableGate {

    /**
     Produces a `Gate` instance using as many `inputs` as necessary to configure it.

     - Parameter inputs: A list of qubits/indexes in any order.

     - Throws: `EvolveCircuitError`.

     - Returns: A `Gate` instance.
     */
    func makeFixed(inputs: [Int]) throws -> Gate
}
