pragma solidity^0.4.19;

contract RockPaperScissors{
    
    enum answer {Vacio, Piedra, Papel, Tijeras} //Solo tengo estas opciones para jugar.
    struct data{
        address player1; //información jugar1
        address player2;
        bytes32 secret_mov1;  //el movimiento del jugador1 viene como un hash
        answer mov2;   //el movimiento del jugador 2.
        bool gameStatus;  //indica si el juego está en curso.
        string whoWon;  //indica el ganador.
    }
    
    mapping(bytes32 => data) public playersInfo;  //ingreso al struct
    mapping(address => uint) public balances;  // para controlar los balances
    uint public amountToBet;  //guarda cuanto es el monto a apostar
    address public owner;  
    uint public PlayerOneMovements=1;   // cantidad de movimientos para el player1
    uint public PlayerTwoMovements=1;
    
    modifier onlyA(){			
        require(owner==msg.sender);		//Solo Alice puede interactuar.
        _;
    }
    event retirado(address to, uint amount);  //para seguir quien a retirado dinero
    
    function RockPaperScissors() payable public{
        owner=msg.sender;  
    }
    
    function startGame(bytes32 secret, answer _mov1, address player2, bytes32 onlyAlice, uint amount) public payable{
        balances[msg.sender]+=msg.value;  //si apuesta, se guarda.
        require(owner==msg.sender); 
        require(answer.Vacio != _mov1); //no puede jugar a vacio
        require(player2!=0x0);  // debe haber un rival
        require(player2!=msg.sender); //no puede ser el mismo jugar 1 el rival.
        require(PlayerOneMovements>0);  // le debe quedar movimientos para jugar.
        require(amount==balances[msg.sender]);  //lo utilicé de esta manera, pues si tiene balance acumulado, no es necesario que ingrese ether para jugar nuevamente.
        require(playersInfo[secret].gameStatus==false); // no debe haber un juego en curso previamente
        amountToBet=amount;   //setea el valor de la apuesta para el jugador 2.
        PlayerOneMovements=0; 
        playersInfo[secret].player1=msg.sender;   //guarda y configura la información en el struct.
        playersInfo[secret].secret_mov1=keccak256(onlyAlice,_mov1);  //guarda el movimiento, con una clave secreta conocida unicamente por alice.
        playersInfo[secret].player2=player2;
        playersInfo[secret].gameStatus=true;
    }
    
    function answerPlayer2(bytes32 secret, answer _mov2) public payable{
        balances[msg.sender]+=msg.value; // guarda lo apostado por el jugador2
        require(amountToBet==balances[msg.sender]); //lo hice así, pues si tiene saldo acumulado, no es necesario que apueste nuevamente.
        require(playersInfo[secret].player2==msg.sender);  //debe ser el rival
        require(playersInfo[secret].gameStatus==true); // debe haber un juego en curso.
        require(answer.Vacio != _mov2); //la respuesta no puede ser vacia
        require(PlayerTwoMovements>0); //debe quedarle movimiento para jugar
        PlayerTwoMovements=0; 
        playersInfo[secret].mov2=_mov2;  //guarda la jugada en el struct.
    }
    
    function getTheResult(bytes32 secret, bytes32 onlyAlice)public returns(string){  //obtiene el resultado, hace una prueba if para cada caso.
        require(playersInfo[secret].gameStatus==true);
        require(playersInfo[secret].secret_mov1!=0x0);
        require(playersInfo[secret].mov2!=answer.Vacio);
   //nota, no se me ocurrió una manera más eficiente, pues la complejidad está en que la respueta de alice viene con un hash.     
        if(playersInfo[secret].secret_mov1==keccak256(onlyAlice,answer.Piedra)
        && playersInfo[secret].mov2==answer.Piedra){
            playersInfo[secret].whoWon="Empate";
            playersInfo[secret].gameStatus=false;
        }
        if(playersInfo[secret].secret_mov1==keccak256(onlyAlice,answer.Papel)
        && playersInfo[secret].mov2==answer.Papel){
            playersInfo[secret].whoWon="Empate";
            playersInfo[secret].gameStatus=false;
        }
        if(playersInfo[secret].secret_mov1==keccak256(onlyAlice,answer.Tijeras)
        && playersInfo[secret].mov2==answer.Tijeras){
            playersInfo[secret].whoWon="Empate";
            playersInfo[secret].gameStatus=false;
        }
        if(playersInfo[secret].secret_mov1==keccak256(onlyAlice,answer.Piedra)
        && playersInfo[secret].mov2==answer.Papel){
            playersInfo[secret].whoWon="BobGana";
            balances[playersInfo[secret].player2]+=amountToBet;
            balances[playersInfo[secret].player1]-=amountToBet;
            playersInfo[secret].gameStatus=false;
        }
        if(playersInfo[secret].secret_mov1==keccak256(onlyAlice,answer.Papel)
        && playersInfo[secret].mov2==answer.Tijeras){
            playersInfo[secret].whoWon="BobGana";
            balances[playersInfo[secret].player2]+=amountToBet;
            balances[playersInfo[secret].player1]-=amountToBet;
            playersInfo[secret].gameStatus=false;
        }
        
        if(playersInfo[secret].secret_mov1==keccak256(onlyAlice,answer.Piedra)
        && playersInfo[secret].mov2==answer.Tijeras){
            playersInfo[secret].whoWon="AliceGana";
            balances[playersInfo[secret].player1]+=amountToBet;
            balances[playersInfo[secret].player2]-=amountToBet;
            playersInfo[secret].gameStatus=false;
        }
        
        if(playersInfo[secret].secret_mov1==keccak256(onlyAlice,answer.Tijeras)
        && playersInfo[secret].mov2==answer.Papel){
            playersInfo[secret].whoWon="AliceGana";
            balances[playersInfo[secret].player1]+=amountToBet;
            balances[playersInfo[secret].player2]-=amountToBet;
            playersInfo[secret].gameStatus=false;
        }
        
        if(playersInfo[secret].secret_mov1==keccak256(onlyAlice,answer.Papel)
        && playersInfo[secret].mov2==answer.Piedra){
            playersInfo[secret].whoWon="AliceGana";
            balances[playersInfo[secret].player1]+=amountToBet;
            balances[playersInfo[secret].player2]-=amountToBet;
            playersInfo[secret].gameStatus=false;
        }
        
        if(playersInfo[secret].secret_mov1==keccak256(onlyAlice,answer.Tijeras)
        && playersInfo[secret].mov2==answer.Piedra){
            playersInfo[secret].whoWon="BobGana";
            balances[playersInfo[secret].player2]+=amountToBet;
            balances[playersInfo[secret].player1]-=amountToBet;
            playersInfo[secret].gameStatus=false;
        }
        return(playersInfo[secret].whoWon);
    }
    
    function ResetGame(bytes32 secret) public{
        require(playersInfo[secret].gameStatus==false);   //solo puede resetear si el juego acabó
        require(msg.sender==playersInfo[secret].player1 || msg.sender == playersInfo[secret].player2);  //solo los jugadores pueden resetear.
        PlayerOneMovements=1;  //vuelve todo al estado inicial.
        PlayerTwoMovements=1;
        amountToBet=0;
        playersInfo[secret].player2=0x0;
        playersInfo[secret].secret_mov1=0x0;
        playersInfo[secret].mov2=answer.Vacio;
        playersInfo[secret].whoWon="";
        
    }
    
  //nota, si el jugador no retira fondos y decide seguir jugando, los fondos se acumulan.
  
    function withDraw(uint amount)public payable{   //el jugador decide retirar fondos
        require(balances[msg.sender]>0);
        balances[msg.sender]-=amount;  
        msg.sender.transfer(amount);
        retirado(msg.sender,amount);
    }
    
    function contractBalance() public view returns(uint){
        return address(this).balance;
    }
    
    function emergency()public onlyA{  //en caso de emergencia, devuelve los fondos y destruye el contrato.
        selfdestruct(owner);
    }
}
