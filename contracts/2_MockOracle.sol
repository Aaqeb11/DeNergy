// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract MockOracle {
    uint256 private productionData;
    uint256 private consumptionData;
    address public admin;

    mapping(address => bool) public isMeter;

    event MeterRegistered(address indexed meter);
    event MeterRemoved(address indexed meter);
    event EnergyDataUpdated(
        address indexed meter,
        uint256 production,
        uint256 consumption
    );

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }
    modifier onlyMeter() {
        require(isMeter[msg.sender], "Not authorized meter");
        _;
    }

    constructor(){
        admin = msg.sender;
    }

    function registerMeter(address _meter) external onlyAdmin {
        require(_meter!=address(0),"No address present");
        isMeter[_meter] = true;
        emit MeterRegistered(_meter);
    }

    function removeMeter(address _meter) external onlyAdmin {
        require(_meter!=address(0),"No address found");
        isMeter[_meter] = false;
        emit MeterRemoved((_meter));
    }
    
    // Set test data
    function setEnergyData(uint256 _production, uint256 _consumption) external onlyMeter {
        productionData = _production;
        consumptionData = _consumption;

        emit EnergyDataUpdated(msg.sender, _production, _consumption);
    }
    
    // Implements the IOracle interface
    function getEnergyData() external view returns (uint256 production, uint256 consumption) {
        return (productionData, consumptionData);
    }
}
