// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract Token is ERC20 {
    constructor() ERC20("ERC20 Token", "TKN") {
        _mint(msg.sender, 100_000_000_000 * 10**18 );
    }
}