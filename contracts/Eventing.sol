// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

struct Ticket {
    bool enable;
    uint256 row;
    uint256 seet;
}

struct EventDetails {
    string name;
}

contract Eventing is ERC721Enumerable {
    using Counters for Counters.Counter;
    Counters.Counter private ticketIds;
    Counters.Counter private eventIds;

    // price 0 mean not for sale
    mapping(uint256 => uint256) private ticketsPrice;

    mapping(uint256 => address) private eventOwner;
    mapping(uint256 => uint256) private eventBalances;
    mapping(uint256 => uint256) private eventStartIndex;

    Ticket[] private ticketsDetails;
    EventDetails[] private eventDetails;

    event NewEvent(address indexed owner, uint256 indexed eventId, string name);

    constructor() ERC721("Ticketing", "TCK") {}

    function createEvent(
        uint256 _ticketsAmount,
        uint256 _seetsOnRow,
        uint256 _startPrice,
        string calldata name
    ) external {
        uint256 eventId = eventIds.current();

        eventOwner[eventId] = msg.sender;
        eventStartIndex[eventId] = ticketIds.current();
        eventBalances[eventId] = _ticketsAmount;

        eventDetails.push(EventDetails(name));

        mintBatchTicket(msg.sender, _ticketsAmount, _seetsOnRow, _startPrice);

        eventIds.increment();
    }

    function getEventAmount() external view returns (uint256) {
        return eventIds.current();
    }

    function getEventDetail(uint256 _eventId)
        external
        view
        returns (EventDetails memory details, address owner)
    {
        details = eventDetails[_eventId];
        owner = eventOwner[_eventId];
    }

    function getAllEventTickets(uint256 eventId)
        external
        view
        returns (uint256 startIndex, uint256 lenght)
    {
        startIndex = eventStartIndex[eventId];
        lenght = eventBalances[eventId];
    }

    function mintBatchTicket(
        address _author,
        uint256 _ticketsAmount,
        uint256 _seetsOnRow,
        uint256 _startPrice
    ) internal {
        uint256 row = 1;

        uint256 currentSeetInRow = 0;

        uint256 newItemId = ticketIds.current();

        for (uint256 i = 0; i < _ticketsAmount; i++) {
            currentSeetInRow += 1;

            if (currentSeetInRow > _seetsOnRow) {
                currentSeetInRow = 1;
                row++;
            }

            _mint(_author, newItemId);

            ticketsDetails.push(Ticket(true, row, currentSeetInRow));

            ticketsPrice[newItemId] = _startPrice;

            ticketIds.increment();
            newItemId = ticketIds.current();
        }
    }

    function buyTicket(uint256 _ticketId) external payable {
        require(ticketsPrice[_ticketId] > 0, "Ticket not for sale!");
        require(msg.value >= ticketsPrice[_ticketId], "Not enought money!");

        address ticketOwner = ownerOf(_ticketId);

        (bool success, ) = ticketOwner.call{value: msg.value}("");

        require(success, "Payment is failed!");

        _transfer(ticketOwner, msg.sender, _ticketId);

        ticketsPrice[_ticketId] = 0;
    }

    function sellTicket(uint256 _ticketId, uint256 _price) external {
        require(ownerOf(_ticketId) == msg.sender, "You not a owner!");
        ticketsPrice[_ticketId] = _price;
    }

    function getTicketDetails(uint256 _ticketId)
        external
        view
        returns (
            Ticket memory ticket,
            uint256 price,
            address owner
        )
    {
        require(_ticketId < ticketsDetails.length);

        ticket = ticketsDetails[_ticketId];
        price = ticketsPrice[_ticketId];
        owner = ownerOf(_ticketId);
    }

    //////////////////////////validation///////////////////////
    using ECDSA for bytes32;

    string private constant APPROVE_MSG_PREFIX = "Approve use token:";

    mapping(bytes => bool) usedSignatures;

    function useTicket(uint256 _ticketId, bytes memory _signature) external {
        require(
            ownerOf(_ticketId) ==
                getMessageHashForToken(_ticketId)
                    .toEthSignedMessageHash()
                    .recover(_signature),
            "Wrong signature!"
        );

        require(!usedSignatures[_signature], "This signature was use before!");

        usedSignatures[_signature] = true;

        // use ticket
        Ticket storage ticket = ticketsDetails[_ticketId];
        ticket.enable = false;
    }

    function getMessageHashForToken(uint256 _tokenId)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(APPROVE_MSG_PREFIX, _tokenId));
    }
}
