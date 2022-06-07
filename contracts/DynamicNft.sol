// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

struct Tiket{
    string secret;
    bool enable;
    bool forSale;
    uint tiketId;
    uint price;
}

contract DynamicNft{
    using Counters for Counters.Counter;

    Counters.Counter private tiketIds;

    // count of tikets
    mapping(address => uint) private balances;

    // address: iterrable (0, 1, 2 to count tikets) tiketId
    mapping(address => mapping(uint => uint)) private ownableTikets;

    mapping(address => mapping(uint => uint)) private reverseOwnableTikets;

    // tiket id - to adress
    mapping(uint => address) private tiketsOwner;
    
    // tiketId - array index
    mapping(uint => uint) private tiketsMetadataIndex;

    // tiket id and who can change it oncer
    mapping(uint => mapping(address => bool)) private sharedTiketWith;

    Tiket[] private allTikets;

    modifier isTiketOwner(address from, uint tiketId){
        require(tiketsOwner[tiketId] == from, "You are not tiket owner");
        _;
    }

    modifier canUseTiket(address who, uint tiketId){
        require(sharedTiketWith[tiketId][who], "You not allow use this tiket");
        _;
    }

    constructor(){}

    function mintTiket(string memory _secret, uint price) external{
        uint newTiketId = tiketIds.current();
        
        uint currentIndex = balanceOf(msg.sender);

        ownableTikets[msg.sender][currentIndex] = newTiketId;
        reverseOwnableTikets[msg.sender][newTiketId] = currentIndex;

        tiketsOwner[newTiketId] = msg.sender;
        tiketsMetadataIndex[newTiketId] = allTikets.length;
        

        allTikets.push(Tiket(_secret, true, true, newTiketId, price));

        balances[msg.sender] += 1;
        
        tiketIds.increment();
    }

    function buyTiket(uint tiketId) external {
        address tiketOwner = tiketsOwner[tiketId];
        require(tiketOwner != address(0), "Tiket not exist!");

        Tiket storage result = allTikets[tiketsMetadataIndex[tiketId]];
        require(result.forSale, "Tiket not for sale!");
        
        uint ownerBalance = balanceOf(tiketOwner);
        uint byerBalance = balanceOf(msg.sender);

        // if balabnce more than one, do swap
        if(ownerBalance > 1){
            // seller iterable index [0 -> balance]
            uint iterableSelledIndex = reverseOwnableTikets[tiketOwner][tiketId];
            // last tiket id, which we will swap with removed
            uint latestTiketIdForSwap = ownableTikets[tiketOwner][ownerBalance - 1];
            reverseOwnableTikets[tiketOwner][latestTiketIdForSwap] = iterableSelledIndex;
            ownableTikets[tiketOwner][iterableSelledIndex] = latestTiketIdForSwap;
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
    }

    function myBalance() external view returns(uint){
        return balanceOf(msg.sender);
    }

    function balanceOf(address to) internal view returns(uint){
        return balances[to];
    }

    function getAllTikets() external view returns (Tiket[] memory){
        return allTikets;
    }

    function getMyTiketByIndex(uint index) external view returns(Tiket memory){
        return getTiketByIndex(msg.sender, index);
    }

    function getTiketByIndex(address to, uint index) internal view returns (Tiket memory){
        require(balanceOf(to) > index, "Wrong index, out of boundce");

        return allTikets[tiketsMetadataIndex[ownableTikets[to][index]]];
    }

    function allowUseTiket(address to, uint tiketId) external isTiketOwner(msg.sender, tiketId) {
        sharedTiketWith[tiketId][to] = true;
    }

    function useTiket(uint tiketId) external canUseTiket(msg.sender, tiketId) {
        Tiket storage usedTiket = allTikets[tiketsMetadataIndex[tiketId]];
        usedTiket.enable = false;
    }

    function showTiket(uint tiketId) external view returns(Tiket memory){
        Tiket memory result = allTikets[tiketsMetadataIndex[tiketId]];
        if(sharedTiketWith[tiketId][msg.sender]){
            // uncreapt message
            // result.secret = result.secret;
        }
        return result;
    }
}