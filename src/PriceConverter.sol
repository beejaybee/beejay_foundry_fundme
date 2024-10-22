// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


library PriceConverter {
    function getPrice(AggregatorV3Interface priceFeed) internal view returns(uint256) {
        // address 0x694AA1769357215DE4FAC081bf1f309aDC325306 sepolia
        // address 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF zksync
        // ABI
        (, int256 answer, , ,) = priceFeed.latestRoundData();
        return uint256(answer * 1e10); // There's no decimal in solidity;
    }

    function getConversion(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns(uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18; // coz no decimal
        return ethAmountInUsd;
    }

    function getVersion(AggregatorV3Interface priceFeed) internal view returns(uint256) {
        return priceFeed.version();
    }
}