//
//  Matrix+Oracle.swift
//  SwiftQuantumComputing
//
//  Created by Enrique de la Torre on 09/01/2019.
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

import ComplexModule
import Foundation

// MARK: - Main body

extension Matrix {

    // MARK: - Internal class methods

    enum MakeOracleError: Error {
        case controlCountHasToBeBiggerThanZero
        case matrixIsNotSquare
        case matrixRowCountHasToBeAPowerOfTwo
    }

    static func makeOracle(truthTable: [String],
                           controlCount: Int,
                           controlledMatrix: Matrix) -> Result<Matrix, MakeOracleError> {
        guard controlledMatrix.isSquare else {
            return .failure(.matrixIsNotSquare)
        }

        guard controlledMatrix.rowCount.isPowerOfTwo else {
            return .failure(.matrixRowCountHasToBeAPowerOfTwo)
        }

        guard controlCount > 0 else {
            return .failure(.controlCountHasToBeBiggerThanZero)
        }

        let truthTableAsInts = Matrix.truthTableAsInts(truthTable)
        let controlledMatrixSize = controlledMatrix.columnCount
        let columnCount = Int.pow(2, controlCount) * controlledMatrixSize

        var rows: [[Complex<Double>]] = []
        for controlValue in 0..<Int.pow(2, controlCount) {
            let isControlValueTrue = truthTableAsInts.contains(controlValue)

            for ri in 0..<controlledMatrixSize {
                var row = Array(repeating: Complex<Double>.zero, count: columnCount)

                for ci in 0..<controlledMatrixSize {
                    row[controlValue * controlledMatrixSize + ci] = (
                        isControlValueTrue ? controlledMatrix[ri, ci] : (ri == ci ? .one : .zero)
                    )
                }

                rows.append(row)
            }
        }

        return .success(try! Matrix(rows)) 
    }
}

// MARK: - Private body

private extension Matrix {

    // MARK: - Private class methods

    static func truthTableAsInts(_ truthTable: [String]) -> [Int] {
        var result: [Int] = []

        for truth in truthTable {
            guard let truthAsInt = Int(truth, radix: 2) else {
                continue
            }

            result.append(truthAsInt)
        }

        return result
    }
}
