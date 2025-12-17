// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

interface IEnergyToken {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract EnergyMarketplace {
    IEnergyToken public energyToken;
    uint256 public nextListingId;

    struct Listing {
        uint256 id;
        address seller;
        uint256 amount;        
        uint256 pricePerToken;
        bool active;
    }

    mapping(uint256 => Listing) public listings;

    event ListingCreated(
        uint256 indexed id,
        address indexed seller,
        uint256 amount,
        uint256 pricePerToken
    );

    event ListingCancelled(uint256 indexed id);
    event Purchase(
        uint256 indexed id,
        address indexed buyer,
        uint256 amount,
        uint256 totalPrice
    );

    constructor(address _energyToken) {
        require(_energyToken != address(0), "Token required");
        energyToken = IEnergyToken(_energyToken);
    }


    function createListing(uint256 amount, uint256 pricePerToken) external {
        require(amount > 0, "Amount = 0");
        require(pricePerToken > 0, "Price = 0");

        uint256 listingId = nextListingId++;
        listings[listingId] = Listing({
            id: listingId,
            seller: msg.sender,
            amount: amount,
            pricePerToken: pricePerToken,
            active: true
        });

        emit ListingCreated(listingId, msg.sender, amount, pricePerToken);
    }


    function buy(uint256 listingId, uint256 amountToBuy) external payable {
        Listing storage listing = listings[listingId];
        require(listing.active, "Listing inactive");
        require(amountToBuy > 0, "Amount = 0");
        require(amountToBuy <= listing.amount, "Not enough tokens");

        uint256 totalPrice = amountToBuy * listing.pricePerToken;
        require(msg.value == totalPrice, "Incorrect ETH sent");

        payable(listing.seller).transfer(totalPrice);

        bool ok = energyToken.transferFrom(listing.seller, msg.sender, amountToBuy);
        require(ok, "Token transfer failed");

        listing.amount -= amountToBuy;
        if (listing.amount == 0) {
            listing.active = false;
        }

        emit Purchase(listingId, msg.sender, amountToBuy, totalPrice);
    }

    function cancelListing(uint256 listingId) external {
        Listing storage listing = listings[listingId];
        require(listing.seller == msg.sender, "Not seller");
        require(listing.active, "Already inactive");

        listing.active = false;
        emit ListingCancelled(listingId);
    }
}
