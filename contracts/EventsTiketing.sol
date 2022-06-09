// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";

struct EventDetails {
    uint256 ticketAmount;
    uint256 ticketPrice;
    uint256 eventDate;
    string eventName;
    string description;
    string[] imageUrls;
}

contract EventTiketing {
    using Counters for Counters.Counter;

    event NewEvent(address indexed owner, uint256 indexed eventId);
    Counters.Counter private eventIds;

    //  EventDetails[] private eventDetails;

    // eventId => address
    mapping(uint256 => address) eventOwner;

    // address => [0, 1, 2] => eventId
    mapping(address => mapping(uint256 => uint256)) enumerableEventId;

    // address => count events
    mapping(address => uint256) eventBalances;

    constructor() {}

    function createEmptyEvent() external {
        uint256 newEventId = eventIds.current();

        eventOwner[newEventId] = msg.sender;
        enumerableEventId[msg.sender][balanceOf(msg.sender)] = newEventId;

        eventBalances[msg.sender]++;

        eventIds.increment();

        emit NewEvent(msg.sender, newEventId);
        // eventDetails.push(
        //     EventDetails(_amountTickets, _ticketPrice, _description, _imageUrls)
        // );
    }

    function balanceOf(address to) public view returns (uint256) {
        return eventBalances[to];
    }

    function totalSupply() public view returns (uint256) {
        return eventIds.current();
    }

    function tokenByIndex(uint256 index)
        public
        view
        returns (EventDetails memory)
    {
        require(index < totalSupply(), "Wrong index!");

        return eventDetails[index];
    }

    function tokenOfOwnerByIndex(address owner, uint256 index)
        public
        view
        returns (EventDetails memory)
    {
        require(index < balanceOf(owner), "Wrong index!");

        return eventDetails[enumerableEventId[owner][index]];
    }
}
