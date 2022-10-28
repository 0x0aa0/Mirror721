// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {Script} from "../lib/forge-std/src/Script.sol";
import {NFT} from "../src/NFT.sol";

contract StartTransfer is Script {
    NFT mirror = NFT(address(0)); //address of implementation

    function run(address to, string memory seed) public {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));
        address deployerPublicKey = vm.envAddress("PUBLIC_KEY");

        vm.startBroadcast(deployerPrivateKey);

        mirror.transferFrom(
            deployerPublicKey,
            to,
            uint256(keccak256(abi.encodePacked(seed)))
        );

        vm.stopBroadcast();
    }
}
