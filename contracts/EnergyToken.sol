// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EnergyToken is ERC20, Ownable {

    address public minter;

    event MinterUpdated(address indexed newMinter);

    constructor() ERC20("Energy kWh Token", "EKWH") Ownable(msg.sender) {}

    modifier onlyMinter() {
        require(msg.sender == minter, "Not minter");
        _;
    }

    function setMinter(address _minter) external onlyOwner {
        require(_minter != address(0), "Invalid minter");
        minter = _minter;
        emit MinterUpdated(_minter);
    }

    function mint(address to, uint256 amount) external onlyMinter {
        _mint(to, amount);
    }
}
