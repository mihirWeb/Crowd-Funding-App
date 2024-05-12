import { ethers } from "./ethers-5.6.esm.min.js"
import { abi, contractAddress } from "./constants.js"

const connectButton = document.getElementById("connectButton")
const withdrawButton = document.getElementById("withdrawButton")
const fundButton = document.getElementById("fundButton")
// const balanceButton = document.getElementById("balanceButton")
// const campaignOwner = "0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f";

// Create a provider connected to the network where your contract is deployed
// const provider = new ethers.providers.JsonRpcProvider('https://eth-sepolia.g.alchemy.com/v2/64ItDmE6Q2MTLJBkhKbbbcYAR9OQ4Noe');
const provider = new ethers.providers.Web3Provider(window.ethereum);

// Replace with your Alchemy project's endpoint URL
// const ALCHEMY_API_KEY = '64ItDmE6Q2MTLJBkhKbbbcYAR9OQ4Noe';
// const networkName = Network.ETH_SEPOLIA;

// Create a provider connected to the Alchemy network
// const provider = new ethers.providers.JsonRpcProvider(
//   `https://${networkName}.alchemyapi.io/v2/${ALCHEMY_API_KEY}`
// );


// Create a contract instance
const contract = new ethers.Contract(contractAddress, abi, provider);

connectButton.onclick = connect
withdrawButton.onclick = withdraw
fundButton.onclick = fund
// balanceButton.onclick = getBalance


async function connect() {
  if (typeof window.ethereum !== "undefined") {
    try {
      console.log("hiiiiii");
      await ethereum.request({ method: "eth_requestAccounts" })
      connectButton.innerHTML = "Connected To Metamask"
    } catch (error) {
      console.log(error)
    }
    const accounts = await ethereum.request({ method: "eth_accounts" })
    console.log(accounts)
  } else {
    alert("Metamask Not Found")
  }
}

async function withdraw() {
  console.log(`Withdrawing...`)
  if (typeof window.ethereum !== "undefined") {
    const provider = new ethers.providers.Web3Provider(window.ethereum)
    await provider.send('eth_requestAccounts', [])
    const signer = provider.getSigner()
    const contract = new ethers.Contract(contractAddress, abi, signer)
    try {
      const transactionResponse = await contract.withdraw()
      await listenForTransactionMine(transactionResponse, provider)
      // await transactionResponse.wait(1)
    } catch (error) {
      console.log(error)
    }
  } else {
    withdrawButton.innerHTML = "Please install MetaMask"
  }
}

async function fund() {
  try {
    const etherAmount = document.getElementById("ethAmount").value;
    console.log(`Funding with ${etherAmount}...`);

    if (typeof window.ethereum!== "undefined") {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(contractAddress, abi, signer);

      const valueToSend = ethers.utils.parseEther(etherAmount);
      const txConfig = {
        to: contractAddress,
        value: `0x${valueToSend.toHexString().slice(2)}`, // Add 0x prefix and remove leading 0x
        gasLimit: ethers.utils.hexlify(100000), // Pass a number
      };

      console.log(txConfig);

      const transactionResponse = await provider.sendTransaction(txConfig);
      await listenForTransactionMine(transactionResponse, provider);
    } else {
      fundButton.innerHTML = "Please install MetaMask";
    }
  } catch (error) {
    console.error(`Error funding contract: ${error.message}`);
    fundButton.innerHTML = `Error funding contract: ${error.message}`; // Display error message to user
  }
}


async function getBalance() {
  if (typeof window.ethereum !== "undefined") {
    const provider = new ethers.providers.Web3Provider(window.ethereum)
    try {
      const balance = await provider.getBalance(contractAddress)
      console.log(ethers.utils.formatEther(balance))
    } catch (error) {
      console.log(error)
    }
  } else {
    balanceButton.innerHTML = "Please install MetaMask"
  }
}

function listenForTransactionMine(transactionResponse, provider) {
    console.log(`Mining ${transactionResponse.hash}`)
    return new Promise((resolve, reject) => {
        try {
            provider.once(transactionResponse.hash, (transactionReceipt) => {
                console.log(
                    `Completed with ${transactionReceipt.confirmations} confirmations. `
                )
                resolve()
            })
        } catch (error) {
            reject(error)
        }
    })
}