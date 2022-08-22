const hre = require("hardhat");

async function main() {
  const Setup = await ethers.getContractFactory("contracts/Random/Setup.sol");
  const setup = await Setup.attach(`0x3E3e2621B54098900934B47626135A3b000c2d16`);
  const randomContractAddress = await setup.random();
  console.log(randomContractAddress);
  const Random = await ethers.getContractFactory("Random");
  const random = await Random.attach(randomContractAddress);
  await random.solve(4);
  const solved = await setup.isSolved();
  console.log('Solved',solved);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
