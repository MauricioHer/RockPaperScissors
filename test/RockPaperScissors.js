const RockPaperScissors = artifacts.require("./RockPaperScissors.sol");

contract('RockPaperScissors', accounts=>{console.log(accounts);
	let rock;
	var alice = accounts[0];
	var bob = accounts[1];

	beforeEach('set up contract', async function(){
		rock = await RockPaperScissors.new({from: accounts[0]})
	});

	it('it should be owned Player1', async function(){
		assert.equal(await rock.owner(),alice,"alice isn't the owner")
	});

	it('it allows Player1 to do the first movement', async function(){
		let startGame = await rock.startGame("firstgame",1,accounts[1],"kibernum",1000,{from:accounts[0], value:1000});
		let balance= await rock.contractBalance();
		const result1= await rock.playersInfo.call("0x666972737467616d650000000000000000000000000000000000000000000000");
		assert.equal(result1[0],accounts[0]);
		assert.equal(result1[1],accounts[1]);
		assert.equal(result1[4],true);
		assert.equal(balance.valueOf(),1000,"the contract doesn't have 1000");
		assert.equal(await rock.amountToBet(),1000,"the amount is not set properly");
		assert.equal(await rock.PlayerOneMovements(),0,"movements1 not set");
		assert.equal(await rock.PlayerTwoMovements(),1,"movements2 not set");
		assert.notEqual(result1[2],"0x0");
	});

	it('it allows Player2 to do the second movement', async function(){
		let startGame = await rock.startGame("firstgame",1,accounts[1],"kibernum",1000,{from:accounts[0], value:1000});
		let answerPlayer2= await rock.answerPlayer2("firstgame",1,{from: accounts[1], value:1000});
		let balance = await rock.contractBalance();
		const result1= await rock.playersInfo.call("0x666972737467616d650000000000000000000000000000000000000000000000");
		assert.equal(result1[0],accounts[0]);
		assert.equal(result1[1],accounts[1]);
		assert.equal(result1[4],true);
		assert.equal(balance.valueOf(),2000,"the contract doesn't have 2000");
		assert.equal(await rock.amountToBet(),1000, "the amount is not set properly");
		assert.equal(await rock.PlayerOneMovements(),0,"movements1 not set");
		assert.equal(await rock.PlayerTwoMovements(),0,"movements2 not set");
		assert.notEqual(result1[3],0);
	});

	it('it shows the answer of the match', async function(){
		let startGame = await rock.startGame("firstgame",1,accounts[1],"kibernum",1000,{from:accounts[0], value:1000});
		let answerPlayer2= await rock.answerPlayer2("firstgame",1,{from: accounts[1], value:1000});
		let balance = await rock.contractBalance();
		let getTheResult = await rock.getTheResult("firstgame","kibernum");
		const result1= await rock.playersInfo.call("0x666972737467616d650000000000000000000000000000000000000000000000");
		console.log(result1[5]);
		assert.equal(result1[5],"Empate");
	});

	it('if they tie in the game, there is no movement of funds', async function(){
		let startGame = await rock.startGame("firstgame",1,accounts[1],"kibernum",1000,{from:accounts[0], value:1000});
		let answerPlayer2= await rock.answerPlayer2("firstgame",1,{from: accounts[1], value:1000});
		let balance = await rock.contractBalance();
		let getTheResult = await rock.getTheResult("firstgame","kibernum");
		const result1= await rock.playersInfo.call("0x666972737467616d650000000000000000000000000000000000000000000000");
		let balance1=await rock.balances.call(accounts[0]);
		let balance2=await rock.balances.call(accounts[1]);
		assert.equal(result1[5],"Empate");
		assert.equal(balance1,1000);
		assert.equal(balance2,1000);
	});

	it('it allows to withdraw funds', async function(){
		let startGame = await rock.startGame("firstgame",1,accounts[1],"kibernum",10000000000000000,{from:accounts[0], value:10000000000000000});
		const AliceBalanceBefore=web3.eth.getBalance(accounts[0]).toNumber();
		let answerPlayer2= await rock.answerPlayer2("firstgame",1,{from: accounts[1], value:10000000000000000});
		let balance = await rock.contractBalance();
		let getTheResult = await rock.getTheResult("firstgame","kibernum");
		let withdraw= await rock.withDraw(10000000000000000, {from: accounts[0]});
		let balance1=await rock.balances.call(accounts[0]);
		assert.equal(balance1,0);
		assert.isAbove(web3.eth.getBalance(alice).toNumber(),AliceBalanceBefore);
	});

	it('allows to reset the game', async function(){
		let startGame = await rock.startGame("firstgame",1,accounts[1],"kibernum",1000,{from:accounts[0], value:1000});
		let answerPlayer2= await rock.answerPlayer2("firstgame",1,{from: accounts[1], value:1000});
		let balance = await rock.contractBalance();
		let getTheResult = await rock.getTheResult("firstgame","kibernum");	
		let restart = await rock.ResetGame("firstgame", {from: accounts[1]});
    	const result1= await rock.playersInfo.call("0x666972737467616d650000000000000000000000000000000000000000000000");
    	assert.equal(result1[2],0x0);
    	assert.equal(result1[3],0);
    	assert.equal(result1[4],false);
    	assert.equal(result1[5], "");
	});

	it("Emergency returns all the funds to Alice & only alice can use it", async function(){
		let startGame = await rock.startGame("firstgame",1,accounts[1],"kibernum",10000000000000000,{from:accounts[0], value:10000000000000000});
		const AliceBalanceBefore = web3.eth.getBalance(accounts[0]).toNumber();	
		let answerPlayer2= await rock.answerPlayer2("firstgame",1,{from: accounts[1], value:10000000000000000});
		let balance = await rock.contractBalance();
		let getTheResult = await rock.getTheResult("firstgame","kibernum");
		let remove = await rock.emergency();
		assert.isAbove(web3.eth.getBalance(alice).toNumber(),AliceBalanceBefore);
	});

	it("if Alice plays rock & bob paper, bob wins & the reward is move to his address.", async function(){
		let startGame = await rock.startGame("firstgame",1,accounts[1],"kibernum",1000,{from:accounts[0], value:1000});
		let answerPlayer2= await rock.answerPlayer2("firstgame",2,{from: accounts[1], value:1000});
		let balance = await rock.contractBalance();
		const balanceBefore= await rock.balances.call(accounts[1]);
		let getTheResult = await rock.getTheResult("firstgame","kibernum");
		const result1= await rock.playersInfo.call("0x666972737467616d650000000000000000000000000000000000000000000000");
		const balanceAfter=await rock.balances.call(accounts[1]);
		console.log(result1[5]);
		assert.equal(result1[5],"BobGana");
		assert.isAbove(balanceAfter,balanceBefore);
	});

	it("if Alice plays paper & bob scissors, bob wins & the reward is move to his address.", async function(){
		let startGame = await rock.startGame("firstgame",2,accounts[1],"kibernum",1000,{from:accounts[0], value:1000});
		let answerPlayer2= await rock.answerPlayer2("firstgame",3,{from: accounts[1], value:1000});
		let balance = await rock.contractBalance();
		const balanceBefore= await rock.balances.call(accounts[1]);
		let getTheResult = await rock.getTheResult("firstgame","kibernum");
		const result1= await rock.playersInfo.call("0x666972737467616d650000000000000000000000000000000000000000000000");
		const balanceAfter=await rock.balances.call(accounts[1]);
		console.log(result1[5]);
		assert.equal(result1[5],"BobGana");
		assert.isAbove(balanceAfter,balanceBefore);
	});

	it("if Alice plays scissors & bob rock, bob wins & the reward is move to his address.", async function(){
		let startGame = await rock.startGame("firstgame",3,accounts[1],"kibernum",1000,{from:accounts[0], value:1000});
		let answerPlayer2= await rock.answerPlayer2("firstgame",1,{from: accounts[1], value:1000});
		let balance = await rock.contractBalance();
		const balanceBefore= await rock.balances.call(accounts[1]);
		let getTheResult = await rock.getTheResult("firstgame","kibernum");
		const result1= await rock.playersInfo.call("0x666972737467616d650000000000000000000000000000000000000000000000");
		const balanceAfter=await rock.balances.call(accounts[1]);
		console.log(result1[5]);
		assert.equal(result1[5],"BobGana");
		assert.isAbove(balanceAfter,balanceBefore);
	});

	it("if Alice plays rock & bob scissors, Alice wins & the reward is move to his address.", async function(){
		let startGame = await rock.startGame("firstgame",1,accounts[1],"kibernum",1000,{from:accounts[0], value:1000});
		let answerPlayer2= await rock.answerPlayer2("firstgame",3,{from: accounts[1], value:1000});
		let balance = await rock.contractBalance();
		const balanceBefore= await rock.balances.call(accounts[0])
		let getTheResult = await rock.getTheResult("firstgame","kibernum");
		const result1= await rock.playersInfo.call("0x666972737467616d650000000000000000000000000000000000000000000000");
		const balanceAfter=await rock.balances.call(accounts[0]);
		console.log(result1[5]);
		assert.equal(result1[5],"AliceGana");
		assert.isAbove(balanceAfter,balanceBefore);
	});

	it("if Alice plays paper & bob rock, Alice wins & the reward is move to his address.", async function(){
		let startGame = await rock.startGame("firstgame",2,accounts[1],"kibernum",1000,{from:accounts[0], value:1000});
		let answerPlayer2= await rock.answerPlayer2("firstgame",1,{from: accounts[1], value:1000});
		let balance = await rock.contractBalance();
		const balanceBefore= await rock.balances.call(accounts[0])
		let getTheResult = await rock.getTheResult("firstgame","kibernum");
		const result1= await rock.playersInfo.call("0x666972737467616d650000000000000000000000000000000000000000000000");
		const balanceAfter=await rock.balances.call(accounts[0]);
		console.log(result1[5]);
		assert.equal(result1[5],"AliceGana");
		assert.isAbove(balanceAfter,balanceBefore);
	});	

	it("if Alice plays scissors & bob paper, Alice wins & the reward is move to his address.", async function(){
		let startGame = await rock.startGame("firstgame",3,accounts[1],"kibernum",1000,{from:accounts[0], value:1000});
		let answerPlayer2= await rock.answerPlayer2("firstgame",2,{from: accounts[1], value:1000});
		let balance = await rock.contractBalance();
		const balanceBefore= await rock.balances.call(accounts[0])
		let getTheResult = await rock.getTheResult("firstgame","kibernum");
		const result1= await rock.playersInfo.call("0x666972737467616d650000000000000000000000000000000000000000000000");
		const balanceAfter=await rock.balances.call(accounts[0]);
		console.log(result1[5]);
		assert.equal(result1[5],"AliceGana");
		assert.isAbove(balanceAfter,balanceBefore);
	});	

	it ("only the owner can start the game", async function(){
		try{
			await rock.startGame("firstgame",1,accounts[1],"kibernum",1000,{from:accounts[1],value:1000})
		}catch(error){
			return true;
		}
		throw new Error("I shouldn't see this")
		const result = await rock.balances.call(accounts[0]);
		assert.equal(result,0);
		assert.equal(await PlayerTwoMovements(),1);

	});

	it("only if you send the right amount of ethers you can start the game", async function(){
		try{
			await rock.startGame("firstgame",1,accounts[1],"kibernum",1000,{from:accounts[0],value:100})
		}catch(error){
			return true;
		}
		throw new Error("I shouldn't see this")
		const result = await rock.balances.call(accounts[0]);
		assert.equal(result,0);
		assert.equal( await PlayerOneMovements(),1);
	});

	it("if you've done your first movement, u can't do a second one", async function(){
		await rock.startGame("firstgame",1,accounts[1],"kibernum",1000,{from:accounts[0],value:1000})
		try{
			await rock.startGame("firstgame",2,accounts[1],"kibernum",1000,{from:accounts[0],value:1000})
		}catch(error){
			return true;
		}
		throw new Error("I shouldn't see this")
		const result = await rock.balances.call(accounts[0]);
		assert.equal(result,1000);
		assert.equal( await PlayerOneMovements(),0);
	});

	it("the player 2 can play only after the player1's movement", async function(){
		try{
			await rock.answerPlayer2("firstgame",1,{from:accounts[1],value:1000})
		}catch(error){
			return true;
		}
		throw new Error("the contract allows player 2 play before mov1");
		const result = await rock.balances.call(accounts[0]);
		assert.equal(result,0);
		assert.equal(await PlayerOneMovements(),1);
		assert.equal(await PlayerTwoMovements(),1);
	});

	it("player2 can play only if he sends the right amount of ethers", async function(){
		await rock.startGame("firstgame",1,accounts[1],"kibernum",1000,{from:accounts[0],value:1000})
		try{
			await rock.answerPlayer2("firstgame",1,{from:accounts[1],value:10})
		}catch(error){
			return true;
		}
		throw new Error("the contract allows player 2 send a different amount of ethers");
		const result1= await rock.balances.call(accounts[0]);
		const result2= await rock.balances.call(accounts[1]);
		assert.equal(result1,1000);
		assert.equal(result2,0); 
		assert.equal(await PlayerOneMovements(),0);
		assert.equal(await PlayerTwoMovements(),1);
	})

	it("you can reset the game only if the latest game is over", async function(){
		await rock.startGame("firstgame",1,accounts[1],"kibernum",1000,{from:accounts[0],value:1000})
		await rock.answerPlayer2("firstgame",1,{from:accounts[1],value:1000});
		try{
			await rock.ResetGame("firstgame",{from:accounts[0]});
		}catch(error){
			return true;
		}
		throw new Error("El contrato permite resetearse sin haber finalizado el juego");
		const result1= await rock.balances.call(accounts[0]);
		const result2= await rock.balances.call(accounts[1]);
		assert.equal(result1,1000);
		assert.equal(result2,1000); 
		assert.equal(await PlayerOneMovements(),0);
		assert.equal(await PlayerTwoMovements(),0);
	});

	it("if you don't have balance to withdraw u can't use the function",async function(){
		try{
			await rock.withDraw(100,{from:accounts[0]});
		}catch(error){
			return true;
		}
		throw new Error("the contract allows withdraw without having balance")
	});

})