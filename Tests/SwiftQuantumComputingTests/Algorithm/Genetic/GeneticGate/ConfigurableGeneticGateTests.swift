//
//  ConfigurableGeneticGateTests.swift
//  SwiftQuantumComputing
//
//  Created by Enrique de la Torre on 12/02/2019.
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

import XCTest

@testable import SwiftQuantumComputing

// MARK: - Main body

class ConfigurableGeneticGateTests: XCTestCase {

    // MARK: - Tests

    func testAnyGateAndCorrectTruthTable_makeFixed_returnValue() {
        // Given
        let gate = ConfigurableGeneticGate(inputs: [0, 1])
        let useCase = try! GeneticUseCase(emptyTruthTableQubitCount: 1, circuitOutput: "0")

        // Then
        switch gate.makeFixed(useCase: useCase) {
        case .success:
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }

    static var allTests = [
        ("testAnyGateAndCorrectTruthTable_makeFixed_returnValue",
         testAnyGateAndCorrectTruthTable_makeFixed_returnValue)
    ]
}
