// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./Car.sol";

// e70a5e8d08034fe31b8e95f6592ef42ffb666cd558d9fb852679ef976e

contract LewisHamiltonBkup is Car {
  uint256 turns = 0;
  bool shellPurchased = false;
  Monaco.CarData ourCar;
  Monaco.CarData leadCar;
  uint256 ourCarIndex;
  uint256 firstLap = 750;
  
  constructor(Monaco _monaco) Car(_monaco) {}

  function buyAcc() internal {
    uint256 costPerAcc = monaco.getAccelerateCost(1);
    uint256 maxCost = 14;
    if (leadCar.y > 500) maxCost = 22;
    if (leadCar.y > 800) maxCost = 27;
    if (leadCar.y > 850) maxCost = 37;
    if (leadCar.y > 900) maxCost = 47;
    if (leadCar.y > 950) maxCost = 67;
    if (leadCar.y > 970) maxCost = 97;
    if (leadCar.y - ourCar.y > 100 && leadCar.y > 750) maxCost = maxCost * 3 / 2; // don't get left behind
    if (leadCar.y - ourCar.y > 150 && leadCar.y > 650) maxCost = maxCost * 3 / 2;
    if (leadCar.y - ourCar.y > 200 && leadCar.y > 400) maxCost = maxCost * 3 / 2;
    if (leadCar.y - ourCar.y > 400) maxCost = maxCost * 3 / 2;
    if (leadCar.y > firstLap && ourCarIndex >= 1) maxCost = maxCost * 3 / 2; // want to be in first
    if (leadCar.y > firstLap && ourCarIndex >= 2) maxCost = maxCost * 3 / 2; // want to be in second
    if (leadCar.y < firstLap && ourCar.speed < 7 && costPerAcc < maxCost && ourCar.balance > monaco.getAccelerateCost(3)) {
      // First part get moving
      ourCar.balance -= uint24(monaco.buyAcceleration(3));
    } else if (leadCar.y < firstLap && ourCar.speed < 26 && costPerAcc < maxCost / 2 && ourCar.balance > monaco.getAccelerateCost(3)) {
      // First part buy cheap
      if (ourCar.balance > monaco.getAccelerateCost(99)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(14));
      } else if (ourCar.balance > monaco.getAccelerateCost(56)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(9));
      } else if (ourCar.balance > monaco.getAccelerateCost(38)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(6));
      } else if (ourCar.balance > monaco.getAccelerateCost(18)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(2));
      } else if (ourCar.balance > monaco.getAccelerateCost(8)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(1));
      }
    } else if (leadCar.y < firstLap && ourCar.speed < 26) {
      // First part of race maintain 2nd
      if (ourCar.balance < 6000) maxCost = maxCost / 2;
      if (leadCar.y - ourCar.y > 200) maxCost = maxCost * 2;
      if (costPerAcc < maxCost) {
        uint256 acc2 = leadCar.speed - ourCar.speed;
        if (leadCar.y - ourCar.y > 50) acc2 += 1;
        if (acc2 + ourCar.speed > 26) acc2 = acc2 / 2;
        if (acc2 > 0 && ourCar.balance > monaco.getAccelerateCost(acc2)) {
          ourCar.balance -= uint24(monaco.buyAcceleration(acc2));
        }
      }
    } else if (leadCar.y > firstLap && costPerAcc < maxCost && ourCar.speed < 56) {
      // Second part standard
      if (ourCar.balance > monaco.getAccelerateCost(99)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(17));
      } else if (ourCar.balance > monaco.getAccelerateCost(56)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(9));
      } else if (ourCar.balance > monaco.getAccelerateCost(38)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(7));
      } else if (ourCar.balance > monaco.getAccelerateCost(18)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(6));
      } else if (ourCar.balance > monaco.getAccelerateCost(8)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(3));
      }
    } else if (leadCar.y > firstLap && costPerAcc < maxCost * 2 && ourCar.speed < 56) {
      // Second part cheap
      if (ourCar.balance > monaco.getAccelerateCost(56)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(17));
      } else if (ourCar.balance > monaco.getAccelerateCost(38)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(11));
      } else if (ourCar.balance > monaco.getAccelerateCost(12)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(6));
      } else if (ourCar.balance > monaco.getAccelerateCost(4)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(3));
      }
    } else if (leadCar.y > firstLap && ourCar.speed < 4 && costPerAcc < maxCost && ourCar.speed < 9) {
      // Second part get moving
      if (ourCar.balance > monaco.getAccelerateCost(12)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(9));
      } else if (ourCar.balance > monaco.getAccelerateCost(4)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(3));
      }
    } else if (leadCar.y > 800 || (leadCar.y > 750 && ourCar.balance > 7000)) {
      // Speed Up
      if (ourCar.balance > monaco.getAccelerateCost(24)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(6));
      } else if (ourCar.balance > monaco.getAccelerateCost(12)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(3));
      } else if (ourCar.balance > monaco.getAccelerateCost(6)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(2));
      } else if (ourCar.balance > monaco.getAccelerateCost(4)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(1));
      }
    }

    if (leadCar.y > 960 || (leadCar.y > 930 && ourCar.balance > 4000)) {
      // Sprint finish
      if (ourCar.balance > monaco.getAccelerateCost(24)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(12));
      } else if (ourCar.balance > monaco.getAccelerateCost(12)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(6));
      } else if (ourCar.balance > monaco.getAccelerateCost(6)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(3));
      } else if (ourCar.balance > monaco.getAccelerateCost(4)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(2));
      } else if (ourCar.balance > monaco.getAccelerateCost(1)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(1));
      }
    }
  }

  function fireShell() internal {
    uint256 shellCost = monaco.getShellCost(1);
    uint256 maxShellCost = 150;
    if (leadCar.y < firstLap) maxShellCost = 20;
    if (leadCar.y > 850) maxShellCost = 250;
    if (leadCar.y > 900) maxShellCost = 350;
    if (leadCar.y > 930) maxShellCost = 750;
    if (leadCar.y > 960) maxShellCost = 1200;
    if (leadCar.y > 980) maxShellCost = 1800;
    if (ourCarIndex == 2 && leadCar.y < 900) maxShellCost = maxShellCost * 2 / 3;
    if (ourCar.balance > shellCost && shellCost < maxShellCost) {
      monaco.buyShell(1);
    }
  }

  function takeYourTurn(Monaco.CarData[] calldata allCars, uint256 _ourCarIndex) external override {
    ourCarIndex = _ourCarIndex;
    ourCar = allCars[ourCarIndex];
    leadCar = allCars[0];
    turns += 1;
    buyAcc();
    if (ourCarIndex != 0 && allCars[ourCarIndex - 1].speed >= 14) {
      fireShell();
    } else if (ourCarIndex != 0 && leadCar.y > 800 && allCars[ourCarIndex - 1].speed >= 9) {
      fireShell();
    } else if (ourCarIndex != 0 && leadCar.y > 950 && allCars[ourCarIndex - 1].speed >= 4) {
      fireShell();
    } else if (ourCarIndex != 0 && allCars[ourCarIndex - 1].y - ourCar.y > 94 && leadCar.y > firstLap && allCars[ourCarIndex - 1].speed >= 9) {
      fireShell();
    }
  }
}
