// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./Car.sol";

// e70a5e8d08034fe31b8e95f6592ef42ffb666cd558d9fb852679ef976e

contract Hamilton is Car {
    uint256 turns = 0;
    bool shellPurchased = false;
    constructor(Monaco _monaco) Car(_monaco) {}

    function takeYourTurn(Monaco.CarData[] calldata allCars, uint256 ourCarIndex) external override {
        Monaco.CarData memory ourCar = allCars[ourCarIndex];
        turns += 1;
        if (ourCarIndex != 0 && (allCars[0].y > 500 || allCars[1].y > 500 || allCars[2].y > 500)) {
            // strong finish
            uint256 acc = 10;
            if (ourCar.balance > monaco.getAccelerateCost(acc)) ourCar.balance -= uint24(monaco.buyAcceleration(acc));
        } else if (ourCarIndex > 1) {
            // maintain 2nd
            if (allCars[ourCarIndex - 1].speed > 29 && ourCar.balance > monaco.getShellCost(1)) {
                monaco.buyShell(1);
                shellPurchased = true;
            }
            uint256 acc2 = allCars[ourCarIndex - 1].speed - allCars[ourCarIndex].speed;
            if (acc2 > 10) acc2 = 10;
            if (ourCar.balance > monaco.getAccelerateCost(acc2)) ourCar.balance -= uint24(monaco.buyAcceleration(acc2));
        } else if ((allCars[0].y > 900 && allCars[0].speed > 20) || (allCars[0].y > 950 && allCars[0].speed > 10) || allCars[0].y > 980) {
            // sprint finish
            if (ourCar.balance > monaco.getShellCost(1) && shellPurchased == false) {
                monaco.buyShell(1);
                shellPurchased = true;
            }
            uint256 cost = monaco.getAccelerateCost(1);
            uint256 acc3 = ourCar.balance / cost;
            if (ourCar.balance > monaco.getAccelerateCost(acc3)) ourCar.balance -= uint24(monaco.buyAcceleration(acc3));
        }
        if (ourCarIndex != 0 && allCars[ourCarIndex - 1].speed > 10 && allCars[0].y > 700) {
            if (ourCar.balance > monaco.getShellCost(1) && shellPurchased == false) {
                monaco.buyShell(1);
                shellPurchased = true;
            }
        } else if (allCars[ourCarIndex - 1].speed > 30) {
            if (ourCar.balance > monaco.getShellCost(1) && shellPurchased == false) {
                monaco.buyShell(1);
                shellPurchased = true;
            }
        } else if (allCars[0].speed > 30 && ourCarIndex == 1) {
            if (ourCar.balance > monaco.getShellCost(1) && shellPurchased == false) {
                monaco.buyShell(1);
                shellPurchased = true;
            }
        }
        shellPurchased = false;
    }
}
