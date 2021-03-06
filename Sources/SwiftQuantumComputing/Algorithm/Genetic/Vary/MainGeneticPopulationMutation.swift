//
//  MainGeneticPopulationMutation.swift
//  SwiftQuantumComputing
//
//  Created by Enrique de la Torre on 19/02/2019.
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

struct MainGeneticPopulationMutation {

    // MARK: - Internal types

    typealias RandomElements = ([Fitness.EvalCircuit], Int) -> [Fitness.EvalCircuit]

    // MARK: - Private properties

    private let tournamentSize: Int
    private let fitness: Fitness
    private let mutation: GeneticCircuitMutation
    private let evaluator: GeneticCircuitEvaluator
    private let score: GeneticCircuitScore
    private let randomElements: RandomElements

    // MARK: - Internal init methods

    init(tournamentSize: Int,
         fitness: Fitness,
         mutation: GeneticCircuitMutation,
         evaluator: GeneticCircuitEvaluator,
         score: GeneticCircuitScore,
         randomElements: @escaping RandomElements = { $0.randomElements(count: $1) } ) {
        assert(tournamentSize > 0, "tournamentSize has to be bigger than zero")

        self.tournamentSize = tournamentSize
        self.fitness = fitness
        self.mutation = mutation
        self.evaluator = evaluator
        self.score = score
        self.randomElements = randomElements
    }
}

// MARK: - GeneticPopulationMutation methods

extension MainGeneticPopulationMutation: GeneticPopulationMutation {
    func applied(to population: [Fitness.EvalCircuit]) -> Result<Fitness.EvalCircuit?, EvolveCircuitError> {
        let sample = randomElements(population, tournamentSize)
        guard let winner = fitness.fittest(in: sample) else {
            return .success(nil)
        }

        switch mutation.execute(winner.circuit) {
        case .success(let mutated):
            guard let mutated = mutated else {
                return .success(nil)
            }

            switch evaluator.evaluateCircuit(mutated) {
            case .success(let evaluation):
                return .success((score.calculate(evaluation), mutated))
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
}
