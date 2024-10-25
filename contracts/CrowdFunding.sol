// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract CrowdFunding {
    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 target;
        uint256 deadline;
        uint256 amountCollected;
        string image;
        address[] donators;
        uint256[] donations;
        bool withdrawn;
    }

    mapping(uint256 => Campaign) public campaigns;
    uint256 public numberOfCampaigns = 0;

    
    event CampaignCreated(uint256 indexed campaignId, address indexed owner, string title, uint256 target, uint256 deadline);
    event DonationReceived(uint256 indexed campaignId, address indexed donator, uint256 amount);
    event FundsWithdrawn(uint256 indexed campaignId, address indexed owner, uint256 amount);

    function createCampaign(
        address _owner,
        string memory _title,
        string memory _description,
        uint256 _target,
        uint256 _deadline,
        string memory _image
    ) public returns (uint256) {
        require(_deadline > block.timestamp, "The deadline should be a date in the future.");
        require(_target > 0, "Target must be greater than zero.");

        Campaign storage campaign = campaigns[numberOfCampaigns];
        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadline = _deadline;
        campaign.amountCollected = 0;
        campaign.image = _image;
        campaign.withdrawn = false;

        emit CampaignCreated(numberOfCampaigns, _owner, _title, _target, _deadline);

        numberOfCampaigns++;
        return numberOfCampaigns - 1;
    }

    function donateCampaign(uint256 _id) public payable {
        require(_id < numberOfCampaigns, "Campaign does not exist.");
        require(msg.value > 0, "Donation amount must be greater than zero.");

        Campaign storage campaign = campaigns[_id];
        require(block.timestamp < campaign.deadline, "Campaign has ended.");

        campaign.donators.push(msg.sender);
        campaign.donations.push(msg.value);
        campaign.amountCollected += msg.value;

        emit DonationReceived(_id, msg.sender, msg.value);
    }

    function withdraw(uint256 _id) public {
        require(_id < numberOfCampaigns, "Campaign does not exist.");

        Campaign storage campaign = campaigns[_id];
        require(msg.sender == campaign.owner, "Only the campaign owner can withdraw funds.");
        require(block.timestamp > campaign.deadline, "Campaign is still active.");
        require(!campaign.withdrawn, "Funds have already been withdrawn.");
        require(campaign.amountCollected > 0, "No funds to withdraw.");

        uint256 amountToTransfer = campaign.amountCollected;
        campaign.withdrawn = true;

        (bool sent, ) = payable(campaign.owner).call{value: amountToTransfer}("");
        require(sent, "Failed to send Ether.");

        emit FundsWithdrawn(_id, campaign.owner, amountToTransfer);
    }

    function getDonators(uint256 _id) public view returns (address[] memory, uint256[] memory) {
        require(_id < numberOfCampaigns, "Campaign does not exist.");
        return (campaigns[_id].donators, campaigns[_id].donations);
    }

    function getCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);

        for (uint256 i = 0; i < numberOfCampaigns; i++) {
            Campaign storage item = campaigns[i];
            allCampaigns[i] = item;
        }

        return allCampaigns;
    }

   
    receive() external payable {}

  
    fallback() external payable {}
}
