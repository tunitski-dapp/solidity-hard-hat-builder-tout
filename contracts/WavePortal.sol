// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "hardhat/console.sol";

struct Messages{
    uint256 lastWavedAt;
    uint256 maxWaveAmount;
    uint256 wavedCount;
}

struct Wave {
    address waver; // The address of the user who waved.
    string message; // The message the user sent.
    uint256 timestamp; // The timestamp when the user waved.
}

contract WavePortal {
    event NewWave(address indexed from, uint256 timestamp, string message);

    mapping(address => Messages) public messageStore;

    address payable owner;

    Wave[] public waves;

    constructor() payable {
        owner = payable(msg.sender);
    }

    function wave(string memory _message) public {
        Messages memory userMessage = messageStore[msg.sender];

        require(
            userMessage.maxWaveAmount <= userMessage.wavedCount,
            "You can not send message, because you limit is reached"
        );
        
        userMessage.lastWavedAt = block.timestamp;
        userMessage.wavedCount++;

        waves.push(Wave(msg.sender, _message, block.timestamp));

        emit NewWave(msg.sender, block.timestamp, _message);
    }

    function getTotalWaves() public view returns (uint256){
        return waves.length;
    }

    function cleanMessages() public {
        require(owner == msg.sender);
        delete waves;
    }

    function getUserProfile() external view returns(Messages memory) {
        return messageStore[msg.sender];
    }

    function byeMoreMessages() public payable {
        (bool success, ) = owner.call{value: 10 ether }("");
        require(success, "Failed to withdraw money from contract.");
        
        Messages memory userMessage = messageStore[msg.sender];
        userMessage.maxWaveAmount += 5;
    }

    function destroyContract() external {
        require(owner == msg.sender);
        selfdestruct(owner);
    }
}
