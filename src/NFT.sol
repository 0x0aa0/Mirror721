// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {Mirror721Test} from "./Mirror721Test.sol";
import {SVGUtil} from "./utils/SVGUtil.sol";

contract NFT is Mirror721Test, SVGUtil {
    mapping(uint256 => address) discoverer;

    constructor(
        address _wormhole,
        uint8 _finality,
        uint256 _chains,
        uint16 _prevChain,
        uint16 _nextChain,
        string memory _name,
        string memory _symbol
    )
        Mirror721Test(
            _wormhole,
            _finality,
            _chains,
            _prevChain,
            _nextChain,
            _name,
            _symbol
        )
    {}

    function tokenURI(uint256 id) public view override returns (string memory) {
        return _manifest(bytes32(id), discoverer[id]);
    }

    function mint(string memory seed) external {
        uint256 id = uint256(keccak256(abi.encodePacked(seed)));
        discoverer[id] = msg.sender;
        _mint(msg.sender, id);
    }
}
