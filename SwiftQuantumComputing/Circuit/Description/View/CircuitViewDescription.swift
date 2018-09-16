//
//  CircuitViewDescription.swift
//  SwiftQuantumComputing
//
//  Created by Enrique de la Torre on 10/09/2018.
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

// MARK: - Main body

struct CircuitViewDescription {

    // MARK: - Private properties

    private let layers: [[CircuitViewPosition]]

    private var layerCount: Int {
        return layers.count
    }

    private var qubitCount: Int {
        return layers.first!.count
    }

    // MARK: - Init methods

    init?(qubitCount: Int) {
        guard qubitCount > 0 else {
            return nil
        }

        let layer = (0..<qubitCount).map { CircuitViewPosition.qubit(index: $0) }

        self.init(layers: [layer])
    }

    private init(layers: [[CircuitViewPosition]]) {
        self.layers = layers
    }
}

// MARK: - CustomPlaygroundDisplayConvertible methods

extension CircuitViewDescription: CustomPlaygroundDisplayConvertible {
    var playgroundDescription: Any {
        let container = makeContainerView()
        let layerStack = makeLayerStack(container: container)

        for layer in layers {
            let positions = layer.map { $0.makePositionView(size: Constants.positionSize) }
            let positionStack = makePositionStack(positions: positions)

            layerStack.addArrangedSubview(positionStack)
        }

        container.addSubview(layerStack)

        return container
    }
}

// MARK: - CircuitDescription methods

extension CircuitViewDescription: CircuitDescription {
    func applyingDescriber(_ describer: CircuitGateDescribable,
                           inputs: [Int]) -> CircuitViewDescription {
        let gateDescription = describer.gateDescription(with: inputs)
        let layer = gateDescription.makeLayer(qubitCount: qubitCount)

        return CircuitViewDescription(layers: layers + [layer])
    }
}

// MARK: - Private body

private extension CircuitViewDescription {

    // MARK: - Constants

    enum Constants {
        static let positionSize = CGSize(width: 80, height: 80)
    }

    // MARK: - Private methods

    func makeContainerView() -> UIView {
        let width = (CGFloat(layerCount) * Constants.positionSize.width)
        let height = (CGFloat(qubitCount) * Constants.positionSize.height)
        let frame = CGRect(x: 0, y: 0, width: width, height: height)

        return UIView(frame: frame)
    }

    func makeLayerStack(container: UIView) -> UIStackView {
        let stack = UIStackView(frame: container.bounds)
        stack.axis = .horizontal
        stack.distribution = .fillEqually

        return stack
    }

    func makePositionStack(positions: [UIView]) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: positions)
        stack.axis = .vertical
        stack.distribution = .fillEqually

        return stack
    }
}