const { ethers } = require("ethers");
require("dotenv").config();

async function main() {
  const [castId, claimer] = process.argv.slice(2);
  const pk = process.env.VALIDATOR_PRIVATE_KEY;
  const wallet = new ethers.Wallet(pk);
  const packed = ethers.utils.solidityPack(["bytes32", "address"], [castId, claimer]);
  const hash = ethers.utils.keccak256(packed);
  const sig = await wallet.signMessage(ethers.utils.arrayify(hash));
  console.log("Signature:", sig);
}

main();
