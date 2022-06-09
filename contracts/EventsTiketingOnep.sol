// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";

struct EventDetails {
    uint256 tiketAmount;
    uint256 tiketPrice;
    string description;
}

contract EventTiketing {
    using Counters for Counters.Counter;

    Counters.Counter private eventIds;

    EventDetails[] private eventDetails;

    // who => eventId
    mapping(address => uint256) eventOwner;

    mapping(uint256 => uint256) enumerableEventId;

    constructor() {
        //
    }

    function createNewEvent(uint256 _amountTikets) external {
        uint256 newEventId = eventIds.current();
        // _mint(msg.sender, newEventId, _amountTikets, "");

        eventIds.increment();
    }

    function totalSupply() external view returns (uint256) {
        return eventIds.current();
    }
}
