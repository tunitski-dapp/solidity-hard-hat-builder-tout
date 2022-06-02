// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "hardhat/console.sol";

struct UserProfile{
    uint256 lastMessageAt;
    uint256 maxMessageAmount;
    uint256 messageCount;
}

struct Message {
    address waver;
    string message;
    uint256 timestamp;
}

contract MessagesPortal {
    event NewMessage(address indexed from, uint256 timestamp, string message);

    event BuyMessage(address indexed from, uint8 acount);

    mapping(address => UserProfile) public messageStore;

    address payable owner;

    Message[] messageList;

    constructor() payable {
        owner = payable(msg.sender);
    }

    function sendMessage(string memory _message) public {
        UserProfile storage userMessage = messageStore[msg.sender];

        require(
            userMessage.maxMessageAmount > userMessage.messageCount,
            "You can not send message, because you limit is reached"
        );
        
        userMessage.lastMessageAt = block.timestamp;
        userMessage.messageCount++;

        messageList.push(Message(msg.sender, _message, block.timestamp));

        emit NewMessage(msg.sender, block.timestamp, _message);
    }

    function getMessagesCount() public view returns (uint256){
        return messageList.length;
    }

    function cleanMessages() public {
        require(owner == msg.sender);
        delete messageList;
    }

    function getUserProfile() external view returns(UserProfile memory) {
        return messageStore[msg.sender];
    }

    function buyMessages() public payable {
        require(msg.value >= 1 ether, "not ehought ether");

        (bool success, ) = owner.call{value: msg.value }("");
        require(success, "Failed to withdraw money from contract.");
        
        uint8 count = 5;

        UserProfile storage userMessage = messageStore[msg.sender];
        userMessage.maxMessageAmount += count;

        emit BuyMessage(msg.sender, count);
    }

    function getMessages() public view returns(Message[] memory){
        return messageList;
    }

    function destroyContract() external {
        require(owner == msg.sender);
        selfdestruct(owner);
    }
}
