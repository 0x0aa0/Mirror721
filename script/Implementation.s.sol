// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {Script} from "../lib/forge-std/src/Script.sol";
import {NFT} from "../src/NFT.sol";

contract Implementation is Script {
    address _wormhole = address(0); //wormhole address for chain
    uint16 _prevChain = 0; //previous wormhole chain id
    uint16 _nextChain = 0; //next wormhole chain id
    uint8 _finality = 200; //configure finality
    uint256 _chains = 2; //number of chains
    string _name = "MIRROR";
    string _symbol = ":)";

    //dry run to get creation code
    function run() public returns (NFT implementation) {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));

        vm.startBroadcast(deployerPrivateKey);

        implementation = new NFT(
            _wormhole,
            _finality,
            _chains,
            _prevChain,
            _nextChain,
            _name,
            _symbol
        );

        vm.stopBroadcast();
    }
}
