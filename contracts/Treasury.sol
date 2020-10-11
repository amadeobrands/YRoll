// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/Erc20/IErc20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./ExchangeAdaptor.sol";

contract Treasury is AccessControl, ReentrancyGuard {
    ExchangeAdaptor exchangeAdaptor;

    // @dev mapping from User address to ERC20 address then to Balances
    mapping(address => mapping(address => Balance)) userBalances;

    // @dev clients deposited balance along with allocated balance
    struct Balance {
        uint256 deposited;
        uint256 allocated;
    }

    // @dev allows changing of the exchange adaptor - can be expanded past 1inch in future if needed
    function setExchangeAdaptor(address _exchangeAdaptor) public {
        exchangeAdaptor = ExchangeAdaptor(_exchangeAdaptor);
    }

    // @dev allow deposits of specific tokens which can then be streamed out
    function deposit(
        address _token,
        address _who,
        uint256 _amount
    ) public {
        userBalances[_who][_token].deposited += _amount;

        IERC20(_token).transferFrom(_who, address(this), _amount);
    }

    // @dev allows withdrawal from the treasury, can be called by the depositor or by the stream manager
    function withdraw(
        address _token,
        address _from,
        address _to,
        uint256 _amount
    )
        public
        nonReentrant
        hasSufficientAvailableBalance(_from, _token, _amount)
    {
        decreaseTotalBalance(_token, _from, _amount);

        IERC20(_token).transfer(_to, _amount);
    }

    // @dev performs a swap allowing users to withdraw a different token to the deposited one
    function withdrawAs(
        address _tokenSell,
        address _tokenBuy,
        uint256 _amountToSell,
        uint256 _minAmountToBuy,
        uint256[] memory _distribution,
        address _from,
        address _to
    )
        public
        nonReentrant
        hasSufficientAvailableBalance(_from, _tokenSell, _amountToSell)
    {
        decreaseTotalBalance(_tokenSell, _from, _amountToSell);

        IERC20(_tokenSell).transfer(address(exchangeAdaptor), _amountToSell);

        exchangeAdaptor.exchange(
            _tokenSell,
            _tokenBuy,
            _amountToSell,
            _minAmountToBuy,
            _distribution,
            _to
        );
    }

    // @dev once a stream is started, funds are allocated and locked from being withdrawn
    // by the account which started the stream
    function allocateFunds(
        address _token,
        address _who,
        uint256 _amount
    ) public {
        userBalances[_who][_token].allocated += _amount;
    }

    // @dev decreases the total & available balance
    function decreaseTotalBalance(
        address _token,
        address _who,
        uint256 _amount
    ) internal {
        userBalances[_who][_token].deposited -= _amount;
    }

    // @dev See the total available tokens for client
    function viewUserTokenBalance(address _token, address _who)
        public
        view
        returns (uint256 deposited, uint256 allocated)
    {
        return (
            userBalances[_who][_token].deposited,
            userBalances[_who][_token].allocated
        );
    }

    // @dev subtract the allocated balance from the deposit to see the available funds
    function viewAvailableBalance(address _from, address _token)
        public
        view
        returns (uint256)
    {
        return
            userBalances[_from][_token].deposited -
            userBalances[_from][_token].allocated;
    }

    // @dev ensure there is enough balance to perform withdrawal
    modifier hasSufficientAvailableBalance(
        address _from,
        address _token,
        uint256 _amount
    ) {
        require(
            viewAvailableBalance(_from, _token) >= _amount,
            "Insufficient balance to withdraw"
        );
        _;
    }
}
