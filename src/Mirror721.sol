// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {ERC721} from "../lib/solmate/src/tokens/ERC721.sol";
import {IWormhole} from "../lib/wormhole/ethereum/contracts/interfaces/IWormhole.sol";
import {Structs} from "../lib/wormhole/ethereum/contracts/Structs.sol";

abstract contract Mirror721 is ERC721 {
    event transferInitiated(uint64 sequence);

    address public immutable wormhole;
    uint8 public immutable finality;

    uint256 public immutable chains;
    uint16 public immutable prevChain;
    uint16 public immutable nextChain;

    mapping(uint256 => address) public processing;
    mapping(uint256 => address) public prevAddr;
    mapping(uint256 => bool) public passed;
    mapping(uint256 => bool) public timestampLock;
    mapping(uint256 => uint256) public lastTimestamp;

    constructor(
        address _wormhole,
        uint8 _finality,
        uint256 _chains,
        uint16 _prevChain,
        uint16 _nextChain,
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {
        wormhole = _wormhole;
        finality = _finality;
        chains = _chains;
        prevChain = _prevChain;
        nextChain = _nextChain;
    }

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual override {
        _checkProcessing(from, to, id);
        uint64 sequence = _emitTransfer(from, to, id, 1);
        emit transferInitiated(sequence);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual override {
        _checkProcessing(from, to, id);
        uint64 sequence = _emitTransfer(from, to, id, 1);
        emit transferInitiated(sequence);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata /*data*/
    ) public virtual override {
        _checkProcessing(from, to, id);
        uint64 sequence = _emitTransfer(from, to, id, 1);
        emit transferInitiated(sequence);
    }

    function validateTransfer(bytes calldata encodedVM)
        external
        returns (uint64 sequence)
    {
        bytes memory payload = _validateVM(encodedVM, prevChain);

        (address from, address to, uint256 id, uint256 counter) = abi.decode(
            payload,
            (address, address, uint256, uint256)
        );

        if (processing[id] == address(0)) {
            ++counter;
            prevAddr[id] = from;
            delete passed[id];
            super.transferFrom(from, to, id);
            sequence = _emitTransfer(from, to, id, counter);
        } else {
            require(counter == chains);
            require(to == processing[id]);
            prevAddr[id] = from;
            delete processing[id];
            delete timestampLock[id];
            super.transferFrom(from, to, id);
        }
    }

    function validateMint(bytes calldata encodedVM)
        external
        returns (uint64 sequence)
    {
        bytes memory payload = _validateVM(encodedVM, prevChain);

        (address to, uint256 id, uint256 counter) = abi.decode(
            payload,
            (address, uint256, uint256)
        );

        if (processing[id] == address(0)) {
            ++counter;
            passed[id] = true;
            super._mint(to, id);
            sequence = _emitMint(to, id, counter);
        } else {
            require(counter == chains);
            require(to == processing[id]);
            delete processing[id];
            delete timestampLock[id];
            super._mint(to, id);
        }
    }

    function rectify(uint256 id) public virtual returns (uint64 sequence) {
        if (prevAddr[id] != address(0)) {
            address current = _ownerOf[id];
            super.transferFrom(current, prevAddr[id], id);
            prevAddr[id] = current;
        }
        sequence = IWormhole(wormhole).publishMessage(
            1,
            abi.encodePacked(id),
            finality
        );
    }

    function rectifyMint(uint256 id) public virtual returns (uint64 sequence) {
        if (passed[id]) {
            _burn(id);
            delete passed[id];
        }
        sequence = IWormhole(wormhole).publishMessage(
            1,
            abi.encodePacked(id),
            finality
        );
    }

    function rectificationReciever(bytes calldata encodedVM)
        external
        returns (uint64 sequence)
    {
        bytes memory payload = _validateVM(encodedVM, nextChain);

        uint256 id = abi.decode(payload, (uint256));

        if (processing[id] == address(0)) {
            sequence = rectify(id);
        } else {
            require(!timestampLock[id]);
            delete processing[id];
        }
    }

    function rectificationMintReciever(bytes calldata encodedVM)
        external
        returns (uint64 sequence)
    {
        bytes memory payload = _validateVM(encodedVM, nextChain);

        uint256 id = abi.decode(payload, (uint256));

        if (processing[id] == address(0)) {
            sequence = rectifyMint(id);
        } else {
            require(!timestampLock[id]);
            delete processing[id];
        }
    }

    function proveTimestamp(uint256 id) external returns (uint64 sequence) {
        require(processing[id] != address(0));
        sequence = IWormhole(wormhole).publishMessage(
            1,
            abi.encodePacked(id, lastTimestamp[id]),
            finality
        );
    }

    function removeTimestampLock(bytes calldata encodedVM) external {
        (Structs.VM memory vm, bool valid, string memory reason) = IWormhole(
            wormhole
        ).parseAndVerifyVM(encodedVM);

        if (!valid) revert(reason);
        require(address(bytes20(vm.emitterAddress)) == address(this));

        (uint256 id, uint256 timestamp) = abi.decode(
            vm.payload,
            (uint256, uint256)
        );

        require(timestamp < lastTimestamp[id]);
        delete timestampLock[id];
    }

    function _mint(address to, uint256 id) internal virtual override {
        require(processing[id] == address(0));
        processing[id] = to;
        uint64 sequence = _emitMint(to, id, 1);
        emit transferInitiated(sequence);
    }

    function _emitTransfer(
        address from,
        address to,
        uint256 id,
        uint256 counter
    ) internal virtual returns (uint64 sequence) {
        sequence = IWormhole(wormhole).publishMessage(
            1,
            abi.encode(
                bytes32(uint256(uint160(from))),
                bytes32(uint256(uint160(to))),
                id,
                counter
            ),
            finality
        );
    }

    function _emitMint(
        address to,
        uint256 id,
        uint256 counter
    ) internal virtual returns (uint64 sequence) {
        sequence = IWormhole(wormhole).publishMessage(
            1,
            abi.encode(bytes32(uint256(uint160(to))), id, counter),
            finality
        );
    }

    function _validateVM(bytes calldata encodedVM, uint16 chain)
        internal
        virtual
        returns (bytes memory payload)
    {
        (Structs.VM memory vm, bool valid, string memory reason) = IWormhole(
            wormhole
        ).parseAndVerifyVM(encodedVM);

        if (!valid) revert(reason);

        require(vm.emitterChainId == chain);
        require(address(uint160(uint256(vm.emitterAddress))) == address(this));

        return (vm.payload);
    }

    function _checkProcessing(
        address from,
        address to,
        uint256 id
    ) internal virtual {
        require(from == _ownerOf[id]);
        require(to != address(0));
        require(
            msg.sender == from ||
                isApprovedForAll[from][msg.sender] ||
                msg.sender == getApproved[id]
        );
        require(processing[id] == address(0));
        processing[id] = to;
        lastTimestamp[id] = block.timestamp;
        timestampLock[id] = true;
    }
}
