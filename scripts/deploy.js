const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  const validator = process.env.VALIDATOR_ADDRESS || deployer.address;
  const CastClaim = await hre.ethers.getContractFactory("CastClaim");
  const contract = await CastClaim.deploy(validator);
  await contract.deployed();
  console.log("CastClaim deployed to:", contract.address);
}

main().catch((e) => { console.error(e); process.exit(1); });
