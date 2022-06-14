// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";

struct EventDetails {
    string name;
    string description;
    uint256 date;
    uint256 ticketAmount;
    uint256 ticketPrice;
    string[] imageUrls;
}

contract EventTicketing {
    using Counters for Counters.Counter;

    event NewEvent(
        address indexed owner,
        uint256 indexed eventId,
        string name,
        string description,
        uint256 date,
        uint256 ticketAmount,
        uint256 ticketPrice,
        string[] imageUrls
    );

    Counters.Counter private eventIds;

    EventDetails[] private eventDetails;

    // eventId => address
    mapping(uint256 => address) eventOwner;

    // owner address => [0, 1, 2] => eventId
    mapping(address => mapping(uint256 => uint256)) enumerableEventId;

    // owner address => count events
    mapping(address => uint256) eventBalances;

    constructor() {}

    function createEmptyEvent(
        string memory _name,
        string memory _description,
        uint256 _date,
        uint256 _ticketAmount,
        uint256 _ticketPrice,
        string[] memory _imageUrls
    ) external {
        uint256 newEventId = eventIds.current();

        eventOwner[newEventId] = msg.sender;
        enumerableEventId[msg.sender][balanceOf(msg.sender)] = newEventId;

        eventBalances[msg.sender] += 1;

        eventDetails.push(
            EventDetails(
                _name,
                _description,
                _date,
                _ticketAmount,
                _ticketPrice,
                _imageUrls
            )
        );

        eventIds.increment();

        emit NewEvent(
            msg.sender,
            newEventId,
            _name,
            _description,
            _date,
            _ticketAmount,
            _ticketPrice,
            _imageUrls
        );
    }

    function balanceOf() public view returns (uint256) {
        return balanceOf(msg.sender);
    }

    function balanceOf(address to) public view returns (uint256) {
        return eventBalances[to];
    }

    function totalSupply() public view returns (uint256) {
        return eventIds.current();
    }

    /**
        this not like in standart for simplify
     */
    function tokenByIndex(uint256 index)
        public
        view
        returns (EventDetails memory)
    {
        require(index < totalSupply(), "Wrong index!");

        return eventDetails[index];
    }

    function tokenOfOwnerByIndex(uint256 index)
        public
        view
        returns (EventDetails memory)
    {
        return tokenOfOwnerByIndex(msg.sender, index);
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
