//SPDX-License-Identifier :MIT
pragma solidity 0.8.23;

contract DcaCore {

    mapping(address user => mapping(address collateralToken => uint256 amount)) private balance;
    receive(){
    }
    constructor(){
    }
    function deposit(address _tokenAddress, uint256 _amount) public payable{
    }
    function createDCA(address intoken,address outtoken,)
    
}