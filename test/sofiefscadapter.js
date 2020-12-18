const SofieFSCAdapter = artifacts.require("SofieFSCAdapter");
const SofieFSC = artifacts.require("SofieFSC")
const truffleAssert = require('truffle-assertions')
const Web3 = require('web3')
const chai = require("chai")

contract("SofieFSCAdapter", accounts => {
    const sha3 = Web3.utils.sha3
    let sofieAdapterContract;
    let sofieFSC;
    let owner = accounts[0]
    let user1 = accounts[1]
    let contractBase;

    it("should allow the setting of the contract base", async () => {
        let tx = await sofieAdapterContract.setContractBase(contractBase, {from: owner})

        truffleAssert.eventEmitted(tx, 'LogContractSet', (ev) => {
            return ev.base === contractBase
        })
    })

    it("should allow the registration of a new user", async () => {
        let tx = await sofieAdapterContract.registerUser(user1, {from: owner})

        truffleAssert.eventEmitted(tx, 'LogUserRegistered', (ev) => {
            return ev.user === user1
        })
    })

    it("should allow the removal of an existing user", async () => {
        await sofieAdapterContract.registerUser(user1, {from: owner})
        let tx = await sofieAdapterContract.removeUser(user1, {from: owner})

        truffleAssert.eventEmitted(tx, 'LogUserRemoved', (ev) => {
            return ev.user === user1
        })
    })

    it("should allow the interlegder receiver to accept event data", async() => {
        await sofieAdapterContract.setContractBase(contractBase, {from: owner})
        let nonce = 1
        let data = "0x00000000000000000000000000000000000000000000000000000000000001400000000000000000000000000000000000000000000000000000000000000180e882f7ff255814141995a7647c8f2c1d5cbab36504c39eed184fd3edd5544d5f90400a77f2ac838227d9249e6f7cc159af604af1ce481c99d81270af6cac9e79da4b6f3764ec69ee8a937a63ade3fa4a8294331ae1b79abff322195b17e7ff0a3f9ae1d3b2333ce01823ed779a6a2119f189af8591ef139b41c14726995fcbcc143d097ceed41b8af42d7186469f402064bfba235a12088afafbfccd6ce40e8bf598e1cc720782f21da4bfe074eba26a99b22b0a9842dcddd197f7822ed72998fd45b31dfc75074451434d8fc63c9164d3f692788df3edb49c10e94cb64b638463ad2fb28345e0fffa22c3eef858d4fb1d2b30c04aca5ee4b16a72f85aea7700000000000000000000000000000000000000000000000000000000000000001845323830313133303230303032303634444244383030414200000000000000000000000000000000000000000000000000000000000000000000000000000042307834313362343332356235346365653731646337633165636565313433356338616336333265313037653932336362373232316530616138303932326461393435000000000000000000000000000000000000000000000000000000000000"
        let tx = await sofieAdapterContract.interledgerReceive(nonce, data, {from: owner})
        truffleAssert.eventEmitted(tx, 'InterledgerEventAccepted', (ev) => {
            return ev.nonce.toNumber() === nonce
        })
    })

    it("should allow the interledger receiver to reject event data", async() => {
        let nonce = 1
        let data = "0x00000000000000000000000000000000000000000000000000000000000001400000000000000000000000000000000000000000000000000000000000000180e882f7ff255814141995a7647c8f2c1d5cbab36504c39eed184fd3edd5544d5f90400a77f2ac838227d9249e6f7cc159af604af1ce481c99d81270af6cac9e79da4b6f3764ec69ee8a937a63ade3fa4a8294331ae1b79abff322195b17e7ff0a3f9ae1d3b2333ce01823ed779a6a2119f189af8591ef139b41c14726995fcbcc143d097ceed41b8af42d7186469f402064bfba235a12088afafbfccd6ce40e8bf598e1cc720782f21da4bfe074eba26a99b22b0a9842dcddd197f7822ed72998fd45b31dfc75074451434d8fc63c9164d3f692788df3edb49c10e94cb64b638463ad2fb28345e0fffa22c3eef858d4fb1d2b30c04aca5ee4b16a72f85aea7700000000000000000000000000000000000000000000000000000000000000001845323830313133303230303032303634444244383030414200000000000000000000000000000000000000000000000000000000000000000000000000000042307834313362343332356235346365653731646337633165636565313433356338616336333265313037653932336362373232316530616138303932326461393435000000000000000000000000000000000000000000000000000000000000"
        let tx = await sofieAdapterContract.interledgerReceive(nonce, data, {from: owner})
        truffleAssert.eventEmitted(tx, 'InterledgerEventRejected', (ev) => {
            return ev.nonce.toNumber() === nonce
        })
    })

    beforeEach(async () => {
        // Deploy adapter smart contract
        sofieAdapterContract = await SofieFSCAdapter.new({from: owner})

        // Deploy FSC contract
        sofieFSC = await SofieFSC.new({from: owner})

        // Set contract base
        contractBase = sofieFSC.address

        // Register adapter as user of the FSC contract
        await sofieFSC.registerUser(sofieAdapterContract.address, {from: owner})
    })

    afterEach(async () => {
        await sofieAdapterContract.kill({from: owner})
        await sofieFSC.kill({from: owner})
    })
})
