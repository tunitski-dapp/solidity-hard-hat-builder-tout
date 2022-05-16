// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "hardhat/console.sol";

contract WavePortal {
    uint256 amountWaves;

    event NewWave(address indexed from, uint256 timestamp, string message);

    struct Wave {
        address waver; // The address of the user who waved.
        string message; // The message the user sent.
        uint256 timestamp; // The timestamp when the user waved.
    }

    Wave[] waves;

    constructor() {
        console.log("This is my smart(dumb) contact");
    }

    function wave(string memory _message) public {
        amountWaves += 1;
        console.log("%s has waved w/ message %s", msg.sender, _message);

        waves.push(Wave(msg.sender, _message, block.timestamp));

        emit NewWave(msg.sender, block.timestamp, _message);
    }

    function getTotalWaves() public view returns (uint256){
        console.log("We have %d total waves!", amountWaves);
        return amountWaves;
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }
}
