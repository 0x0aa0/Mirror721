// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {Script} from "../lib/forge-std/src/Script.sol";
import {NFT} from "../src/NFT.sol";
import {console} from "../lib/forge-std/src/console.sol";

contract Validate is Script {
    NFT mirror = NFT(address(0)); //address of implementation

    function run(bytes calldata vaa) public {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));

        vm.startBroadcast(deployerPrivateKey);

        mirror.validateMint(vaa);

        vm.stopBroadcast();
    }
}
