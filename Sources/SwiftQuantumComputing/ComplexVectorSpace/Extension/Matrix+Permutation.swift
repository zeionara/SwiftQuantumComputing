//
//  Matrix+Permutation.swift
//  SwiftQuantumComputing
//
//  Created by Enrique de la Torre on 26/09/2020.
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

extension Matrix {

    // MARK: - Internal class methods

    enum MakePermutationError: Error {
        case doNotPassAnEmptyPermutation
        case doNotRepeatIndexesInPermutation
        case doNotUseNegativeIndexesInPermutation
    }

    static func makePermutation(permutation: [Int]) -> Result<Matrix, MakePermutationError> {
        let count = permutation.count
        guard count > 0 else {
            return .failure(.doNotPassAnEmptyPermutation)
        }

        guard count == Set(permutation).count else {
            return .failure(.doNotRepeatIndexesInPermutation)
        }

        guard permutation.filter({ $0 < 0 }).isEmpty else {
            return .failure(.doNotUseNegativeIndexesInPermutation)
        }

        let matrix = try! Matrix.makeMatrix(rowCount: count, columnCount: count, value: { row, col in
            return col == permutation[row] ? Complex.one : Complex.zero
        }).get()

        return .success(matrix)
    }
}
