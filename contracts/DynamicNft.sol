// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

struct Tiket{
    string secret;
    bool enable;
    bool forSale;

    uint tiketId;
    address owner;

    uint price;
}

contract DynamicNft{
    using Counters for Counters.Counter;

    Counters.Counter private tiketIds;

    // count of tikets
    mapping(address => uint) private balances;

    // address: iterrable (0, 1, 2 to count tikets) array index in allTikets
    mapping(address => mapping(uint => uint)) private tiketsArrayIndex;

    mapping(address => mapping(uint => uint)) private tiketsIterableIndex;

    // tiket id - to adress
    mapping(uint => address) private tiketsOwner;
    
    // tiket id and who can change it oncer
    mapping(uint => mapping(address => bool)) private sharedTiketWith;

    mapping(uint => uint) private tiketIdToTiketIndex;

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
        uint currentIndex = this.myBalance();

        tiketsArrayIndex[msg.sender][currentIndex] = allTikets.length;
        tiketsIterableIndex[msg.sender][allTikets.length] = currentIndex;

        tiketsOwner[currentIndex] = msg.sender;
        tiketIdToTiketIndex[currentIndex] = allTikets.length;
        

        allTikets.push(Tiket(_secret, true, true, newTiketId, msg.sender, price));
        balances[msg.sender] += 1;
        
        tiketIds.increment();
    }

    function buyTiket(uint tiketId) external {
        address tiketOwner = tiketsOwner[tiketId];
        require(tiketOwner != address(0), "Tiket not exist!");
        
        uint tiketArrayIndex = tiketIdToTiketIndex[tiketId];

        Tiket storage result = allTikets[tiketArrayIndex];
        require(result.forSale, "Tiket not for sale!");
        
        uint ownerBalance = balanceOf(tiketOwner);
        
        uint byerBalance = balanceOf(msg.sender);

        uint lastOwnerArrayIndex = tiketsArrayIndex[tiketOwner][ownerBalance];
        uint selledOwnerArrayIndex = tiketsArrayIndex[tiketOwner][ownerBalance];
        
        tiketsArrayIndex[tiketOwner][selledOwnerArrayIndex] = lastOwnerArrayIndex;

        delete tiketsIterableIndex[msg.sender][lastOwnerArrayIndex];

        tiketsArrayIndex[msg.sender][byerBalance] = selledOwnerArrayIndex;
        tiketsIterableIndex[msg.sender][selledOwnerArrayIndex] = byerBalance;
        // tiketsIterableIndex[msg.sender][allTikets.length] = currentIndex;

        // change balance
        balances[msg.sender] += 1;
        balances[tiketOwner] -= 1;
        
        // change owner
        tiketsOwner[tiketId] = msg.sender;
        
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

        return allTikets[tiketsArrayIndex[to][index]];
    }

    function allowUseTiket(address to, uint tiketId) external isTiketOwner(msg.sender, tiketId) {
        sharedTiketWith[tiketId][to] = true;
    }

    function useTiket(uint tiketId) external canUseTiket(msg.sender, tiketId) {
        Tiket storage usedTiket = allTikets[tiketIdToTiketIndex[tiketId]];
        usedTiket.enable = false;
    }

    function showTiket(uint tiketId) external view returns(Tiket memory){
        Tiket memory result = allTikets[tiketIdToTiketIndex[tiketId]];
        if(sharedTiketWith[tiketId][msg.sender]){
            // uncreapt message
            // result.secret = result.secret;
        }
        return result;
    }
}