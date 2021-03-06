//
//  MainGeneticFactory.swift
//  SwiftQuantumComputing
//
//  Created by Enrique de la Torre on 02/02/2019.
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

public struct MainGeneticFactory {

    // MARK: - Private properties

    private let initialPopulationFactory: InitialPopulationProducerFactory
    private let fitness: Fitness
    private let reproductionFactory: GeneticPopulationReproductionFactory
    private let oracleFactory: OracleCircuitFactory

    // MARK: - Private class properties

    private static let logger = Logger()

    // MARK: - Public init methods

    /// Initialize a `MainGeneticFactory` instance
    public init(circuitFactory: CircuitFactory = MainCircuitFactory()) {
        let generatorFactory = MainGeneticGatesRandomizerFactory()
        let statevectorFactory = MainCircuitStatevectorFactory()
        let oracleFactory = MainOracleCircuitFactory()
        let useCaseEvaluatorFactory = MainGeneticUseCaseEvaluatorFactory(circuitFactory: circuitFactory,
                                                                         statevectorFactory: statevectorFactory,
                                                                         oracleFactory:oracleFactory)
        let evaluatorFactory = MainGeneticCircuitEvaluatorFactory(factory: useCaseEvaluatorFactory)
        let score = MainGeneticCircuitScore()
        let producerFactory = MainInitialPopulationProducerFactory(generatorFactory: generatorFactory,
                                                                   evaluatorFactory: evaluatorFactory,
                                                                   score: score)

        let fitness = MainFitness()
        let circuitCrossover = MainGeneticCircuitCrossover()
        let crossoverFactory = MainGeneticPopulationCrossoverFactory(fitness: fitness,
                                                                     crossover: circuitCrossover,
                                                                     score: score)
        let circuitMutationFactory = MainGeneticCircuitMutationFactory(factory: generatorFactory)
        let mutationFactory = MainGeneticPopulationMutationFactory(fitness: fitness,
                                                                   factory: circuitMutationFactory,
                                                                   score: score)
        let reproductionFactory = MainGeneticPopulationReproductionFactory(evaluatorFactory: evaluatorFactory,
                                                                           crossoverFactory: crossoverFactory,
                                                                           mutationFactory: mutationFactory)

        self.init(initialPopulationFactory: producerFactory,
                  fitness: fitness,
                  reproductionFactory: reproductionFactory,
                  oracleFactory: oracleFactory)
    }

    // MARK: - Internal init methods

    init(initialPopulationFactory: InitialPopulationProducerFactory,
         fitness: Fitness,
         reproductionFactory: GeneticPopulationReproductionFactory,
         oracleFactory: OracleCircuitFactory) {
        self.initialPopulationFactory = initialPopulationFactory
        self.fitness = fitness
        self.reproductionFactory = reproductionFactory
        self.oracleFactory = oracleFactory
    }
}


// MARK: - GeneticFactory methods

extension MainGeneticFactory: GeneticFactory {

    /// Check `GeneticFactory.evolveCircuit(configuration:useCases:gates:)`
    public func evolveCircuit(configuration config: GeneticConfiguration,
                              useCases: [GeneticUseCase],
                              gates: [ConfigurableGate]) -> Result<EvolvedCircuit, EvolveCircuitError> {
        let initSize = config.populationSize.first!
        let maxSize = config.populationSize.last!
        let maxDepth = config.depth.last!

        guard let firstCase = useCases.first else {
            return .failure(.useCaseListIsEmpty)
        }

        let qubitCount = firstCase.circuit.qubitCount
        guard useCases.reduce(true, { $0 && $1.circuit.qubitCount == qubitCount })  else {
            return .failure(.useCasesDoNotSpecifySameCircuitQubitCount)
        }

        let initialPopulation = initialPopulationFactory.makeProducer(qubitCount: qubitCount,
                                                                      threshold: config.threshold,
                                                                      useCases: useCases,
                                                                      gates: gates)

        let reproduction = reproductionFactory.makeReproduction(qubitCount: qubitCount,
                                                                tournamentSize: config.tournamentSize,
                                                                mutationProbability: config.mutationProbability,
                                                                threshold: config.threshold,
                                                                maxDepth: maxDepth,
                                                                useCases: useCases,
                                                                gates: gates)

        MainGeneticFactory.logger.info("Producing initial population...")
        var population: [Fitness.EvalCircuit]!
        switch initialPopulation.execute(size: initSize, depth: config.depth) {
        case .success(let result):
            population = result
        case .failure(let error):
            return .failure(error)
        }
        MainGeneticFactory.logger.info("Initial population completed")

        var candidate = fitness.fittest(in: population)!

        var currGen = 0
        let errProb = config.errorProbability
        let genCount = config.generationCount
        while (candidate.eval > errProb) && (currGen < genCount) && (population.count < maxSize) {
            MainGeneticFactory.logger.info("Init. generation \(currGen)...")

            switch reproduction.applied(to: population) {
            case .success(let offspring):
                if (offspring.isEmpty) {
                    MainGeneticFactory.logger.debug("evolveCircuit: empty offspr.")
                } else {
                    population.append(contentsOf: offspring)
                    candidate = fitness.fittest(in: population)!
                }
            case .failure(let error):
                return .failure(error)
            }

            MainGeneticFactory.logger.info("Generation \(currGen) completed. Population: \(population.count). Evaluation: \(String(candidate.eval))")

            currGen += 1
        }

        let circuit = try! oracleFactory.makeOracleCircuit(geneticCircuit: candidate.circuit,
                                                           useCase: firstCase).get()

        return .success((candidate.eval, circuit.circuit, circuit.oracleAt))
    }
}
