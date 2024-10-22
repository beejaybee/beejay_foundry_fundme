//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error FundMe_notOwner();

contract FundMe {
    using PriceConverter for uint256;
    AggregatorV3Interface private s_priceFeed;

    uint256 public constant MINIMUM_USD = 5e18;
    address[] private s_funders;

    mapping(address funder => uint256 amountFunded) private s_addressToAmountFunded;
    address private immutable i_owner;

    constructor(address priceFeed) {
        //set the deployer as owner
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }
    function fund() payable public {
        require(msg.value.getConversion(s_priceFeed) >= MINIMUM_USD, "Did not send enough ETH");
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function cheaperWithdraw() onlyOwner public {
        uint256 fundersLength = s_funders.length;
        for(uint256 funderIndex; funderIndex < fundersLength; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        
        s_funders = new address[](0);

        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    function withdraw() onlyOwner public { // withdrawal made by only owner

        for(uint256 funderIndex; funderIndex < s_funders.length; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        s_funders = new address[](0);  // reset the funders array to 0;


        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    function getVersion() public view returns(uint256){
        return PriceConverter.getVersion(s_priceFeed);
    }

    receive() external payable { 
        fund();
    }

    fallback() external payable { 
        fund();
    }

    /** 
     * View / pure functions
     * 
     * getters
    */

   function getAddressToAmountFunded(
    address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns(address) {
        return s_funders[index];
    }

    function getOwner() external view returns(address) {
        return i_owner;
    }

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Sender is not the owner");
        if (msg.sender != i_owner) revert FundMe_notOwner();
        _;
    }
}