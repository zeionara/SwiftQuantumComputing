//
//  XorEquationSystemBruteForceSolverTests.swift
//  SwiftQuantumComputing
//
//  Created by Enrique de la Torre on 01/01/2020.
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

import XCTest

@testable import SwiftQuantumComputing

// MARK: - Main body

class XorEquationSystemBruteForceSolverTests: XCTestCase {

    // MARK: - Properties

    let factory = XorEquationSystemFactoryTestDouble()

    // MARK: - Tests

    func testAnySolverAndEquations_findActivatedVariablesInEquations_returnExpectedResult() {
        // Given
        let solver = XorEquationSystemBruteForceSolver(factory: factory)

        let equations: [[XorEquationComponent]] = [
            [.variable(id: 0), .variable(id: 1), .constant(activated: true)],
            [.variable(id: 1), .variable(id: 2), .constant(activated: false)]
        ]

        factory.makeSystemResult.solvesResult = true

        // When
        let result = solver.findActivatedVariablesInEquations(equations)

        // Then
        let expectedResult: [[Int]] = [
            [],
            [0], [1], [2],
            [0, 1], [0, 2], [1, 2],
            [0, 1, 2]
        ]

        XCTAssertEqual(factory.makeSystemCount, 1)
        XCTAssertEqual(expectedResult.count, factory.makeSystemResult.solvesCount)
        XCTAssertEqual(expectedResult.count, result.count)
        XCTAssertTrue(expectedResult.allSatisfy { expectedValue in
            return result.contains { value in Set(expectedValue) == Set(value) }
        })
    }

    func testAnySolverAndEquationsWithRepeatedVariables_findActivatedVariablesInEquations_returnEmptyResult() {
        let solver = XorEquationSystemBruteForceSolver(factory: factory)

        let equations: [[XorEquationComponent]] = [
            [.variable(id: 0), .variable(id: 0), .constant(activated: true)],
            [.variable(id: 1), .variable(id: 1), .constant(activated: false)]
        ]

        factory.makeSystemResult.solvesResult = true

        // When
        let result = solver.findActivatedVariablesInEquations(equations)

        // Then
        let expectedResult: [[Int]] = [
            [], [0], [1], [0, 1],
        ]

        XCTAssertEqual(factory.makeSystemCount, 1)
        XCTAssertEqual(expectedResult.count, factory.makeSystemResult.solvesCount)
        XCTAssertEqual(expectedResult.count, result.count)
        XCTAssertTrue(expectedResult.allSatisfy { expectedValue in
            return result.contains { value in Set(expectedValue) == Set(value) }
        })
    }

    func testAnySolverAndEquationsOnlyWithConstants_findActivatedVariablesInEquations_returnEmptyResult() {
        // Given
        let solver = XorEquationSystemBruteForceSolver(factory: factory)

        let equations: [[XorEquationComponent]] = [
            [.constant(activated: true), .constant(activated: false)],
            [.constant(activated: false), .constant(activated: true)]
        ]

        // Then
        XCTAssertEqual(solver.findActivatedVariablesInEquations(equations), [])
        XCTAssertEqual(factory.makeSystemCount, 1)
        XCTAssertEqual(factory.makeSystemResult.solvesCount, 0)
    }

    static var allTests = [
        ("testAnySolverAndEquations_findActivatedVariablesInEquations_returnExpectedResult",
         testAnySolverAndEquations_findActivatedVariablesInEquations_returnExpectedResult),
        ("testAnySolverAndEquationsWithRepeatedVariables_findActivatedVariablesInEquations_returnEmptyResult",
         testAnySolverAndEquationsWithRepeatedVariables_findActivatedVariablesInEquations_returnEmptyResult),
        ("testAnySolverAndEquationsOnlyWithConstants_findActivatedVariablesInEquations_returnEmptyResult",
         testAnySolverAndEquationsOnlyWithConstants_findActivatedVariablesInEquations_returnEmptyResult)
    ]
}
