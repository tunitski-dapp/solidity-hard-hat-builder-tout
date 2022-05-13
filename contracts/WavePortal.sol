// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "hardhat/console.sol";

contract WavePortal {
    uint256 amountWaves;

    constructor() {
        console.log("This is my smart(dumb) contact");
    }

    function wave() public {
        amountWaves += 1;
        console.log("%s has waved!", msg.sender);
    }

    function getTotalWaves() public view returns (uint256){
        console.log("We have %d total waves!", amountWaves);
        return amountWaves;
    }
}
