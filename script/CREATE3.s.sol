// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {Script} from "../lib/forge-std/src/Script.sol";
import {ICREATE3Factory} from "../lib/create3-factory/src/ICREATE3Factory.sol";

contract CREATE3 is Script {
    ICREATE3Factory factory =
        ICREATE3Factory(address(0)); //address of factory

    bytes32 salt = keccak256(abi.encodePacked("")); //add salt

    bytes creationCode = hex""; //deployment code from dry run

    function run() public {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));

        vm.startBroadcast(deployerPrivateKey);

        factory.deploy(salt, creationCode);

        vm.stopBroadcast();
    }
}
