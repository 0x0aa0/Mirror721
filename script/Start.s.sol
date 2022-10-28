// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {Script} from "../lib/forge-std/src/Script.sol";
import {NFT} from "../src/NFT.sol";

contract Start is Script {
    NFT mirror = NFT(address(0)); //address of implementation

    function run(string memory seed) public {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));

        vm.startBroadcast(deployerPrivateKey);

        mirror.mint(seed);

        vm.stopBroadcast();
    }
}
