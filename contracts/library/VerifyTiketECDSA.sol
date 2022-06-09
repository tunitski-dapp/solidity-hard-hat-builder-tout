// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

library VerifyTiketECDSA {
    using ECDSA for bytes32;

    string private constant approveUseTokenMessage = "Approve use token:";

    function getMessageHashForToken(uint256 tokenId)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(approveUseTokenMessage, tokenId));
    }

    function verifySignature(uint256 tokenId, bytes memory signature)
        public
        pure
        returns (address)
    {
        return
            getMessageHashForToken(tokenId).toEthSignedMessageHash().recover(
                signature
            );
    }
}
