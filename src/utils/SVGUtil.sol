// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {Base64} from "./Base64.sol";
import {Strings} from "./Strings.sol";

contract SVGUtil {
    using Strings for uint8;
    using Strings for uint160;
    using Strings for uint256;

    string[] elements = [
        "&#8858;",
        "&#8889;",
        "&#164;",
        "&#8942;",
        "&#10070;",
        "&#10696;",
        "&#10803;",
        "&#10811;",
        "&#10057;",
        "&#10023;",
        "&#8762;",
        "&#8790;",
        "&#8853;",
        "&#8915;",
        "&#10773;",
        "&#8578;"
    ];

    function _upper() internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<svg height="310" width="250" xmlns="http://www.w3.org/2000/svg">',
                    "<defs>",
                    '<radialGradient id="myGradient">'
                )
            );
    }

    function _orbital(bytes32 seed, uint8 num)
        internal
        pure
        returns (string memory)
    {
        string memory first = string(
            abi.encodePacked(
                '<stop offset="',
                (5 + num * 20).toString(),
                '%" stop-color="rgb(',
                uint8(seed[0 + (num * 6)]).toString(),
                ",",
                uint8(seed[1 + (num * 6)]).toString(),
                ",",
                uint8(seed[2 + (num * 6)]).toString(),
                ')" />'
            )
        );
        string memory second = string(
            abi.encodePacked(
                '<stop offset="',
                (15 + num * 20).toString(),
                '%" stop-color="rgb(',
                uint8(seed[3 + (num * 6)]).toString(),
                ",",
                uint8(seed[4 + (num * 6)]).toString(),
                ",",
                uint8(seed[5 + (num * 6)]).toString(),
                ')" />'
            )
        );
        return string(abi.encodePacked(first, second));
    }

    function _lower() internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "</radialGradient>",
                    "</defs>",
                    '<rect height="310" width="250" fill="#000" rx="20"></rect>'
                )
            );
    }

    function _elements(bytes32 seed) internal view returns (string memory) {
        string memory a = elements[uint8(seed[31]) & 15];
        string memory b = elements[(uint8(seed[31]) & 240) / 16];
        string memory c = elements[uint8(seed[30]) & 15];
        string memory d = elements[(uint8(seed[30]) & 240) / 16];

        return
            string(
                abi.encodePacked(
                    '<text fill="#ffffff" font-size="30" font-family="Verdana" x="12.5%" y="12.5%" text-anchor="middle">',
                    a,
                    "</text>",
                    '<text fill="#ffffff" font-size="30" font-family="Verdana" x="87.5%" y="12.5%" text-anchor="middle">',
                    b,
                    "</text>",
                    '<text fill="#ffffff" font-size="30" font-family="Verdana" x="12.5%" y="77.5%" text-anchor="middle">',
                    c,
                    "</text>",
                    '<text fill="#ffffff" font-size="30" font-family="Verdana" x="87.5%" y="77.5%" text-anchor="middle">',
                    d,
                    "</text>"
                )
            );
    }

    function _power(bytes32 seed) internal pure returns (string memory) {
        uint256 n = uint256(seed);
        uint256 count;
        string memory power;
        assembly {
            for {

            } gt(n, 0) {

            } {
                n := and(n, sub(n, 1))
                count := add(count, 1)
            }
        }
        if (count > 127) {
            power = uint256((count - 128) * 125).toString();
        } else {
            power = uint256((128 - count) * 125).toString();
        }

        return
            string(
                abi.encodePacked(
                    '<text fill="#ffffff" font-size="30" font-family="Verdana" x="50%" y="92.5%" text-anchor="middle">&#937;: ',
                    power,
                    "</text>",
                    '<circle cx="125" cy="125" r="100" fill="url(\'#myGradient\')" />',
                    "</svg>"
                )
            );
    }

    function _getPower(uint256 id) internal pure returns (uint256 power) {
        uint256 count;
        assembly {
            for {

            } gt(id, 0) {

            } {
                id := and(id, sub(id, 1))
                count := add(count, 1)
            }
        }
        if (count > 127) {
            power = uint256((count - 128) * 125);
        } else {
            power = uint256((128 - count) * 125);
        }
    }

    function _particle(bytes32 seed) internal view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    _upper(),
                    _orbital(seed, 0),
                    _orbital(seed, 1),
                    _orbital(seed, 2),
                    _orbital(seed, 3),
                    _orbital(seed, 4),
                    _lower(),
                    _elements(seed),
                    _power(seed)
                )
            );
    }

    function _image(bytes32 seed) internal view returns (string memory) {
        string memory image = _particle(seed);
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(bytes(image))
                )
            );
    }

    function _manifest(bytes32 seed, address discoverer)
        internal
        view
        returns (string memory)
    {
        string memory image = _image(seed);
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name": "',
                                uint256(seed).toHexString(),
                                '", "description": "Discovered By: ',
                                uint160(discoverer).toHexString(20),
                                '", "image": "',
                                image,
                                '"}'
                            )
                        )
                    )
                )
            );
    }
}
