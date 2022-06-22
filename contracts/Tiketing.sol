// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

struct Tiket {
    string secret;
    bool enable;
    bool forSale;
    uint256 tiketId;
    uint256 price;
}

contract Ticketing {
    event BuyTiket(address indexed who, uint256 indexed tiketId);

    event UsedTiket(address indexed who, uint256 indexed tiketId);

    event SharedTiket(address indexed to, uint256 indexed tiketId);

    event CreateTiket(address indexed who, uint256 indexed tiketId);

    using Counters for Counters.Counter;

    Counters.Counter private tiketIds;

    // count of tikets
    mapping(address => uint256) private balances;

    // address: iterrable (0, 1, 2 to count tikets) tiketId
    mapping(address => mapping(uint256 => uint256)) private ownableTikets;

    mapping(address => mapping(uint256 => uint256))
        private reverseOwnableTikets;

    // tiket id - to adress
    mapping(uint256 => address) private tiketsOwner;

    // tiketId - array index
    mapping(uint256 => uint256) private tiketsMetadataIndex;

    // tiket id and who can change it oncer
    mapping(uint256 => mapping(address => bool)) private sharedTiketWith;

    Tiket[] private allTikets;

    modifier isTiketOwner(address from, uint256 tiketId) {
        require(tiketsOwner[tiketId] == from, "You are not tiket owner");
        _;
    }

    modifier canUseTiket(address who, uint256 tiketId) {
        require(sharedTiketWith[tiketId][who], "You not allow use this tiket");
        _;
    }

    constructor() {}

    function mintTiket(string memory _secret, uint256 price) external {
        uint256 newTiketId = tiketIds.current();

        uint256 currentIndex = balanceOf(msg.sender);

        ownableTikets[msg.sender][currentIndex] = newTiketId;
        reverseOwnableTikets[msg.sender][newTiketId] = currentIndex;

        tiketsOwner[newTiketId] = msg.sender;
        tiketsMetadataIndex[newTiketId] = allTikets.length;

        allTikets.push(Tiket(_secret, true, true, newTiketId, price));

        balances[msg.sender] += 1;

        tiketIds.increment();

        emit CreateTiket(msg.sender, newTiketId);
    }

    function buyTiket(uint256 tiketId) external payable {
        address tiketOwner = tiketsOwner[tiketId];
        require(tiketOwner != address(0), "Tiket not exist!");

        Tiket storage result = allTikets[tiketsMetadataIndex[tiketId]];
        require(result.forSale, "Tiket not for sale!");

        uint256 ownerBalance = balanceOf(tiketOwner);
        uint256 byerBalance = balanceOf(msg.sender);

        // if balabnce more than one, do swap
        if (ownerBalance > 1) {
            // seller iterable index [0 -> balance]
            uint256 iterableSelledIndex = reverseOwnableTikets[tiketOwner][
                tiketId
            ];
            // last tiket id, which we will swap with removed
            uint256 latestTiketIdForSwap = ownableTikets[tiketOwner][
                ownerBalance - 1
            ];
            reverseOwnableTikets[tiketOwner][
                latestTiketIdForSwap
            ] = iterableSelledIndex;
            ownableTikets[tiketOwner][
                iterableSelledIndex
            ] = latestTiketIdForSwap;
        }

        delete reverseOwnableTikets[tiketOwner][tiketId];
        delete ownableTikets[tiketOwner][ownerBalance - 1];

        // change owner
        ownableTikets[msg.sender][byerBalance] = tiketId;
        reverseOwnableTikets[msg.sender][tiketId] = byerBalance;
        tiketsOwner[tiketId] = msg.sender;

        // change balance
        balances[msg.sender] += 1;
        balances[tiketOwner] -= 1;

        // can sell tiket only once
        result.forSale = false;
        result.price = 0;

        emit BuyTiket(msg.sender, tiketId);

        (bool success, ) = tiketOwner.call{value: msg.value}("");
        require(success, "Failed!");
    }

    function myBalance() external view returns (uint256) {
        return balanceOf(msg.sender);
    }

    function balanceOf(address to) internal view returns (uint256) {
        return balances[to];
    }

    function getAllTikets() external view returns (Tiket[] memory) {
        return allTikets;
    }

    function getMyTiketByIndex(uint256 index)
        external
        view
        returns (Tiket memory)
    {
        return getTiketByIndex(msg.sender, index);
    }

    function getTiketByIndex(address to, uint256 index)
        internal
        view
        returns (Tiket memory)
    {
        require(balanceOf(to) > index, "Wrong index, out of boundce");

        return allTikets[tiketsMetadataIndex[ownableTikets[to][index]]];
    }

    function allowUseTiket(address to, uint256 tiketId)
        external
        isTiketOwner(msg.sender, tiketId)
    {
        sharedTiketWith[tiketId][to] = true;

        emit SharedTiket(to, tiketId);
    }

    function useTiket(uint256 tiketId)
        external
        canUseTiket(msg.sender, tiketId)
    {
        Tiket storage usedTiket = allTikets[tiketsMetadataIndex[tiketId]];
        usedTiket.enable = false;

        emit UsedTiket(msg.sender, tiketId);
    }

    function showTiket(uint256 tiketId) external view returns (Tiket memory) {
        Tiket memory result = allTikets[tiketsMetadataIndex[tiketId]];
        if (sharedTiketWith[tiketId][msg.sender]) {
            // uncreapt message
            // result.secret = result.secret;
        }
        return result;
    }
}
