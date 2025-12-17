// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IOracle {
    function setEnergyData(uint256 _production, uint256 _consumption) external;
}

contract SmartMeter {
    address public owner;
    IOracle public oracle;

    uint256 public lastProduction;
    uint256 public lastConsumption;
    uint256 public lastUpdatedAt;

    event ReadingPushed(
        address indexed meter,
        uint256 production,
        uint256 consumption,
        uint256 timestamp
    );

    modifier onlyOwner() {
        require(msg.sender==owner, "Not meter owner");
        _;
    }

    constructor(address _owner, address _oracle) {
        require(_owner != address(0), "Owner required");
        require(_oracle != address(0), "Oracle required");
        owner = _owner;
        oracle = IOracle(_oracle);
    }

    function pushReading(uint256 _production, uint256 _consumption) external onlyOwner {
        lastProduction = _production;
        lastConsumption = _consumption;
        lastUpdatedAt   = block.timestamp;

        oracle.setEnergyData(_production, _consumption);
        emit ReadingPushed(address(this), _production, _consumption, block.timestamp);
    }
}