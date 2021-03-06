// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

struct Ticket {
    bool enable;
    uint256 row;
    uint256 seet;
    uint256 price;
}

contract TicketsCollection is ERC721Enumerable {
    using Counters for Counters.Counter;

    Counters.Counter private ticketIds;

    Ticket[] private ticketsDetails;

    mapping(uint256 => bool) private ticketsForSale;

    constructor(
        string memory _eventName,
        uint256 _ticketsAmount,
        uint256 _seetsOnRow,
        uint256 _startPrice
    ) ERC721(_eventName, "TCK") {
        mintBatchTicket(msg.sender, _ticketsAmount, _seetsOnRow, _startPrice);
    }

    function mintBatchTicket(
        address _author,
        uint256 _ticketsAmount,
        uint256 _seetsOnRow,
        uint256 _startPrice
    ) internal {
        uint256 row = 1;

        uint256 currentSeetInRow = 0;

        for (uint256 i = 0; i < _ticketsAmount; i++) {
            currentSeetInRow += 1;

            if (currentSeetInRow > _seetsOnRow) {
                currentSeetInRow = 1;
                row++;
            }

            uint256 newItemId = ticketIds.current();

            _mint(_author, newItemId);

            ticketsDetails.push(
                Ticket(true, row, currentSeetInRow, _startPrice)
            );

            ticketsForSale[newItemId] = true;

            ticketIds.increment();
        }
    }

    function buyTicket(uint256 _ticketId) external payable {
        require(ticketsForSale[_ticketId], "Ticket not for sale!");

        address ticketOwner = ownerOf(_ticketId);

        Ticket storage _ticket = ticketsDetails[_ticketId];

        require(msg.value >= _ticket.price);

        (bool success, ) = ticketOwner.call{value: msg.value}("");

        require(success, "Payment is failed!");

        _transfer(ticketOwner, msg.sender, _ticketId);

        ticketsForSale[_ticketId] = false;
    }

    function sellTicket(uint256 _ticketId, uint256 _price) external {
        require(ownerOf(_ticketId) == msg.sender, "You not a owner!");

        Ticket storage _ticket = ticketsDetails[_ticketId];
        _ticket.price = _price;

        ticketsForSale[_ticketId] = true;
    }

    function getTicketDetails(uint256 _ticketId)
        external
        view
        returns (Ticket memory)
    {
        require(_ticketId < ticketsDetails.length);
        return ticketsDetails[_ticketId];
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
        Ticket storage tik = ticketsDetails[_ticketId];
        tik.enable = false;
    }

    function getMessageHashForToken(uint256 _tokenId)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(APPROVE_MSG_PREFIX, _tokenId));
    }
}
