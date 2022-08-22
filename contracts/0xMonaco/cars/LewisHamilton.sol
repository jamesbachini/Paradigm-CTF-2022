// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./Car.sol";

// e70a5e8d08034fe31b8e95f6592ef42ffb666cd558d9fb852679ef976e

contract LewisHamilton is Car {
  Monaco.CarData ourCar;
  Monaco.CarData leadCar;
  Monaco.CarData secondCar;
  uint256 ourCarIndex;

  constructor(Monaco _monaco) Car(_monaco) {}

  function fairValueAcc() internal view returns(uint256) {
    uint256 fairValue = 14;
    fairValue = fairValue * leadCar.y / 100;
    uint256 lapsLeft = 1000 - leadCar.y;
    uint256 expectedBalance = 15 * lapsLeft;
    if (ourCar.balance > expectedBalance) fairValue = fairValue * 3 / 2;
    if (ourCar.balance > expectedBalance * 3 / 2) fairValue = fairValue * 3 / 2;
    if (ourCar.balance > expectedBalance * 2) fairValue = fairValue * 3 / 2;
    if (leadCar.y - ourCar.y > 100) fairValue = fairValue * 3 / 2;
    if (leadCar.y - ourCar.y > 200) fairValue = fairValue * 3 / 2;
    if (leadCar.y - ourCar.y > 300) fairValue = fairValue * 3 / 2;
    if (ourCarIndex == 0 ) fairValue = fairValue / 2;
    return fairValue;
  }

  function fairShellValue() internal view returns(uint256) {
    uint256 fairValue = 200;
    fairValue = fairValue * leadCar.y / 100;
    uint256 lapsLeft = 1000 - leadCar.y;
    uint256 expectedBalance = 15 * lapsLeft;
    if (ourCar.balance > expectedBalance * 2) fairValue = fairValue * 3 / 2;

    if ((ourCarIndex == 1 && leadCar.speed > 26) || (ourCarIndex == 2 && secondCar.speed > 26)) {
      fairValue = fairValue * 3;
    } else if ((ourCarIndex == 1 && leadCar.speed > 17) || (ourCarIndex == 2 && secondCar.speed > 17)) {
      fairValue = fairValue * 2;
    } else if ((ourCarIndex == 1 && leadCar.speed > 6) || (ourCarIndex == 2 && secondCar.speed > 6)) {
      fairValue = fairValue * 3 / 2;
    }
    if (leadCar.y - ourCar.y > 100) fairValue = fairValue * 3 / 2;
    if (leadCar.y - ourCar.y > 200) fairValue = fairValue * 3 / 2;
    if (leadCar.y - ourCar.y > 300) fairValue = fairValue * 3 / 2;
    if (ourCarIndex == 0) fairValue = 1;
    return fairValue;
  }

  function idealSpeed() internal view returns(uint256) {
    uint256 targetSpeed = 4;
    targetSpeed = targetSpeed * leadCar.y / 100;
    if (ourCarIndex == 2) targetSpeed += 6;
    if (ourCarIndex == 1) targetSpeed += 3;
    if (leadCar.y - ourCar.y > 100) targetSpeed = targetSpeed * 3 / 2;
    if (leadCar.y - ourCar.y > 200) targetSpeed = targetSpeed * 3 / 2;
    if (leadCar.speed > targetSpeed) targetSpeed = leadCar.speed;
    if (leadCar.y <= 650 && targetSpeed > 9) targetSpeed = 9;
    if (leadCar.y <= 450 && targetSpeed > 4) targetSpeed = 4;
    if (leadCar.y <= 900 && targetSpeed > 36) targetSpeed = 36;
    if (targetSpeed > 62) targetSpeed = 62;
    return targetSpeed;
  }

  function strategyOne() internal {
    uint256 fairValue = fairValueAcc();
    uint256 targetSpeed = idealSpeed();
    uint256 costPerAcc = monaco.getAccelerateCost(1);
    if (costPerAcc < fairValue / 2 && ourCar.speed < targetSpeed && ourCarIndex != 0) {
      uint256 accPurchase = targetSpeed - ourCar.speed;
      if (ourCar.balance / 8 > monaco.getAccelerateCost(accPurchase)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(accPurchase));
      } else if (accPurchase > 0 && ourCar.balance / 8 > monaco.getAccelerateCost(1)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(1));
      }
    }
  }

  function strategyTwo() internal {
    uint256 fairValue = fairValueAcc();
    uint256 targetSpeed = idealSpeed();
    uint256 costPerAcc = monaco.getAccelerateCost(1);
    if (costPerAcc < fairValue && ourCar.speed < targetSpeed && ourCarIndex != 0) {
      uint256 accPurchase = targetSpeed - ourCar.speed;
      if (accPurchase > 0 && ourCar.balance / 4 > monaco.getAccelerateCost(accPurchase)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(accPurchase));
      } else if (accPurchase > 0 && ourCar.balance / 8 > monaco.getAccelerateCost(2)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(2));
      }
    }
    uint256 shellCost = monaco.getShellCost(1);
    uint256 maxShellCost = fairShellValue();
    if (shellCost < maxShellCost && ourCar.balance > shellCost) {
      monaco.buyShell(1);
    }
  }

  function strategyThree() internal {
    uint256 fairValue = fairValueAcc();
    uint256 targetSpeed = idealSpeed();
    uint256 costPerAcc = monaco.getAccelerateCost(1);
    if (costPerAcc < fairValue && ourCar.speed < targetSpeed && ourCarIndex != 0) {
      uint256 accPurchase = targetSpeed - ourCar.speed;
      if (accPurchase > 0 && ourCar.balance / 2 > monaco.getAccelerateCost(accPurchase)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(accPurchase));
      } else if (accPurchase > 0 && ourCar.balance / 2 > monaco.getAccelerateCost(accPurchase/3)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(accPurchase/3));
      } else if (accPurchase > 0 && ourCar.balance / 8 > monaco.getAccelerateCost(3)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(3));
      } else if (ourCarIndex == 2) {
        ourCar.balance -= uint24(monaco.buyAcceleration(3));
      }
    }
    uint256 shellCost = monaco.getShellCost(1);
    uint256 maxShellCost = fairShellValue();
    if (shellCost < maxShellCost && ourCar.balance > shellCost) {
      monaco.buyShell(1);
    }
  }

  function strategyFour() internal {
    uint256 fairValue = fairValueAcc();
    uint256 targetSpeed = idealSpeed();
    uint256 costPerAcc = monaco.getAccelerateCost(1);
    if (costPerAcc < fairValue && ourCar.speed < targetSpeed) {
      uint256 accPurchase = targetSpeed - ourCar.speed;
      if (accPurchase > 0 && ourCar.balance > monaco.getAccelerateCost(accPurchase)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(accPurchase));
      } else if (accPurchase > 0 && ourCar.balance > monaco.getAccelerateCost(accPurchase/3)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(accPurchase/3));
      } else if (accPurchase > 0 && ourCar.balance / 8 > monaco.getAccelerateCost(3)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(3));
      } else if (ourCarIndex >= 1) {
        ourCar.balance -= uint24(monaco.buyAcceleration(1));
      }
    }
    uint256 shellCost = monaco.getShellCost(1);
    uint256 maxShellCost = fairShellValue();
    if (shellCost < maxShellCost && ourCar.balance > shellCost) {
      monaco.buyShell(1);
    }
  }

  function strategyFive() internal {
    uint256 fairValue = fairValueAcc();
    uint256 targetSpeed = idealSpeed();
    uint256 costPerAcc = monaco.getAccelerateCost(1);
    if ((costPerAcc < fairValue * 2 || leadCar.y > 960) && ourCar.speed < targetSpeed) {
      uint256 accPurchase = targetSpeed - ourCar.speed;
      if (accPurchase > 0 && ourCar.balance > monaco.getAccelerateCost(accPurchase)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(accPurchase));
      } else if (accPurchase > 0 && ourCar.balance > monaco.getAccelerateCost(accPurchase/3)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(accPurchase/3));
      } else if (accPurchase > 0 && ourCar.balance > monaco.getAccelerateCost(3)) {
        ourCar.balance -= uint24(monaco.buyAcceleration(3));
      } else if (ourCarIndex >= 1) {
        ourCar.balance -= uint24(monaco.buyAcceleration(1));
      }
    }
    uint256 shellCost = monaco.getShellCost(1);
    uint256 maxShellCost = fairShellValue();
    if (shellCost < maxShellCost * 2 && ourCar.balance > shellCost) {
      monaco.buyShell(1);
    }
  }

  function takeYourTurn(Monaco.CarData[] calldata allCars, uint256 _ourCarIndex) external override {
    ourCarIndex = _ourCarIndex;
    ourCar = allCars[ourCarIndex];
    leadCar = allCars[0];
    secondCar = allCars[1];
    if (leadCar.y <= 400) {
      strategyOne();
    } else if (leadCar.y > 400) {
      strategyTwo();
    } else if (leadCar.y > 700) {
      strategyThree();
    } else if (leadCar.y > 850) {
      strategyFour();
    } else if (leadCar.y > 920) {
      strategyFive();
    }
  }
}
