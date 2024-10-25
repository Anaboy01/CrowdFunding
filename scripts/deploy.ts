import hardhat from 'hardhat';
const { ethers } = hardhat;

async function main() {

const ClaimFaucetFactory = await ethers.getContractFactory("CrowdFunding");
const claimFaucetFactory = await ClaimFaucetFactory.deploy();

const deployedContract = await claimFaucetFactory.waitForDeployment();

  console.log('Contract Deployed at ' + deployedContract.target);

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

// 0x5FbDB2315678afecb367f032d93F642f64180aa3